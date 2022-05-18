include {
    create_container_options;
} from '../../lib/container_utils'

process DETECT_FEATURES_FOR_VIEW_MOVIES {
    label 'use_gpu'
    container { params.apt_detect_container }
    containerOptions { create_container_options([
        file(viewlist_filename).parent,
        file(output_dirname).parent.parent,
        params.model_cache_dirname,
        file(params.body_axis_lookup_filename).parent,
        file(params.label_filename).parent
    ]) }
    cpus { params.apt_detect_cpus }
    memory { params.apt_detect_memory }

    input:
    tuple val(viewlist_filename), val(output_dirname)
    tuple val(view_type), val(view_crop_size)

    output:
    tuple val(viewlist_filename), val(output_dirname)

    script:
    """
    cd /code/apt/deepnet
    python classify_single_view.py \
        -viewfile ${viewlist_filename} \
        -view ${view_type} \
        -bodylabelfilename ${params.body_axis_lookup_filename} \
        -lbl_file ${params.label_filename} \
        -crop_reg_file ${params.crop_regression_filename} \
        -view_crop_size "${view_crop_size}" \
        -cache_dir "${params.model_cache_dirname}" \
        -n "${params.model_name}" \
        -o "${output_dirname}"
    """    
}
