# Tethered Fly Pipeline

Nextflow pipeline for processing tethered fly videos using [Animal Part Tracker (APT)](https://github.com/kristinbranson/APT).

## Quick Start

The easiest way to use the EASI-FISH pipeline is by running it from the Nextflow Tower web GUI interface. See the step-by-step [instructions for running on tower.nf](docs/NextflowTowerAWS.md) or use the [Janelia instance](docs/NextflowTowerJanelia.md) if you are on Janelia's network.

For tech-savvy users, the pipeline can be invoked from the command-line and runs on any workstation or cluster. The only software requirements for running this pipeline are [Nextflow](https://www.nextflow.io) (version 20.10.0 or greater) and [Singularity](https://sylabs.io) (version 3.5 or greater).

If you are running on an HPC cluster, ask your system administrator to install Singularity on all the cluster nodes.

To [install Nextflow](https://www.nextflow.io/docs/latest/getstarted.html) simply do this:

```bash
curl -s https://get.nextflow.io | bash 
```

Then add the Nextflow install directory to your PATH environment variable, e.g.:

```bash
mv nextflow bin/ 
echo 'export PATH=$PATH:/$HOME/bin' >> .bashrc
```

Nextflow versions >=22.04.0 require JDK-11 or newer, but you can also run this pipeline with an older version of Nextflow (20.10) by downloading the latest Nextflow with the command above and then setting the environment variable NXF_VER to the desired version to use, as bellow:

```bash
export NXF_VER=20.10.0
```

To [install Singularity](https://sylabs.io/guides/3.7/admin-guide/installation.html) on Oracle Linux:

```bash
sudo yum install singularity
```

Last step before running the pipeline is to clone this repository:

```bash
git clone git@github.com:JaneliaSciComp/tethered-fly-pipeline.git
```

## Pipeline execution

You can run the pipeline on any Unix like system: Mac OSX, Linux or on Windows >= 10 using Windows System for Linux 2.0 (WSL2). On Mac you would typically run the pipeline using docker so you may also need to [install and setup docker](https://docs.docker.com/desktop/mac/install/)

### Run the pipeline locally with docker

To run the pipeline locally on a Mac, you need to use the localDocker profile and you may also need to tweak your Docker settings to have enough memory to be able to analyze the data, even if you only analyze a single video file.

```bash
./main.nf -profile localDocker <arguments>
```

### Run the pipeline locally on a Linux machine

On Linux you can simply run the pipeline with the standard profile:

```bash
./main.nf <arguments>
```

### Run the pipeline on Janelia's LSF cluster

To run the pipeline on Janelia's LSF cluster you submit the main job to the cluster and then the main job will take care of submitting all the other sub-tasks to the cluster.

```bash
export JAVA_HOME=/usr/lib/jvm/jre-17
LSF_PROJECT_CODE=clusterProjectCode

bsub -e jobErrorLog.err -o jobOutputLog.out \
    -P ${LSF_PROJECT_CODE} \
    nextflow run main.nf \
        -profile janeliaLSF \
        --lsf_opts "-P ${LSF_PROJECT_CODE}" \
        <arguments>
```

Again if you are using Nextflow version >= 22 make sure your JAVA_HOME environment variable references a JDK >= 11. On Janelia's cluster you can use:

```bash
export JAVA_HOME=/usr/lib/jvm/jre-17
```

You can see full examples with arguments in the [examples](./examples/) folder.

## User Manual

Further documentation is available here:

* [Pipeline Parameters](docs/Parameters.md)
* [Development](docs/Development.md)

