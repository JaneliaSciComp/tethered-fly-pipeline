#!/usr/bin/env nextflow

include {
    input_dir_param;
    output_dir_param;
    scratch_dir_param;
    temp_tracking_dir_param;
} from './lib/param_utils'

include {
    apt_pipeline;
} from './workflows/apt_pipeline'

workflow {
    def input_dir         = channel.of(input_dir_param(params))
    def output_dir        = channel.of(output_dir_param(params))
    def temp_tracking_dir = channel.of(temp_tracking_dir_param(params))

    apt_pipeline(input_dir, output_dir, temp_tracking_dir) | view
}
