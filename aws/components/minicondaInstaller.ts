export const minicondaInstaller =`
name: MinicondaInstaller
description: this document installs Miniconda on Amazon Linux 2
schemaVersion: 1.0

phases:
    - name: build
      steps:
        - name: InstallMiniconda
          action: ExecuteBash
          inputs:
            commands:
                - wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
                - bash Miniconda3-latest-Linux-x86_64.sh -b -f -p $HOME/miniconda
                - $HOME/miniconda/bin/conda install -c conda-forge -y awscli
                - rm Miniconda3-latest-Linux-x86_64.sh
`
