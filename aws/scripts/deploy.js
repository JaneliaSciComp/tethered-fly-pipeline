const execSync = require("child_process").execSync;
const chalk = require("chalk");
const dotenv = require("dotenv");

const exec = (command, options = {}) => {
    const combinedOptions = { stdio: [0, 1, 2], ...options };
    execSync(command, combinedOptions);
};

async function deployImageBuilder() {

    // deploy the AMIBuilder
    console.log(chalk.cyan("🚚 Deploying AMI stack"));
    exec(`npm run cdk -- deploy AMIBuilder --require-approval never`, {
        cwd: ".",
    });

}

async function createAMI() {

}

// set env from .env file if present
dotenv.config();


(async () => {

    deployImageBuilder();

})();
