import { CfnOutput, Stack, StackProps, Token } from 'aws-cdk-lib';
import { Construct } from "constructs";
import { AmiHardwareType, EcsOptimizedImage } from 'aws-cdk-lib/aws-ecs';

import * as imagebuilder from 'aws-cdk-lib/aws-imagebuilder';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as s3 from 'aws-cdk-lib/aws-s3';

import { basicPackagesInstaller } from './components/basicPackagesInstaller';
import { awscliInstaller } from './components/awscliInstaller';
import { AMIDeploymentOptions, getAMIDeploymentOptions } from './ami-options';
import { mountS3 } from './components/mountS3';
import { mountFSX } from './components/mountFSX';
import { startDocker } from './components/startDocker';
import { stopDocker } from './components/stopDocker';

interface ComponentParameter {
    name: string;
    value: string[];
}

interface ComponentData {
    name: string;
    platform: string;
    version: string;
    data: string;
    parameters?: ComponentParameter[];
}

interface ComponentInstance {
    ref: imagebuilder.CfnComponent;
    parameters?: ComponentParameter[];
}

export class AMIBuilderPipelineStack extends Stack {

    constructor(scope: Construct,
        id: string,
        props?: StackProps) {
        super(scope, id, props);

        const deploymentOptions = getAMIDeploymentOptions();

        const imageRecipe = createRecipe(this, deploymentOptions);

        const infrastructure = createInfrastructure(this, deploymentOptions);

        const pipeline = new imagebuilder.CfnImagePipeline(this, 'GPUAMIPipeline', {
            name: 'GPUAMIPipeline',
            imageRecipeArn: imageRecipe.attrArn,
            infrastructureConfigurationArn: infrastructure.attrArn
        });

        new CfnOutput(this, 'AMIPipeline', {
            value: pipeline.attrName
        });
    }

}

function createRecipe(scope: Construct, deploymentOptions: AMIDeploymentOptions): imagebuilder.CfnImageRecipe {
    const parentImage = EcsOptimizedImage.amazonLinux2(AmiHardwareType.GPU);


    const mntS3Comp : ComponentData[] = deploymentOptions.s3Bucket
        ? [
            {
                name: 'mountS3Bucket',
                platform: 'Linux',
                version: '1.0.0',
                data: mountS3,
                parameters: [
                    {
                        name: 'BucketName',
                        value: [ deploymentOptions.s3Bucket ],
                    }
                ],
            }
          ]
        : [];

    const mntFSXComp : ComponentData[] = deploymentOptions.fsxVolume
          ? [
              {
                  name: 'mountFSX',
                  platform: 'Linux',
                  version: '1.0.0',
                  data: mountFSX,
                  parameters: [
                      {
                          name: 'FSXVolume',
                          value: [ deploymentOptions.fsxVolume ]
                      },
                  ],
              }
            ]
          : [];

    const compdata : ComponentData[] = [
        {
            name: 'basicPackagesInstaller',
            platform: 'Linux',
            version: '1.0.0',
            data: basicPackagesInstaller,
        },
        {
            name: 'awscliInstaller',
            platform: 'Linux',
            version: '1.0.0',
            data: awscliInstaller,
        },
    ];

    const components = createComponents(scope, [
        {
            name: 'stopDocker',
            platform: 'Linux',
            version: '1.0.0',
            data: stopDocker,
        },
        ...compdata,
        ...mntS3Comp,
        ...mntFSXComp,
        {
            name: 'startDocker',
            platform: 'Linux',
            version: '1.0.0',
            data: startDocker,
        },
    ]);

    const imageId = parentImage.getImage(scope).imageId;

    new CfnOutput(scope, 'ParentImageId', {
        value: imageId
    });

    return new imagebuilder.CfnImageRecipe(scope, 'AMIRecipe', {
        name: 'amiGPURecipe',
        version: '1.0.0',
        parentImage: imageId,
        components: components.map(c => {
            return {
                componentArn: c.ref.attrArn,
                parameters: c.parameters,
            };
        }),
        workingDirectory: '/tmp',
    });
}

function createComponents(scope: Construct, compdata: ComponentData[]): ComponentInstance[] {
    return compdata.map(cd => {
        const r : ComponentInstance = {
            ref: new imagebuilder.CfnComponent(scope, cd.name, cd),
            parameters: cd.parameters
        };
        return r;
    });
}

function createInfrastructure(scope: Construct, deploymentOptions: AMIDeploymentOptions): imagebuilder.CfnInfrastructureConfiguration {
    // create a Role for the EC2 Instance
    const roleName = 'GPUImageRole';
    const profileName = 'GPUBasedInstanceProfile';

    const imageRole = new iam.Role(scope, 'ImageRole', {
        roleName: roleName,
        assumedBy: new iam.ServicePrincipal('ec2.amazonaws.com'),
        managedPolicies: [
            iam.ManagedPolicy.fromAwsManagedPolicyName('AmazonSSMManagedInstanceCore'),
            iam.ManagedPolicy.fromAwsManagedPolicyName('EC2InstanceProfileForImageBuilder'),
            iam.ManagedPolicy.fromAwsManagedPolicyName('CloudWatchAgentServerPolicy'),
        ],
    });

    if (deploymentOptions.s3Bucket) {
        // bucket must exist
        const bucket = s3.Bucket.fromBucketName(scope, deploymentOptions.s3Bucket, deploymentOptions.s3Bucket);
        bucket.grantReadWrite(imageRole);
    }
    
    const instanceProfile = new iam.CfnInstanceProfile(scope, 'GPUBasedInstanceProfile', {
        instanceProfileName: profileName,
        roles: [imageRole.roleName]
    });

    const infrastructure = new imagebuilder.CfnInfrastructureConfiguration(scope, 'Infrastructure', {
        name: 'Infrastructure',
        instanceProfileName: profileName,
    });

    infrastructure.addDependsOn(instanceProfile);

    new CfnOutput(scope, 'AMIProfile', {
        value: infrastructure.instanceProfileName
    });

    return infrastructure;
}