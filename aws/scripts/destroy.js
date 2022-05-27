const execSync = require("child_process").execSync;
const chalk = require("chalk");
const dotenv = require("dotenv");
const prompts = require('prompts')

const exec = (command, options = {}) => {
    const combinedOptions = { stdio: [0, 1, 2], ...options };
    execSync(command, combinedOptions);
};

async function removeImageBuilder() {

    // remove the AMIBuilder
    console.log(chalk.cyan("🚚 Removing AMI stack"));
    exec(`npm run cdk -- destroy --all --require-approval never`, {
        cwd: ".",
    });

}

// set env from .env file if present
dotenv.config();


(async () => {
    const response = await prompts({
        type: 'confirm',
        name: 'confirm',
        message: 'Do you wish to continue?',
        initial: false
    });

    if (response.confirm) {
        removeImageBuilder();
    } else {
        console.log(chalk.red("🚨 stack removal aborted"));
        process.exit(0);
    }
})();
