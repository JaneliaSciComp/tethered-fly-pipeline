#!/usr/bin/env nextflow

include {
    apt_pipeline;
} from './workflows/apt_pipeline'

workflow {
    def input_dir         = channel.of(input_dir_param(params))
    def output_dir        = channel.of(output_dir_param(params))
    def temp_tracking_dir = channel.of(temp_tracking_dir_param(params))

    apt_pipeline(input_dir, output_dir, temp_tracking_dir) | view
}

def input_dir_param(Map ps) {
    def input_dir = ps.input_dir
    if (!input_dir) {
        input_dir = ps.i
    }
    def dir = file(input_dir)
    return "${dir}"
}

def output_dir_param(Map ps) {
    def output_dir = ps.output_dir
    if (!output_dir) {
        output_dir = ps.o
    }
    def dir = file(output_dir)
    return "${dir}"
}

def temp_tracking_dir_param(Map ps) {
    def dir = file(ps.tmp_tracking_dir)
    return "${dir}"
}
