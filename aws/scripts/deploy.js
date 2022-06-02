const execSync = require('child_process').execSync;
const chalk = require('chalk');
const dotenv = require('dotenv');
const { CloudFormation, Imagebuilder } = require('aws-sdk')
const exec = (command, options = {}) => {
    const combinedOptions = { stdio: [0, 1, 2], ...options };
    execSync(command, combinedOptions);
};

async function deployImageBuilder() {

    // deploy the AMIBuilder
    console.log(chalk.cyan('🚚 Deploying AMI stack'));
    exec(`npm run cdk -- deploy AMIBuilder --require-approval never`, {
        cwd: '.',
    });

}

async function getImageBuilderPipeline() {
    // get stack info
    const cloudformation = new CloudFormation({ AWS_REGION });
    const amiBuilderStack = await cloudformation
        .describeStacks({
            StackName: 'AMIBuilder',
        })
        .promise();

    const outputs = {};
    // dump the outputs into a simple object
    amiBuilderStack.Stacks[0].Outputs.forEach(({ OutputKey, OutputValue }) => {
        outputs[OutputKey] = OutputValue;
    });

    console.log('AMI Builder Stack outputs:', outputs);

    return outputs['AMIPipelineARN'];
}

async function createAMI() {
    const imagebuilder = new Imagebuilder();
    const pipelineArn = await getImageBuilderPipeline();

    console.log(chalk.cyan(`🚚 Start AMI pipeline: ${pipelineArn}`));
    return await imagebuilder.startImagePipelineExecution({
        imagePipelineArn: pipelineArn,
    }).promise();
}

function checkEnv() {
    console.log(chalk.cyan("🔎 Checking environment."));

    const expectedEnvVars = [
        "AWS_ACCOUNT",
        "AWS_REGION",
    ];

    let missingVarsCount = 0;

    expectedEnvVars.forEach((envVar) => {
        if (!process.env[envVar]) {
            console.log(chalk.red(`🚨 Environment variable ${envVar} was not set.`));
            missingVarsCount += 1;
        }
    });

    if (missingVarsCount > 0) {
        process.exit(1);
    }

    console.log(chalk.green("✅ environment looks good."));
}

// set env from .env file if present
dotenv.config();
const { AWS_REGION } = process.env;

const argv = require('yargs/yargs')(process.argv.slice(2))
    .usage('$0 [options]')
    .option('d', {
        alias: 'deploy',
        type: 'boolean',
        describe: 'Deploy the AMI builder stack',
    })
    .option('c', {
        alias: 'create-ami',
        type: 'boolean',
        describe: 'Run the AMI builder pipeline and create an AMI instance',
    })
    .argv;


(async () => {

    checkEnv();
    if (argv.deploy) {
        deployImageBuilder();
    }
    if (argv.createAmi) {
        createAMI();
    }

})();
