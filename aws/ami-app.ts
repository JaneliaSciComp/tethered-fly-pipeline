import { App, Stack, Tags } from 'aws-cdk-lib'
import { StringParameter } from 'aws-cdk-lib/aws-ssm';
import { AMIBuilderPipelineStack } from './ami-constructs';

const { AWS_REGION, AWS_ACCOUNT } = process.env;

const app = new App();

const amiBuilderStack = new AMIBuilderPipelineStack(app, 'AMIBuilder', {
    env: {
        account: AWS_ACCOUNT,
        region: AWS_REGION
    },
});

applyTags([amiBuilderStack]);

function applyTags(stacks: Stack[]) {
  stacks.forEach(s => {
    Tags.of(s).add('PROJECT', 'Huston');
    Tags.of(s).add('DEVELOPER', 'goinac');
    Tags.of(s).add('STAGE', 'dev');
    Tags.of(s).add('VERSION', '1.0.0');
  });
}
