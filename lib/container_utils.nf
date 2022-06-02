def create_container_options(dirList) {
    def dirs = dirList
                .filter {
                    def (f, levels_up) = it
                    f ? true : false
                }
                .collect {
                    def (f, levels_up) = it
                    get_parent(f, levels_up)
                }
                .unique(false)
    if (workflow.containerEngine == 'singularity') {
        dirs
        .findAll { it != null && it != '' }
        .inject(params.runtime_opts) {
            arg, item -> "${arg} -B ${item}"
        }
    } else if (workflow.containerEngine == 'docker') {
        dirs
        .findAll { it != null && it != '' }
        .inject(params.runtime_opts) {
            arg, item -> "${arg} -v ${item}:${item}"
        }
    } else {
        params.runtime_opts
    }
}

def get_parent(f, levels_up) {
    def ff = file(f)
    def parent = ff
    def nlevels = levels_up
    while (nlevels-- > 0) {
        def p = parent.parent;
        if (!p)
            return ff
        else
            parent = p
        
    }
    return parent
}
