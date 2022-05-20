include {
    create_container_options;
} from '../../lib/container_utils'

process GET_TEXT_CONTENT {
    label 'low_cpu'
    label 'low_memory'
    label 'use_local'
    container { params.apt_detect_container }
    containerOptions { create_container_options([
        [f, 1],
    ]) }

    input:
    val(f)

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
