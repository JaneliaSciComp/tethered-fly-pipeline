include {
    GET_SAMPLE_DIRS;
} from '../modules/sample_dirs/main'

include {
    DETECT_PIPELINE as DETECT_SIDE_VIEW;
    DETECT_PIPELINE as DETECT_FRONT_VIEW;
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
    | filter { dirs ->
        def res = dirs != 'null'
        if (!res) {
            log.warn "No fly data directory found! Check the input_dir and/or flydata_maxdepth_search parameters"
        }
        res
    }
    | flatMap { dirs -> dirs.split('\\s+') }
    | map { fly_input_dirname ->
        def fly_input_dir = file(fly_input_dirname)
        def flyname = fly_input_dir.name
        def r = [ flyname, fly_input_dir ]
        log.debug "APT input: $r"
        return r
    } // [ flyname, fly_input_dir]

    def tmp_apt_outputs = temp_tracking_dir
    | combine(apt_inputs.map { row -> row[0] })
    | map { row ->
        def (tracking_results_dir, flyname) = row
        [
            flyname, "${tracking_results_dir}/${flyname}",
        ]
    } // [ flyname, fly_temp_tracking_dir]

    def sideview_filelist = output_dir
    | combine(apt_inputs.map { row -> row[0] })
    | map { row ->
        def (results_dir, flyname) = row
        return file("${results_dir}/${flyname}/${params.sideview_collectionfile}")
    }

    def detect_aux_files = [
        file(params.model_cache_dirname),
        params.model_name,
        file(params.body_axis_lookup_filename),
        file(params.label_filename),
        file(params.crop_regression_filename),
        params.scratch_dir ? file(params.scratch_dir) : [],
    ]

    def detect_side_view_results = DETECT_SIDE_VIEW(
        apt_inputs,
        tmp_apt_outputs,
        detect_aux_files,
        'SIDE', // this is a constant for side view
        params.sideview_videoname_pattern,
        params.sideview_crop_size,
        params.force_detect,
        sideview_filelist,
        params.sideview_detect_result_suffix
    )

    def frontview_filelist = output_dir
    | combine(apt_inputs.map { row -> row[0] })
    | map { row ->
        def (results_dir, flyname) = row
        return file("${results_dir}/${flyname}/${params.frontview_collectionfile}")
    }

    def detect_front_view_results = DETECT_FRONT_VIEW(
        apt_inputs,
        tmp_apt_outputs,
        detect_aux_files,
        'FRONT', // this is a constant for front view
        params.frontview_videoname_pattern,
        params.frontview_crop_size,
        params.force_detect,
        frontview_filelist,
        params.frontview_detect_result_suffix
    )

    def paired_detect_results = detect_side_view_results
    | join(detect_front_view_results, by:[0,1])
    | map { row ->
        def (flyname, _video_key,
             side_video, side_detect_result_dir, side_detect_result_name,
             front_video, front_detect_result_dir, front_detect_result_name
            ) = row
        [
            flyname,
            side_video,
            "${side_detect_result_dir}/${side_detect_result_name}",
            front_video,
            "${front_detect_result_dir}/${front_detect_result_name}"
        ]
    }

    def apt_outputs = output_dir
    | combine(apt_inputs.map { row -> row[0] })
    | map { row ->
        [ row[1], file("${row[0]}/${row[1]}") ]
    } // [ flyname, fly_output_dir]

    def apt_final_results = TRACE_PIPELINE(
        paired_detect_results,
        apt_outputs
    )

    emit:
    done = apt_final_results
}
