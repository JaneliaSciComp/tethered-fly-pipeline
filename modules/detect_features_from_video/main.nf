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
          path(scratch_dir),
          path(data_dirs)
    val(view_type)
    val(view_crop_size)
    val(force_detect)

    output:
    tuple val(flyname), env('full_video_filepath'), env('full_output_dir'), val(expected_output_name)

    script:
    def args = task.ext.args ?: ''
    def check_block = ''
    if (!force_detect) {
        check_block = """
        if [[ -f "${output_dirname}/${expected_output_name}" ]]; then
            echo "Feature detect result ${output_dirname}/${expected_output_name} already exists"
            SKIP_DETECT=1
        fi
        """
    }

    def force_detect_flag = force_detect ? '-r' : ''
    def scratch_dir_arg = scratch_dir 
        ? "-tmp_outdir \$(readlink ${scratch_dir})"
        : ''
    """
    umask 0002

    full_output_dir=\$(readlink -m ${output_dirname})
    full_video_filepath=\$(readlink ${video_filename})
    full_body_axis_lookup_filepath=\$(readlink ${body_axis_lookup_file})
    full_label_filepath=\$(readlink ${label_file})
    full_crop_regression_filepath=\$(readlink ${crop_regression_file})
    full_model_cache_dirpath=\$(readlink ${model_cache_dir})

    ${check_block}

    if [[ ! -v SKIP_DETECT ]]; then
        mkdir -p "\${full_output_dir}"
        echo "Created output dir: \${full_output_dir}"

        cd /code/apt/deepnet

        CMD=(
            python detect_features_from_movies.py
            -movies \${full_video_filepath}
            -view ${view_type}
            ${force_detect_flag}
            -bodylabelfilename \${full_body_axis_lookup_filepath}
            -lbl_file \${full_label_filepath}
            -crop_reg_file \${full_crop_regression_filepath}
            -view_crop_size "${view_crop_size}"
            -cache_dir "\${full_model_cache_dirpath}"
            ${scratch_dir_arg}
            -n "${model_name}"
            -o "\${full_output_dir}"
            ${args}
        )
        echo "CMD: \${CMD[@]}"
        (exec "\${CMD[@]}")
    fi
    """    
}
