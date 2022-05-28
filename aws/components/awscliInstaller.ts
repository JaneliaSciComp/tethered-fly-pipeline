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
            # Download and install miniconda
            - wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda-install.sh
            - bash miniconda-install.sh -b -f -p /opt/miniconda
            - rm miniconda-install.sh
      # Set miniconda path
      - name: SetMinicondaPath
        action: ExecuteBash
        inputs:
          commands:
            - |
              cat > /etc/profile.d/less.sh <<EOF
              export PATH=$PATH:/opt/miniconda/bin
              EOF
      # Install awscli
      - name: InstallAWSCLI
        action: ExecuteBash
        inputs:
          commands:
            - /opt/miniconda/bin/conda install -c conda-forge -y awscli
            - ln -s /opt/miniconda/bin/aws /usr/bin/aws
`
