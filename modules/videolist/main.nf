process CREATE_VIDEO_LIST {
    label 'low_cpu'
    label 'low_memory'
    label 'use_local'
    container 'public.ecr.aws/janeliascicomp/huston/apt_detect:1.1.0'

    input:
    tuple val(fly), path(fly_dir)
    val(video_name_pattern)
    path(collection_file)

    output:
    tuple val(fly), val(collection_file), env('movies_list')

    script:
    def excluded_path = '! -path "*calib*"'
    """
    full_fly_dir=\$(readlink ${fly_dir})
    full_collection_file=\$(readlink -m ${collection_file})
    movies_list=`find "\${full_fly_dir}" -name "${video_name_pattern}" ${excluded_path} | sort`
    echo "Create videolist: \${movies_list} -> \${full_collection_file} "
    mkdir -p "\$(dirname \${full_collection_file})"
    IFS=\$'\n' echo "\${movies_list}" > "\${full_collection_file}"
    """
}
