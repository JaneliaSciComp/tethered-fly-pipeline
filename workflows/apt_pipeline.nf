include {
    GET_SAMPLE_DIRS;
} from '../modules/sample_dirs/main'

include {
    DETECT_PIPELINE as DETECT_SIDE_VIEW
    DETECT_PIPELINE as DETECT_FRONT_VIEW
} from '../subworkflows/detect_pipeline'

include {
    TRACE_PIPELINE;
} from '../subworkflows/trace_pipeline'

workflow apt_pipeline {
    take:
    input_dir
    output_dir
    temp_tracking_dir

    main:
    def apt_inputs = GET_SAMPLE_DIRS(input_dir)
    | filter { 
        def res = it != 'null'
        if (!res) {
            log.warn "No fly data directory found! Check the input_dir and/or flydata_maxdepth_search parameters"
        }
        res
    }
    | flatMap { it.split('\s+') }
    | map {
        def fly = file(it).name
        [fly, it]
    } // [ flyname, fly_input_dir]

    def tmp_apt_outputs = temp_tracking_dir
    | combine(output_dir)
    | combine(apt_inputs.map { it[0] })
    | map {
        def (tracking_results_dir, final_results_dir, flyname) = it
        [
            flyname, 
            "${tracking_results_dir}/${flyname}",
            "${final_results_dir}/${flyname}",
        ] 
    } // [ flyname, fly_temp_tracking_dir]

    def sideview_filelist = tmp_apt_outputs
    | map {
        def (fly, traking_dir, results_dir) = it
        "${results_dir}/${params.sideview_collectionfile}"
    }
    def detect_side_view_results = DETECT_SIDE_VIEW(
        apt_inputs,
        tmp_apt_outputs,
        'SIDE', // this is a constant for side view
        params.sideview_videoname_pattern,
        params.sideview_crop_size,
        sideview_filelist,
        params.sideview_detect_result_suffix
    )

    def frontview_filelist = tmp_apt_outputs
    | map {
        def (fly, traking_dir, results_dir) = it
        "${results_dir}/${params.frontview_collectionfile}"
    }
    def detect_front_view_results = DETECT_FRONT_VIEW(
        apt_inputs,
        tmp_apt_outputs,
        'FRONT', // this is a constant for front view
        params.frontview_videoname_pattern,
        params.frontview_crop_size,
        frontview_filelist,
        params.frontview_detect_result_suffix
    )

    def paired_detect_results = detect_side_view_results
    | join(detect_front_view_results, by:[0,1])
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

    def apt_final_results = TRACE_PIPELINE(
        paired_detect_results,
        apt_outputs
    )

    emit:
    done = apt_final_results
}
