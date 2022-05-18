#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include {
    default_params;
    apt_detect_container_param;
    input_dir_param;
    output_dir_param;
} from './lib/param_utils'

main_params = default_params() + params
process_params = main_params +
    [
        apt_detect_container: apt_detect_container_param(main_params),
        input_dir: input_dir_param(main_params),
        output_dir: output_dir_param(main_params),
    ]

include {
    track_pipeline;
} from './workflows/track_pipeline' addParams(process_params)


input_dir = Channel.of(process_params.input_dir) // flies parent dir
output_dir = Channel.of(process_params.output_dir)

workflow {
    res = track_pipeline(input_dir, output_dir)

    res | view
}
