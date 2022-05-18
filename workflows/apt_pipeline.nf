include {
    GET_SAMPLE_DIRS;
} from '../modules/sample_dirs/main'

include {
    detect_pipeline as side_view_detect
    detect_pipeline as front_view_detect
} from '../subworkflows/detect_pipeline'

workflow apt_pipeline {
    take:
    input_dir
    output_dir
    temp_tracking_dir

    main:
    def apt_inputs = GET_SAMPLE_DIRS(input_dir)
    | flatMap { it.split('\s+') }
    | map {
        def fly = file(it).name
        [fly, it]
    } // [ flyname, fly_input_dir]

    def tmp_apt_outputs = temp_tracking_dir
    | combine(apt_inputs.map { it[0] })
    | map { 
        [it[1], "${it[0]}/${it[1]}"] 
    } // [ flyname, fly_output_dir]

    def side_view_detect_results = side_view_detect(
        apt_inputs,
        tmp_apt_outputs,
        params.sideview_type,
        params.sideview_dirname_pattern,
        params.sideview_crop_size
    )

    def front_view_detect_results = front_view_detect(
        apt_inputs,
        tmp_apt_outputs,
        params.frontview_type,
        params.frontview_dirname_pattern,
        params.frontview_crop_size
    )

    def pair_detect_results = side_view_detect_results
    | join(front_view_detect_results, by:0,1)

    emit:
    res = pair_detect_results
}
