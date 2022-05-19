include {
    create_container_options;
} from '../../lib/container_utils'

process TRACE_TRAJECTORY {
    container { params.apt_track_container }
    containerOptions { create_container_options([
        file(side_features_filename).parent,
        file(front_features_filename).parent,
        file(kinemat_filename).parent,
        file(three_d_res_filename).parent.parent.parent,
        file(side_trk_filename).parent.parent.parent,
        file(front_trk_filename).parent.parent.parent,
    ]) }
    cpus { params.apt_track_cpus }
    memory { params.apt_track_memory }
    errorStrategy { params.error_strategy }

    input:
    tuple val(flyname),
          val(side_features_filename),
          val(front_features_filename),
          val(kinemat_filename),
          val(three_d_res_filename),
          val(side_trk_filename),
          val(front_trk_filename)

    output:
    tuple val(flyname),
          val(three_d_res_filename),
          val(side_trk_filename),
          val(front_trk_filename)

    script:
    def three_d_res_dir = file(three_d_res_filename).parent
    def side_trk_dir = file(side_trk_filename).parent
    def front_trk_dir = file(front_trk_filename).parent
    def check_block = ''
    if (!params.force_track) {
        check_block = """
        if [[ -f "${front_trk_filename}" && -f "${side_trk_filename}" ]]; then
            echo "Trace files ${front_trk_filename} and ${side_trk_filename} already exist"
            exit 0
        fi
        """
    }
    """
    ${check_block}
    umask 0002

    mkdir -p "${three_d_res_dir}"
    mkdir -p "${side_trk_dir}"
    mkdir -p "${front_trk_dir}"

    /app/entrypoint.sh \
    "${three_d_res_filename}" \
    "${front_features_filename}" \
    "${side_features_filename}" \
    "${kinemat_filename}" \
    "${front_trk_filename}" \
    "${side_trk_filename}"
    """    
}
