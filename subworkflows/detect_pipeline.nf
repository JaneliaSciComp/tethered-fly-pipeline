include {
    CREATE_VIDEO_LIST;
} from '../modules/videolist/main'

include {
    DETECT_FEATURES_FROM_VIDEO;
} from '../modules/detect_features_from_video/main'

workflow DETECT_PIPELINE {
    take:
    inputs
    outputs
    view_type
    video_name_pattern
    view_crop_size
    collection_file
    result_suffix

    main:
    def detect_process_inputs = CREATE_VIDEO_LIST(
        inputs,
        video_name_pattern,
        collection_file,
    )
    | flatMap {
        def (flyname, video_list_file, videos_list_string) = it
        videos_list_string.split('\\s+')
            .collect {
                def r = [ flyname, it ]
                log.debug "Prepare movie file $r"
                r
            }
    }
    | combine(outputs, by:0)
    | map {
        def (flyname, video, fly_tracking_output) = it
        def video_file = file(video)
        def video_dirname = video_file.parent.name
        def expected_output_name = get_expected_output_name(video, result_suffix)
        [ flyname, video, "${fly_tracking_output}/${video_dirname}", expected_output_name ]
    }

    def detect_process_outputs = DETECT_FEATURES_FROM_VIDEO(
        detect_process_inputs,
        view_type,
        view_crop_size
    )
    | map {
        def (flyname, video, detect_output, detect_result_name) = it
        def video_file = file(video)
        def video_name = video_file.name
        [ flyname, get_detect_output_key(video_name), video, detect_output, detect_result_name ]
    }

    emit:
    res = detect_process_outputs
}


def get_detect_output_key(fname) {
    fname.split(/[.]/)[0].substring(4)
}

def get_expected_output_name(video, suffix) {
    def video_parts = video.split('/')
    return video_parts.size() > 6
        ? "${video_parts[-6]}__${video_parts[-3]}__${video_parts[-1][-10..-5]}${suffix}.mat"
        : "${video_parts[-3]}__${video_parts[-1][-10..-5]}${suffix}.mat"
}