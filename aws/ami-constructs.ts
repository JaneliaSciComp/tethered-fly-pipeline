import { CfnOutput, Stack, StackProps, Token } from 'aws-cdk-lib';
import { Construct } from "constructs";
import { AmiHardwareType, EcsOptimizedImage } from 'aws-cdk-lib/aws-ecs';
import { CfnImageRecipe, CfnComponent, CfnImagePipeline, CfnInfrastructureConfiguration } from 'aws-cdk-lib/aws-imagebuilder';
import { dockerRuntimeSetup } from './components/dockerRuntimeSetup';
import { basicPackagesInstaller } from './components/basicPackagesInstaller';
import { minicondaInstaller } from './components/minicondaInstaller';
import { CfnInstanceProfile, ManagedPolicy, Role, ServicePrincipal } from 'aws-cdk-lib/aws-iam';
import { SecurityGroup, Vpc } from 'aws-cdk-lib/aws-ec2';

interface ComponentData {
    name: string;
    platform: string;
    version: string;
    data: string;
}

export class AMIBuilderPipelineStack extends Stack {

    constructor(scope: Construct,
                id: string,
                props?: StackProps) {
        super(scope, id, props);

        const imageRecipe = createRecipe(this);

        // create a Role for the EC2 Instance
        const roleName = 'GPUImageRole';
        const profileName = 'GPUBasedInstanceProfile';

        const imageRole = new Role(this, 'ImageRole', {
            roleName: roleName,
            assumedBy: new ServicePrincipal('ec2.amazonaws.com'),
            managedPolicies: [
                ManagedPolicy.fromAwsManagedPolicyName('AmazonSSMManagedInstanceCore'),
                ManagedPolicy.fromAwsManagedPolicyName('EC2InstanceProfileForImageBuilder'),
                ManagedPolicy.fromAwsManagedPolicyName('CloudWatchAgentServerPolicy'),
            ],
        });
  
        const instanceProfile = new CfnInstanceProfile(this, 'GPUBasedInstanceProfile', {
            instanceProfileName: profileName,
            roles: [roleName]
        });

        // const vpc = Vpc.fromLookup(this, 'VPC', {
        //     vpcId: 'vpc-dbd4a1a0',
        //     vpcName: 'default'
        // });
        // const subnet = vpc.publicSubnets[0];
        // const sg = SecurityGroup.fromSecurityGroupId(this, 'SG')
        const infrastructure = new CfnInfrastructureConfiguration(this, 'Infrastructure', {
            name: 'Infrastructure',
            instanceProfileName: profileName,
            instanceTypes: ['g3, g4dn', 'g5', 'g5g', 'p2', 'p3', 'p4d', 'p4de'],
            // subnetId: subnet.subnetId,
            // securityGroupIds: []
        });

        infrastructure.addDependsOn(instanceProfile);

        const pipeline = new CfnImagePipeline(this, 'GPUAMIPipeline', {
            name: 'GPUAMIPipeline',
            imageRecipeArn: imageRecipe.attrArn,
            infrastructureConfigurationArn: infrastructure.attrArn
        });

        pipeline.addDependsOn
    }

}

function createRecipe(scope: Construct) : CfnImageRecipe {
    const parentImage = EcsOptimizedImage.amazonLinux2(AmiHardwareType.GPU);

    const components = createComponents(scope, [
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
        // {
        //     name: 'dockerRuntimeSetup',
        //     platform: 'Linux',
        //     version: '1.0.0',
        //     data: dockerRuntimeSetup,
        // },
    ]);

    const imageId = parentImage.getImage(scope).imageId;

    new CfnOutput(scope, 'ParentImageId', {
        value: imageId
    });

    return new CfnImageRecipe(scope, 'AMIRecipe', {
        name: 'machineRecipe',
        version: '1.0.0',
        parentImage: imageId,
        components: components.map(c => {
            return {
                componentArn: c.attrArn
            };
        }),
    });
}

function createComponents(scope: Construct, compdata: ComponentData[]) : CfnComponent[] {
    return compdata.map (cd => new CfnComponent(scope, cd.name, cd))
}
