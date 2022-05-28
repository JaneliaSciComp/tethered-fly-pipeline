export const mountFSX = `
name: MountFSX
description: this document mounts an FSX on an AMI
schemaVersion: 1.0
parameters:
  - FSXVolume:
      type: string
      description: FSX volume to be mounted.
phases:
  - name: build
    steps:
      - name: FSSXMount
        action: ExecuteBash
        inputs:
          commands:
            - amazon-linux-extras install -y lustre2.10
            - mkdir -p /fsx
            - echo -e '{{FSXVolume}}\\t/fsx\\tlustre\\trw,_netdev,noatime,flock\\t0\\t0' | sudo tee -a /etc/fstab
            - mount -t lustre /fsx
            - chown ec2-user:ec2-user /fsx
`
