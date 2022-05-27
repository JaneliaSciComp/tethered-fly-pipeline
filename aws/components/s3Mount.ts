export const s3Mount =`
name: S3Mount
description: this document mounts an s3 bucket on an AMI
schemaVersion: 1.0

parameters:
  - BucketName:
      type: string
      description: BucketName to be mounted.
phases:
    - name: build
      steps:
        - name: S3Mount
          action: ExecuteBash
          inputs:
            commands:
              - sudo mkdir -p /fusion/s3/{{BucketName}}
              - echo -e "{{BucketName}}\t/fusion/s3/{{BucketName}}\tfuse.s3fs\t_netdev,iam_role=auto,allow_other,umask=0000\t0\t0" | tee -a /etc/fstab
`
