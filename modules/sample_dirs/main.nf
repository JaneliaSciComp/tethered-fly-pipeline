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
    def maxdepth_arg = params.flydata_maxdepth_search > 0
        ? "-maxdepth ${params.flydata_maxdepth_search}"
        : ""
    """
    fly_dirs=`find ${data_dirname} ${maxdepth_arg} -regex ".*/${params.flydata_dirname_pattern}"`
    if [[ -z \${fly_dirs} ]] ; then
        fly_dirs=null
    fi
    """    
}
