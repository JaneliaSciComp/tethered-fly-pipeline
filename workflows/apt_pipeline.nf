include {
    GET_SAMPLE_DIRS;
} from '../modules/sample_dirs/main'

include {
    detect_pipeline as side_view_detect
    detect_pipeline as front_view_detect
} from '../subworkflows/detect_pipeline'

include {
    trace_pipeline;
} from '../subworkflows/trace_pipeline'

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
    } // [ flyname, fly_temp_tracking_dir]

    def side_view_detect_results = side_view_detect(
        apt_inputs,
        tmp_apt_outputs,
        'SIDE', // this is a constant for side view
        params.sideview_videoname_pattern,
        params.sideview_crop_size,
        params.sideview_detect_result_suffix
    )

    def front_view_detect_results = front_view_detect(
        apt_inputs,
        tmp_apt_outputs,
        'FRONT', // this is a constant for front view
        params.frontview_videoname_pattern,
        params.frontview_crop_size,
        params.frontview_detect_result_suffix
    )

    def paired_detect_results = side_view_detect_results
    | join(front_view_detect_results, by:[0,1])
    | map {
        def (flyname, video_key,
             side_video, side_detect_result_dir, side_detect_result_name,
             front_video, front_detect_result_dir, front_detect_result_name
            ) = it
        [
            flyname,
            side_video,
            "${side_detect_result_dir}/${side_detect_result_name}",
            front_video,
            "${front_detect_result_dir}/${front_detect_result_name}"
        ]
    }

    def apt_outputs = output_dir
    | combine(apt_inputs.map { it[0] })
    | map {
        [it[1], "${it[0]}/${it[1]}"]
    } // [ flyname, fly_output_dir]

    def apt_final_results = trace_pipeline(
        paired_detect_results,
        apt_outputs
    )

    emit:
    done = apt_final_results
}
