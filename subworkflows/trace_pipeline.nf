include {
    GET_TEXT_CONTENT;
} from '../modules/get_text_content/main'

include {
    TRACE_FEATURES;
} from '../modules/trace_features/main'

workflow trace_pipeline {
    take:
    side_front_pairs
    output_dir

    main:

    def fly_calibrations = GET_TEXT_CONTENT(params.calibrations_filename)
    | flatMap { fn_and_content ->
        def (fn, csv_rows) = fn_and_content

        if (csv_rows == "null")
            return []
        else 
            return csv_rows.split(/\s+/)
    }
    | map { csv_row ->
        csv_row.split(/[,]/)
    }
    | map {
        def (flynum, calibration_filename) = it
        [ "fly${flynum}", calibration_filename ]
    }
    
    def track_inputs = side_front_pairs
    | combine(fly_calibrations, by: 0)
    | combine(output_dir, by:0)

    emit:
    res = track_inputs
}
