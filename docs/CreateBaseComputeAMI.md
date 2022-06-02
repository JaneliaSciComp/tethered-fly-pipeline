# Creating Base Compute AMI for AWS

[aws](../aws/) folder contains a CDK script that could be used to create a GPU ECS optimized image that will have some tools installed in order to speed up a little bit the creation of EC2 instances for AWS batch.

## Requirements for running the script

The script requires node and npm installed on the machine as well as AWS CLI

## Preparing and running the script.

* Install node packages
You install packages from the 'aws' sub-directory 
    ` npm install`
or from the top cloned directory using
    `npm install --prefix aws`
* Copy 'env.template' from 'aws' sub-directory to '.env' (in the same directory) and then update AWS account number and AWS region in the .env file - do not modify 'env.template file'. Addionally you can set an S3 bucket and/or an FSX volume to be automatically mounted in the EC2 image.

From 'aws' dir:
    `cp env.template .env`
Or from top directory
    `cp aws/env.template aws/.env`

* Run CDK script
From 'aws' dir:
    `npm run deploy -- -d -c`
Or from top directory
    `npm run --prefix aws deploy -- -d -c`

    '-d' - deploy the CDK stack - this flag creates an EC2 builder pipeline that you can later run to actually create the AMI. This flag is required the first time you the script in order to create the EC2 builder pipeline. Once the builder pipeline is available you can create an AMI either from the AWS console or using '-c' flag

* If the stack is already deployed you can create another image using:
    `npm run deploy -- -c`
or
    `npm run --prefix aws deploy -- -c`
depending on where you run the command from: 'aws' or top level directory, respectively.


# Removing the AMIBuilder stack

To remove the stack run (again depending on where you are)
    `npm run destroy`
or
    `npm run --prefix aws destroy`
Keep in mind that removing the stack will not remove pipelines or AMIs already created.
