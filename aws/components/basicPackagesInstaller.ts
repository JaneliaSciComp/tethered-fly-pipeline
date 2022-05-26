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
                - sudo yum update -y
                - sudo amazon-linux-extras install -y epel
                - sudo yum install -y yum-utils pciutils wget fuse s3fs-fuse bzip2 nfs-utils
`