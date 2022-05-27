import { CfnOutput, Stack, StackProps, Token } from 'aws-cdk-lib';
import { Construct } from "constructs";
import { AmiHardwareType, EcsOptimizedImage } from 'aws-cdk-lib/aws-ecs';

import * as imagebuilder from 'aws-cdk-lib/aws-imagebuilder';
import * as iam from 'aws-cdk-lib/aws-iam';
import * as s3 from 'aws-cdk-lib/aws-s3';

import { basicPackagesInstaller } from './components/basicPackagesInstaller';
import { minicondaInstaller } from './components/minicondaInstaller';
import { AMIDeploymentOptions, getAMIDeploymentOptions } from './ami-options';
import { s3Mount } from './components/s3Mount';

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


    const s3mntComp : ComponentData[] = deploymentOptions.mountedS3Bucket
        ? [
            {
                name: 'mountS3Bucket',
                platform: 'Linux',
                version: '1.0.0',
                data: s3Mount,
                parameters: [
                    {
                        name: 'BucketName',
                        value: [ deploymentOptions.mountedS3Bucket ],
                    }
                ],
            }
          ]
        : []

    const compdata : ComponentData[] = [
        {
            name: 'basicPackagesInstaller',
            platform: 'Linux',
            version: '1.0.0',
            data: basicPackagesInstaller,
        },
        {
            name: 'minicondaInstaller',
            platform: 'Linux',
            version: '1.0.0',
            data: minicondaInstaller,
        },
    ];

    const components = createComponents(scope, [
        ...compdata,
        ...s3mntComp,
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

    if (deploymentOptions.mountedS3Bucket) {
        // bucket must exist
        const bucket = s3.Bucket.fromBucketName(scope, deploymentOptions.mountedS3Bucket, deploymentOptions.mountedS3Bucket);
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

    return infrastructure;
}