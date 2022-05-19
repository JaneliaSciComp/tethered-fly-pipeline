include {
    create_container_options;
} from '../../lib/container_utils'

process TRACE_FEATURES {
    label 'use_gpu'
    container { params.apt_track_container }
    containerOptions { create_container_options([
        file(side_features_filename).parent,
        file(front_features_filename).parent,
        file(kinemat_filename).parent,
        file(three_d_res_filename).parent,
        file(side_trk_filename).parent.parent,
        file(front_trk_filename).parent.parent,
    ]) }
    cpus { params.apt_track_cpus }
    memory { params.apt_track_memory }

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
    """
    umask 0002
    /app/entrypoint.sh \
    "${three_d_res_filename}" \
    "${front_features_filename}" \
    "${side_features_filename}" \
    "${kinemat_filename}" \
    "${front_trk_filename}" \
    "${side_trk_filename}"
    """    
}
