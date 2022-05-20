include {
    GET_TEXT_CONTENT;
} from '../modules/get_text_content/main'

include {
    COMPUTE_TRAJECTORIES;
} from '../modules/compute_trajectories/main'

workflow trace_pipeline {
    take:
    side_front_pairs
    output_dir

    main:

    def fly_calibrations = GET_TEXT_CONTENT(params.calibrations_filename)
    | flatMap { fn_and_content ->
        def (fn, csv_rows) = fn_and_content
        if (csv_rows.trim() == "null") {
            return []
        } else {
            return csv_rows.split(/\s+/)
        }
    }
    | filter { it.trim() != '' }
    | map { it.split(/[,]/) }
    | map {
        def (flynum, calibration_filename) = it
        [ "fly${flynum}", calibration_filename ]
    }

    def trace_inputs = side_front_pairs
    | combine(fly_calibrations, by: 0)
    | combine(output_dir, by:0)
    | map {
        def (flyname,
             side_movie_filename, side_features,
             front_movie_filename, front_features,
             kinemat_file, trace_output_dir) = it
        def (three_d_res_folder, three_d_res_filename) = create_trace_filename(side_movie_filename, '_3Dres.mat')
        def (side_trace_folder, side_trace_filename) = create_trace_filename(side_movie_filename, '.trk')
        def (front_trace_folder, front_trace_filename) = create_trace_filename(front_movie_filename, '.trk')
        [
            flyname,
            side_features, front_features,
            kinemat_file,
            "${trace_output_dir}/${three_d_res_folder}/${three_d_res_filename}",
            "${trace_output_dir}/${side_trace_folder}/${side_trace_filename}",
            "${trace_output_dir}/${front_trace_folder}/${front_trace_filename}"
        ]
    }

    def trace_results = COMPUTE_TRAJECTORIES(
        trace_inputs
    )

    emit:
    res = trace_results
}

def create_trace_filename(full_fn, suffix) {
    def f = file(full_fn)
    def folder = f.parent.name
    def name = f.name.split(/[.]/)[0]
    return [ folder, "${name}${suffix}" ]
}