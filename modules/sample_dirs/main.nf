include {
    create_container_options;
} from '../../lib/container_utils'

process GET_SAMPLE_DIRS {
    label 'low_cpu'
    label 'low_memory'
    label 'use_local'
    container { params.apt_detect_container }
    containerOptions { create_container_options([
        [data_dirname, 0],
    ]) }

    input:
    val(data_dirname)

    output:
    env(fly_dirs)

    script:
    """
    fly_dirs=`find "${data_dirname}" -regex ".*/${params.flydata_dirname_pattern}"`
    """    
}
