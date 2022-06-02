export interface AMIDeploymentOptions {
    s3Bucket?: string;
    fsxVolume?: string;
    etcHostsEntry?: string;
}

export function getAMIDeploymentOptions() : AMIDeploymentOptions {
    return {
        s3Bucket: process.env.AMI_S3_BUCKET,
        fsxVolume: process.env.AMI_FSX_VOLUME,
        etcHostsEntry: process.env.ETC_HOSTS_ENTRY,
    };
}
