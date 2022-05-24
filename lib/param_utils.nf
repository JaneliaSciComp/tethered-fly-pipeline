def default_params() {
    [
        apt_containers_repo: 'registry.int.janelia.org/huston',
        apt_detect_container_version: '1.0',
        apt_track_container_version: '1.0',
        error_strategy: 'ignore', // the default nextflow strategy use ignore instead of terminate

        apt_detect_cpus: 2,
        apt_detect_memory: '30G',

        apt_track_cpus: 3,
        apt_track_memory: '45G',

        force_detect: false,
        force_track: false,
        flydata_dirname_pattern: 'fly[0-9]*',
        sideview_crop_size: '230,350',
        sideview_videoname_pattern: 'C001*.avi',
        sideview_detect_result_suffix: '_side',
        frontview_crop_size: '350,350',
        frontview_videoname_pattern: 'C002*.avi',
        frontview_detect_result_suffix: '_front',
        body_axis_lookup_filename: '',
        label_filename: '',
        crop_regression_filename: '',
        model_cache_dirname: '',
        model_name: '',
        calibrations_filename: ''
    ]
}

def input_dir_param(Map ps) {
    def input_dir = ps.input_dir
    if (!input_dir) {
        input_dir = ps.i
    }
    def dir = file(input_dir)
    return "${dir}"
}

def output_dir_param(Map ps) {
    def output_dir = ps.output_dir
    if (!output_dir) {
        output_dir = ps.o
    }
    def dir = file(output_dir)
    return "${dir}"
}

def temp_tracking_dir_param(Map ps) {
    def dir = file(ps.tmp_tracking_dir)
    return "${dir}"
}

def apt_detect_container_param(Map ps) {
    def apt_detect_container = ps.apt_detect_container
    if (!apt_detect_container)
        "${ps.apt_containers_repo}/apt_detect:${ps.apt_detect_container_version}"
    else
        apt_detect_container
}

def apt_track_container_param(Map ps) {
    def apt_track_container = ps.apt_track_container
    if (!apt_track_container)
        "${ps.apt_containers_repo}/apt_track:${ps.apt_track_container_version}"
    else
        apt_track_container
}
