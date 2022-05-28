export interface AMIDeploymentOptions {
    s3Bucket?: string;
    fsxVolume?: string;
}

export function getAMIDeploymentOptions() : AMIDeploymentOptions {
    return {
        s3Bucket: process.env.AMI_S3_BUCKET,
        fsxVolume: process.env.AMI_FSX_VOLUME,
    };
}
