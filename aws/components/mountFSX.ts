export const mountFSX = `
name: MountFSX
description: this document mounts an FSX on an AMI
schemaVersion: 1.0
parameters:
  - FSXVolume:
      type: string
      description: FSX volume to be mounted.
  - FSXMountedDir:
      type: string
      default: /fsx
      description: Mounted directory for FSX volume
phases:
  - name: build
    steps:
      - name: FSSXMount
        action: ExecuteBash
        inputs:
          commands:
            - mkdir -p {{FSXMountedDir}}
            - echo -e '{{FSXVolume}}\\t{{FSXMountedDir}}\\tlustre\\trw,_netdev,noatime,flock\\t0\\t0' | sudo tee -a /etc/fstab
            - mount -t lustre {{FSXMountedDir}}
            - chown ec2-user:ec2-user {{FSXMountedDir}}
`
