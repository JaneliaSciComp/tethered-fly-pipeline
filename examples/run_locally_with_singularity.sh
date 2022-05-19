#!/bin/bash

PROFILE="-profile standard"

JAVA_HOME=$HOME/tools/jdk-17 \
TMPDIR=/data/tmp \
nextflow main.nf \
    $PROFILE \
    --i /nrs/scicompsoft/goinac/huston/data \
    --o /nrs/scicompsoft/goinac/huston/results \
    --tmp_tracking_dir /nrs/scicompsoft/goinac/huston/tmp_tracking_result \
    --flydata_dirname_pattern fly4315 \
    --body_axis_lookup_filename /groups/huston/hustonlab/flp-chrimson_experiments/fly2BodyAxis_lookupTable_Ben.csv \
    --label_filename /groups/branson/bransonlab/apt/experiments/data/sh_trn5017_20200121_stripped.lbl \
    --crop_regression_filename /groups/branson/bransonlab/mayank/stephen_copy/crop_regression_params.mat \
    --model_cache_dirname /groups/branson/bransonlab/mayank/stephen_copy/apt_cache \
    --model_name stephen_20200124 \
    --calibrations_filename /groups/huston/hustonlab/flp-chrimson_experiments/fly2DLT_lookupTableStephen.csv \
    $*

