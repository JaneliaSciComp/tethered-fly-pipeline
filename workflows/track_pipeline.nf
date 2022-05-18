include {
    GET_SAMPLE_DIRS;
} from '../modules/sample_dirs/main'

include {
    CREATE_VIDEO_LIST as CREATE_FRONT_VIEW_LIST;
    CREATE_VIDEO_LIST as CREATE_SIDE_VIEW_LIST;
} from '../modules/videolist/main'

include {
    DETECT_FEATURES_FOR_VIEW_MOVIES as DETECT_FEATURES_FOR_SIDEVIEW_MOVIES;
    DETECT_FEATURES_FOR_VIEW_MOVIES as DETECT_FEATURES_FOR_FRONTVIEW_MOVIES;
} from '../modules/detect_features_from_view_movies/main'

workflow track_pipeline {
    take:
    input_dir
    output_dir

    main:
    def sample_input_dirs = GET_SAMPLE_DIRS(input_dir)
    | flatMap { it.split('\s+') }
    | map {
        def fly = file(it).name
        [fly, it]
    } // [ flyname, fly_input_dir]

    def sample_output_dirs = output_dir
    | combine(sample_input_dirs.map { it[0] })
    | map { 
        [it[1], "${it[0]}/${it[1]}"] 
    } // [ flyname, fly_output_dir]

    def view_list_inputs = sample_input_dirs
    | join(sample_output_dirs, by:0)

    def side_view_lists = CREATE_SIDE_VIEW_LIST(
        view_list_inputs.map { 
            [ it[1], "${it[2]}/sideViewList.txt" ]
        },
        params.sideview_dirname_pattern
    )
    | map {
        def (fly_dirname, view_filename) = it
        def detect_output_dir = file(view_filename).parent
        [ fly_dirname, view_filename, "${detect_output_dir}/detect_results" ]
    }

    def front_view_lists = CREATE_FRONT_VIEW_LIST(
        view_list_inputs.map { 
            [ it[1], "${it[2]}/frontViewList.txt" ]
        },
        params.frontview_dirname_pattern
    )
    | map {
        def (fly_dirname, view_filename) = it
        def detect_output_dir = file(view_filename).parent
        [ fly_dirname, view_filename, "${detect_output_dir}/detect_results" ]
    }

    def side_view_detect_results = DETECT_FEATURES_FOR_SIDEVIEW_MOVIES(
        side_view_lists.map { [ it[1], it[2] ] },
        [ params.sideview_type, params.sideview_crop_size ]
    )

    def front_view_detect_results = DETECT_FEATURES_FOR_FRONTVIEW_MOVIES(
        front_view_lists.map { [ it[1], it[2] ] },
        [ params.frontview_type, params.frontview_crop_size ]
    )

    emit:
    res = side_view_detect_results | concat(front_view_detect_results)
}
