include {
    create_container_options;
} from '../../lib/container_utils'

process DETECT_FEATURES_FROM_VIDEO {
    label 'withGPU'
    container 'public.ecr.aws/janeliascicomp/huston/apt_detect:1.1.0'

    input:
    tuple val(flyname),
          path(video_filename),
          path(output_dirname),
          val(expected_output_name)
    tuple path(model_cache_dir),
          val(model_name),
          path(body_axis_lookup_file),
          path(label_file),
          path(crop_regression_file),
          path(scratch_dir)
    val(view_type)
    val(view_crop_size)
    val(force_detect)

    output:
    tuple val(flyname), val(video_filename), val(output_dirname), val(expected_output_name)

    script:
    def check_block = ''
    if (!force_detect) {
        check_block = """
        if [[ -f "${output_dirname}/${expected_output_name}" ]]; then
            echo "Feature detect result ${output_dirname}/${expected_output_name} already exists"
            exit 0
        fi
        """
    }

    def force_detect_flag = force_detect ? '-r' : ''
    def scratch_dir_arg = scratch_dir 
        ? "-tmp_outdir ${scratch_dir}"
        : ''
    """
    ${check_block}
    umask 0002

    mkdir -p "${output_dirname}"
    echo "Created output dir: ${output_dirname}"

    cd /code/apt/deepnet

    python detect_features_from_movies.py \
        -movies ${video_filename} \
        -view ${view_type} \
        ${force_detect_flag} \
        -bodylabelfilename ${body_axis_lookup_file} \
        -lbl_file ${label_file} \
        -crop_reg_file ${crop_regression_file} \
        -view_crop_size "${view_crop_size}" \
        -cache_dir "${model_cache_dir}" \
        ${scratch_dir_arg} \
        -n "${model_name}" \
        -o "${output_dirname}"
    """    
}
