import { CfnOutput, Stack, StackProps, Token } from 'aws-cdk-lib';
import { Construct } from "constructs";
import { AmiHardwareType, EcsOptimizedImage } from 'aws-cdk-lib/aws-ecs';

import * as awsbatch from 'aws-cdk-lib/aws-batch';
import * as iam from 'aws-cdk-lib/aws-iam';

export class AWSBatchStack extends Stack {

    constructor(scope: Construct,
        id: string,
        props?: StackProps) {
        super(scope, id, props);

    }

}

function createComputeEnv(scope: Construct, computeEnvName: string) : awsbatch.CfnComputeEnvironment {
    return new awsbatch.CfnComputeEnvironment(scope, computeEnvName, {
        computeEnvironmentName: computeEnvName,
        type: 'MANAGED'
    });
}


function createComputeQueue(scope: Construct, computeQueueName: string, computeEnv: awsbatch.CfnComputeEnvironment) : awsbatch.CfnJobQueue {
    return new awsbatch.CfnJobQueue(scope, computeQueueName, {
        jobQueueName: computeQueueName,
        priority: 0,
        computeEnvironmentOrder: [
            {
                computeEnvironment: computeEnv.computeEnvironmentName,
                order: 0,
            }
        ]
    });
}
