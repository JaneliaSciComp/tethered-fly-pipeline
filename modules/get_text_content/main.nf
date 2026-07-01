process GET_TEXT_CONTENT {
    label 'low_cpu'
    label 'low_memory'
    label 'use_local'
    container 'public.ecr.aws/janeliascicomp/huston/apt_detect:1.1.0'

    input:
    path(f)

    output:
    tuple val(f), stdout

    script:
    """
    if [[ -e ${f} ]]; then
        cat ${f}
    else
        echo "null"
    fi
    """
}
