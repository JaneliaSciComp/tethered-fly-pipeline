# Development

If you are new to developing with this project, the following hints may be useful:

## Editing parameter schema

The `nextflow_schema.json` file contains the list of parameters and their documentation, and is used to automatically generate the Nextflow Tower UI for this pipeline. If you want to change the parameters or their docs, use the [nf-core schema builder](https://nf-co.re/pipeline_schema_builder). Copy and paste the contents of the [nextflow_schema.json](../nextflow_schema.json) file into the tool to begin editing, and copy it back when you are done. Don't forget to update the parameter docs, as described below.

## Generating parameter docs

To generate the Parameters documentation from the Nextflow schema, first [install nf-core tools](https://nf-co.re/usage/installation), and then:

    nf-core schema docs -o docs/Parameters.md -f -c parameter,description,type

## Building containers

All containers used by the pipeline have been made available on Docker Hub and AWS ECR. You can rebuild these to make customizations or to replace the algorithms used. To build the containers and push to Docker Hub, install [maru](https://github.com/JaneliaSciComp/maru) and run `maru build`.

## Publishing containers

To push to Docker Hub, you need to login first:

    docker login

To push to AWS ECR, you need to login as follows:

    aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
