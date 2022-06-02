export const awscliInstaller = `
name: AWSCLIInstaller
description: this document installs AWS CLI
schemaVersion: 1.0
phases:
  - name: build
    steps:
      - name: InstallMiniconda
        action: ExecuteBash
        inputs:
          commands:
            # Download and install miniconda in ec2-user's home dir
            - wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda-install.sh
            - mkdir -p /home/ec2-user
            - bash miniconda-install.sh -b -f -p /home/ec2-user/miniconda
            - rm miniconda-install.sh
      # Install awscli
      - name: InstallAWSCLI
        action: ExecuteBash
        inputs:
          commands:
            - /home/ec2-user/miniconda/bin/conda install -c conda-forge -y awscli
`
