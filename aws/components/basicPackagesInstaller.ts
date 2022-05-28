export const basicPackagesInstaller = `
name: BasicPackagesInstaller
description: this document installs basic packages on Amazon Linux 2
schemaVersion: 1.0
phases:
  - name: build
    steps:
      - name: InstallYumPackages
        action: ExecuteBash
        inputs:
          commands:
            - yum update -y
            - amazon-linux-extras install -y epel
            - yum install -y yum-utils
            - yum install -y fuse s3fs-fuse nfs-utils
            - yum install -y jq sed bzip2 wget unzip
            # install cloudwatch agent
            - wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
            - rpm -U ./amazon-cloudwatch-agent.rpm
            - rm -f ./amazon-cloudwatch-agent.rpm
            # create ssm-user
            - useradd -d /home/ssm-user -s /bin/bash ssm-user
            - usermod -aG docker ssm-user
            - echo "ssm-user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ssm-agent-users
            # create hosts entry
            - echo -e '10.36.13.15 nextflow nextflow.int.janelia.org c13u05 c13u05.int.janelia.org' | tee -a /etc/hosts
`
