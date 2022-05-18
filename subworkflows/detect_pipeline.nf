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
    result_suffix

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
        def expected_output_name = get_expected_output_name(movie, result_suffix)
        [ flyname, movie, "${flyoutput}/${movie_dirname}", expected_output_name ]
    }

    def detect_process_outputs = DETECT_FEATURES_FROM_MOVIE(
        detect_process_inputs,
        view_type,
        view_crop_size
    )
    | map {
        def (flyname, movie, detect_output, detect_result_name) = it
        def movie_file = file(movie)
        def movie_name = movie_file.name
        [ flyname, get_detect_output_key(movie_name), movie, detect_output, detect_result_name ]
    }

    emit:
    res = detect_process_outputs
}


def get_detect_output_key(fname) {
    fname.split(/[.]/)[0].substring(4)
}

def get_expected_output_name(movie, suffix) {
    def movie_parts = movie.split('/')
    return movie_parts.size() > 6
        ? "${movie_parts[-6]}__${movie_parts[-3]}__${movie_parts[-1][-10..-5]}${suffix}.mat"
        : "${movie_parts[-3]}__${movie_parts[-1][-10..-5]}${suffix}.mat"
}