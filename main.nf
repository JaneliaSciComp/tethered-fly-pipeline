#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include {
    default_params;
    apt_detect_container_param;
    input_dir_param;
    output_dir_param;
    temp_tracking_dir_param;
} from './lib/param_utils'

main_params = default_params() + params
process_params = main_params +
    [
        apt_detect_container: apt_detect_container_param(main_params),
        input_dir: input_dir_param(main_params),
        output_dir: output_dir_param(main_params),
        temp_tracking_dir: temp_tracking_dir_param(main_params),
    ]

include {
    apt_pipeline;
} from './workflows/apt_pipeline' addParams(process_params)


input_dir = Channel.of(process_params.input_dir) // flies parent dir
output_dir = Channel.of(process_params.output_dir)
temp_tracking_dir = Channel.of(process_params.temp_tracking_dir)

workflow {
    res = apt_pipeline(input_dir, output_dir, temp_tracking_dir)

    res | view
}
