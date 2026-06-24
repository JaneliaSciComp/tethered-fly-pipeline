process GET_SAMPLE_DIRS {
    label 'low_cpu'
    label 'low_memory'
    label 'use_local'
    container 'public.ecr.aws/janeliascicomp/huston/apt_detect:1.1.0'

    input:
    path(data_dir)

    output:
    env('fly_dirs')

    script:
    def maxdepth_arg = params.flydata_maxdepth_search > 0
        ? "-maxdepth ${params.flydata_maxdepth_search}"
        : ""
    """
    full_data_dir=\$(readlink ${data_dir})
    fly_dirs=`find \${full_data_dir} ${maxdepth_arg} -regex ".*/${params.flydata_dirname_pattern}"`
    if [[ -z \${fly_dirs} ]] ; then
        fly_dirs=null
    fi
    """    
}
