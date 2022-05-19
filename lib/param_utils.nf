def default_params() {
    [
        apt_containers_repo: 'registry.int.janelia.org/huston',
        apt_detect_container_version: '1.0',
        apt_track_container_version: '1.0',
        error_strategy: 'ignore', // the default nextflow strategy use ignore instead of terminate

        apt_detect_cpus: 8,
        apt_detect_memory: '24G',

        apt_track_cpus: 8,
        apt_track_memory: '24G',

        force_detect: false,
        force_track: false,
        flydata_dirname_pattern: 'fly[0-9]*',
        sideview_type: 'SIDE',
        sideview_crop_size: '230,350',
        sideview_dirname_pattern: 'C001*002_c.avi',
        sideview_detect_result_suffix: '_side',
        frontview_type: 'FRONT',
        frontview_crop_size: '350,350',
        frontview_dirname_pattern: 'C002*002_c.avi',
        frontview_detect_result_suffix: '_front',
        body_axis_lookup_filename: '/Users/goinac/Work/HHMI/stephen-huston/apt-pipeline/local/data/samples/fly2BodyAxis_lookupTable_Ben.csv',
        label_filename: '/Users/goinac/Work/HHMI/stephen-huston/apt-pipeline/local/data/model/sh_trn5017_20200121_stripped.lbl',
        crop_regression_filename: '/Users/goinac/Work/HHMI/stephen-huston/apt-pipeline/local/data/model/crop_regression_params.mat',
        model_cache_dirname: '/Users/goinac/Work/HHMI/stephen-huston/apt-pipeline/local/apt_model_cache',
        model_name: 'stephen_20200124',
        calibrations_filename: '/Users/goinac/Work/HHMI/stephen-huston/apt-pipeline/local/data/samples/fly2DLT_lookupTableStephen.csv'
    ]
}

def input_dir_param(Map ps) {
    def dir = file(ps.i)
    return "${dir}"
}

def output_dir_param(Map ps) {
    def dir = file(ps.o)
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
