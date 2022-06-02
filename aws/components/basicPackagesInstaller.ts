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
            - amazon-linux-extras install -y epel lustre2.10
            - yum install -y yum-utils
            - yum install -y fuse s3fs-fuse nfs-utils
            - yum install -y jq sed bzip2 wget unzip
      - name: InstallCloudWatch
        action: ExecuteBash
        inputs:
          commands:
            - wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
            - rpm -U ./amazon-cloudwatch-agent.rpm
            - rm -f ./amazon-cloudwatch-agent.rpm
      - name: CreateSSMUser
        action: ExecuteBash
        inputs:
          commands:
            - useradd -d /home/ssm-user -s /bin/bash ssm-user
            - usermod -aG docker ssm-user
            - echo "ssm-user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ssm-agent-users
`
