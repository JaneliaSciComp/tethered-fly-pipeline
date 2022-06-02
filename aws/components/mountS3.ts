export const mountS3 = `
name: MountS3
description: this document mounts an s3 bucket on an AMI
schemaVersion: 1.0
parameters:
  - BucketName:
      type: string
      description: BucketName to be mounted.
  - S3BaseMountedDir
      type: string
      default: /fusion/s3
      description: Parent directory where the S3 bucket will get mounted
phases:
  - name: build
    steps:
      - name: MountS3Bucket
        action: ExecuteBash
        inputs:
          commands:
            - mkdir -p {{S3BaseMountedDir}}/{{BucketName}}
            - echo -e "{{BucketName}}\\t{{S3BaseMountedDir}}/{{BucketName}}\\tfuse.s3fs\\trw,_netdev,iam_role=auto,allow_other,umask=0000\\t0\\t0" | tee -a /etc/fstab
            - mount -t fuse.s3fs {{S3BaseMountedDir}}/{{BucketName}}
`
