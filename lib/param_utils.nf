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

def scratch_dir_param(Map ps) {
    def scratch_dir = ps.scratch_dir
    if (!scratch_dir) {
        return ''
    }
    def dir = file(scratch_dir)
    return "${dir}"
}

def temp_tracking_dir_param(Map ps) {
    def dir = file(ps.tmp_tracking_dir)
    return "${dir}"
}
