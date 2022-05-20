#!/bin/bash

export JAVA_HOME=/usr/lib/jvm/jre-17

PROFILE="-profile janeliaLSF"
LSF_PROJECT_CODE=huston

DATA_DIR=/groups/huston/hustonlab/flp-chrimson_experiments/fly_4315_to_4320_tdtKir
RESULTS_DIR=/groups/huston/hustonlab/flp-chrimson_experiments/fly_4315_to_4320_tdtKir/apt_results
INTERMEDIATE_RESULTS_DIR=/groups/huston/hustonlab/flp-chrimson_experiments/tempTrackingOutput

bsub -e fly_4315_to_4320.err -o fly_4315_to_4320.out -J fly_4315_to_4320 -P ${LSF_PROJECT_CODE} \
nextflow main.nf \
    $PROFILE \
    --lsf_opts "-P ${LSF_PROJECT_CODE}" \
    --i ${DATA_DIR} \
    --o ${RESULTS_DIR} \
    --tmp_tracking_dir ${INTERMEDIATE_RESULTS_DIR} \
    --body_axis_lookup_filename /groups/huston/hustonlab/flp-chrimson_experiments/fly2BodyAxis_lookupTable_Ben.csv \
    --label_filename /groups/branson/bransonlab/apt/experiments/data/sh_trn5017_20200121_stripped.lbl \
    --crop_regression_filename /groups/branson/bransonlab/mayank/stephen_copy/crop_regression_params.mat \
    --model_cache_dirname /groups/branson/bransonlab/mayank/stephen_copy/apt_cache \
    --model_name stephen_20200124 \
    --calibrations_filename /groups/huston/hustonlab/flp-chrimson_experiments/fly2DLT_lookupTableStephen.csv \
    $*

