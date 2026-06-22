process CREATE_VIDEO_LIST {
    label 'low_cpu'
    label 'low_memory'
    label 'use_local'
    container { params.apt_detect_container }

    input:
    tuple val(fly), path(fly_dir)
    val(video_name_pattern)
    val(collection_filename)

    output:
    tuple val(fly), val(collection_file), env('movies_list')

    script:
    def excluded_path = '! -path "*calib*"'
    collection_file = file(collection_filename)
    """
    full_fly_dir=\$(readlink ${fly_dir})
    movies_list=`find "\${full_fly_dir}" -name "${video_name_pattern}" ${excluded_path} | sort`
    echo "Create videolist: \${movies_list} -> ${collection_file} "
    mkdir -p "${collection_file.parent}"
    IFS=\$'\n' echo "\${movies_list}" > "${collection_file}"
    """
}
