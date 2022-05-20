include {
    create_container_options;
} from '../../lib/container_utils'

process CREATE_VIDEO_LIST {
    label 'low_cpu'
    label 'low_memory'
    label 'use_local'
    container { params.apt_detect_container }
    containerOptions { create_container_options([
        [fly_dirname, 0],
    ]) }

    input:
    tuple val(fly), val(fly_dirname)
    val(video_name_pattern)

    output:
    tuple val(fly), env(movies_list)

    script:
    def excluded_path = '! -path "*calib*"'
    """
    movies_list=`find "${fly_dirname}" -name "${video_name_pattern}" ${excluded_path} | sort`
    """    
}
