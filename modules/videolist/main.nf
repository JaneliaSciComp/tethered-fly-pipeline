include {
    create_container_options;
} from '../../lib/container_utils'

process CREATE_VIDEO_LIST {
    label 'low_cpu'
    label 'low_memory'
    container { params.apt_detect_container }
    containerOptions { create_container_options([
        fly_dirname,
        file(viewlist_filename).parent.parent
    ]) }

    input:
    tuple val(fly_dirname), val(viewlist_filename)
    val(pattern)

    output:
    tuple val(fly_dirname), val(viewlist_filename)

    script:
    def excluded_path = '! -path "*calib*"'
    def viewlist_file = file(viewlist_filename)
    def viewlist_parent_dir = viewlist_file.parent
    """
    mkdir -p "${viewlist_parent_dir}"
    find "${fly_dirname}" -name "${pattern}" ${excluded_path} | sort > ${viewlist_file}
    """    
}
