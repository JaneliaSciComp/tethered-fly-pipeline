include {
    CREATE_VIDEO_LIST;
} from '../modules/videolist/main'

include {
    DETECT_FEATURES_FROM_MOVIE;
} from '../modules/detect_features_from_movie/main'

workflow detect_pipeline {
    take:
    inputs
    outputs
    view_type
    view_dirname_pattern
    view_crop_size

    main:
    def detect_process_inputs = CREATE_VIDEO_LIST(
        inputs,
        view_dirname_pattern
    )
    | flatMap {
        def (flyname, movies_list_string) = it
        movies_list_string.split('\s+')
            .collect { [ flyname, it ] }
    }
    | combine(outputs, by:0)
    | map {
        def (flyname, movie, flyoutput) = it
        def movie_file = file(movie)
        def movie_dirname = movie_file.parent.name
        [ flyname, movie, "${flyoutput}/${movie_dirname}" ]
    }

    def detect_process_outputs = DETECT_FEATURES_FROM_MOVIE(
        detect_process_inputs,
        view_type,
        view_crop_size
    )
    | map {
        def (flyname, movie, detectoutput) = it
        def movie_file = file(movie)
        def movie_name = movie_file.name
        [ flyname, get_detect_output_key(movie_name), movie, detectoutput ]
    }

    emit:
    res = detect_process_outputs
}


def get_detect_output_key(fname) {
    fname.split(/[.]/)[0].substring(4)
}
