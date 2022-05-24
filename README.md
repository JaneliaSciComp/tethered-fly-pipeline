# Tethered Fly Pipeline
Nextflow pipeline for processing tethered fly videos using APT

## Quick Start

The only software requirements for running this pipeline are [Nextflow](https://www.nextflow.io) (version 20.10.0 or greater) and [Singularity](https://sylabs.io) (version 3.5 or greater).

If you are running in an HPC cluster, ask your system administrator to install Singularity on all the cluster nodes.

To [install Nextflow](https://www.nextflow.io/docs/latest/getstarted.html):

```
    curl -s https://get.nextflow.io | bash 
```
Then add the next install directory to your PATH environment variable.

Nextflow versions >=22.04.0 require JDK-11 or newer, but you can also run this pipeline with an older version of Nextflow (20.10) by downloading the latest Nextflow with the command above and then setting the environment variable NXF_VER to the desired version to use, as bellow:
```
export NXF_VER=20.10.0
```

To [install Singularity](https://sylabs.io/guides/3.7/admin-guide/installation.html) on Oracle Linux:

```
    sudo yum install singularity
```

Last step before running the pipeline is to clone this repository:
```
    https://github.com/JaneliaSciComp/tethered-fly-pipeline.git
```

## Pipeline execution

You can run the pipeline on any Unix like system: Mac OSX, Linux or on Windows >= 10 using Windows System for Linux 2.0 (WSL2). On Mac you would typically run the pipeline using docker so you may also need to [install and setup docker](https://docs.docker.com/desktop/mac/install/)

### Run the pipeline locally with docker

To run the pipeline locally on a Mac, you need to use the localDocker profile and you may also need to tweak your Docker settings to have enough memory to be able to analyze the data, even if you only analyze a single video file.
```
./main.nf -profile localDocker <arguments>
```

### Run the pipeline locally on a Linux machine

On Linux you can simply run the pipeline with the standard profile:
```
./main.nf <arguments>
```

### Run the pipeline on Janelia's LSF cluster

To run the pipeline on Janelia's LSF cluster you submit the main job to the cluster and then the main job will take care of submitting all the other sub-tasks to the cluster.
```
export JAVA_HOME=/usr/lib/jvm/jre-17
LSF_PROJECT_CODE=clusterProjectCode

bsub -e jobErrorLog.err -o jobOutputLog.out -P ${LSF_PROJECT_CODE} \
nextflow run main.nf \
    -profile janeliaLSF \
    --lsf_opts "-P ${LSF_PROJECT_CODE}" \
    <arguments>
```

Again if you are using Nextflow version >= 22 make sure your JAVA_HOME environment variable references a JDK >= 11. On Janelia's cluster you can use:
```
export JAVA_HOME=/usr/lib/jvm/jre-17
```

You can see full examples with arguments in the [examples](./examples/) folder.

## User Manual

Further documentation is available here:

* [Pipeline Parameters](docs/Parameters.md)
* [Development](docs/Development.md)

