include {
    create_container_options;
} from '../../lib/container_utils'

process DETECT_FEATURES_FROM_MOVIE {
    label 'use_gpu'
    container { params.apt_detect_container }
    containerOptions { create_container_options([
        [movie_filename, 1],
        [output_dirname, 3],
        [params.model_cache_dirname, 0],
        [params.body_axis_lookup_filename, 1],
        [params.label_filename, 1],
        [params.crop_regression_filename, 1],
    ]) }
    cpus { params.apt_detect_cpus }
    memory { params.apt_detect_memory }

    input:
    tuple val(flyname), val(movie_filename), val(output_dirname), val(expected_output_name)
    val(view_type)
    val(view_crop_size)

    output:
    tuple val(flyname), val(movie_filename), val(output_dirname), val(expected_output_name)

    script:
    def check_block = ''
    if (!params.force_detect) {
        check_block = """
        if [[ -f "${output_dirname}/${expected_output_name}" ]]; then
            echo "Feature detect result ${output_dirname}/${expected_output_name} already exists"
            exit 0
        fi
        """
    }

    def force_detect_flag = params.force_detect ? '-r' : ''

    """
    ${check_block}
    umask 0002

    mkdir -p "${output_dirname}"

    cd /code/apt/deepnet
    python detect_features_from_movies.py \
        -movies ${movie_filename} \
        -view ${view_type} \
        ${force_detect_flag} \
        -bodylabelfilename ${params.body_axis_lookup_filename} \
        -lbl_file ${params.label_filename} \
        -crop_reg_file ${params.crop_regression_filename} \
        -view_crop_size "${view_crop_size}" \
        -cache_dir "${params.model_cache_dirname}" \
        -n "${params.model_name}" \
        -o "${output_dirname}"
    """    
}
