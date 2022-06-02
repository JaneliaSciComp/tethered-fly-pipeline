include {
    create_container_options;
} from '../../lib/container_utils'

process COMPUTE_TRAJECTORIES {
    container { params.apt_track_container }
    containerOptions { create_container_options([
        [side_features_filename, 1],
        [front_features_filename, 1],
        [kinemat_filename, 1],
        // the location of the result files is:
        // <output_folder>/<flyfolder-fly123>/<movie folder-C001H001S0002>/<movie name>_3dres.mat
        // so we mount the parent of the output folder
        [three_d_res_filename, 4],
        [side_trk_filename, 4],
        [front_trk_filename, 4],
        [params.scratch_dir, 0],
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
    def three_d_res_file = file(three_d_res_filename)
    def side_trk_file = file(side_trk_filename)
    def front_trk_file = file(front_trk_filename)
    def three_d_res_dir = three_d_res_file.parent
    def side_trk_dir = side_trk_file.parent
    def front_trk_dir = front_trk_file.parent
    def three_d_res_name = three_d_res_file.name
    def side_trk_name = side_trk_file.name
    def front_trk_name = front_trk_file.name

    def check_block = ''
    if (!params.force_track) {
        check_block = """
        if [[ -f "${front_trk_filename}" && -f "${side_trk_filename}" ]]; then
            echo "Trace files ${front_trk_filename} and ${side_trk_filename} already exist"
            exit 0
        fi
        """
    }
    def three_d_res_output
    def side_trk_output
    def front_trk_output
    def mk_output_dirs    
    def mv_result_block
    if (params.scratch_dir) {
        three_d_res_output = "${params.scratch_dir}/${three_d_res_name}"
        side_trk_output = "${params.scratch_dir}/${side_trk_name}"
        front_trk_output = "${params.scratch_dir}/${front_trk_name}"

        mk_output_dirs = """
        mkdir -p ${params.scratch_dir}
        mkdir -p "${three_d_res_dir}"
        mkdir -p "${side_trk_dir}"
        mkdir -p "${front_trk_dir}"
        """

        mv_result_block = """
        mv ${three_d_res_output} ${three_d_res_filename}
        mv ${side_trk_output} ${side_trk_filename}
        mv ${front_trk_output} ${front_trk_filename}
        """
    } else {
        three_d_res_output = three_d_res_filename
        side_trk_output = side_trk_filename
        front_trk_output = front_trk_filename

        mk_output_dirs = """
        mkdir -p "${three_d_res_dir}"
        mkdir -p "${side_trk_dir}"
        mkdir -p "${front_trk_dir}"
        """

        mv_result_block = ''
    }
    """
    ${check_block}
    umask 0002

    ${mk_output_dirs}

    /app/entrypoint.sh \
    "${three_d_res_output}" \
    "${front_features_filename}" \
    "${side_features_filename}" \
    "${kinemat_filename}" \
    "${front_trk_output}" \
    "${side_trk_output}"

    ${mv_result_block}
    """    
}
