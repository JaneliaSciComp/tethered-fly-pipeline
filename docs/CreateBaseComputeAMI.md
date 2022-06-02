# Creating Base Compute AMI for AWS

[aws](../aws/) folder contains a CDK script that could be used to create a GPU ECS optimized image that will have some tools installed in order to speed up a little bit the creation of EC2 instances for AWS batch.

## Requirements for running the script

The script requires node and npm installed on the machine as well as AWS CLI

## Preparing and running the script.

* Install node packages
    ` npm install`
* Copy 'env.template' to '.env' and then update AWS account number and AWS region in the .env file - do not modify 'env.template file'. Addionally you can set an S3 bucket and/or an FSX module to be automatically in the AMI
    `cp env.template .env`
* Run CDK script
    `npm run deploy -- -d -c`

    '-d' - deploy the CDK stack - this flag creates an EC2 builder pipeline that you can later run to actually create the AMI. This flag is required the first time you the script in order to create the EC2 builder pipeline. Once the builder pipeline is available you can create an AMI either from the AWS console or using '-c' flag

