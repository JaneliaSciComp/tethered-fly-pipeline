export interface AMIDeploymentOptions {
    mountedS3Bucket?: string
}

export function getAMIDeploymentOptions() : AMIDeploymentOptions {
    return {
        mountedS3Bucket: process.env.AMI_S3_BUCKET
    };
}
