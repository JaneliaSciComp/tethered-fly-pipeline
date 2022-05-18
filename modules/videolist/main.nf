include {
    create_container_options;
} from '../../lib/container_utils'

process CREATE_VIDEO_LIST {
    label 'low_cpu'
    label 'low_memory'
    container { params.apt_detect_container }
    containerOptions { create_container_options([
        fly_dirname
    ]) }

    input:
    tuple val(fly), val(fly_dirname)
    val(pattern)

    output:
    tuple val(fly), env(movies_list)

    script:
    def excluded_path = '! -path "*calib*"'
    """
    movies_list=`find "${fly_dirname}" -name "${pattern}" ${excluded_path} | sort`
    """    
}
