process CREATE_VIDEO_LIST {
    label 'low_cpu'
    label 'low_memory'

    input:
    val(data_path)
    val(pattern)
    val(video_list_path)

    output:
    val(data_path)
    val(video_list_path)

    script:
    def excluded_path = '! -path "*calib*"'
    def video_list_file = file(video_list_path)
    def video_list_parent_dir = video_list_file.parent
    """
    find "${data_path}" -name "${pattern}" ${excluded_path} | sort > ${video_list_path}
    """    
}