def create_container_options(dirList) {
    def dirs = dirList
                .findAll { entry ->
                    def (f, _levels_up) = entry
                    f
                }
                .collect { entry ->
                    def (f, levels_up) = entry
                    get_parent(f, levels_up)
                }
                .unique(false)
    if (workflow.containerEngine == 'singularity' || workflow.containerEngine == 'apptainer') {
        dirs
        .findAll { d -> d != null && d != '' }
        .inject(params.runtime_opts) { arg, item ->
            "${arg} -B ${item}"
        }
    } else if (workflow.containerEngine == 'docker' || workflow.containerEngine == 'podman') {
        dirs
        .findAll { d -> d != null && d != '' }
        .inject(params.runtime_opts) { arg, item ->
            "${arg} -v ${item}:${item}"
        }
    } else {
        params.runtime_opts
    }
}

def get_parent(f, levels_up) {
    def ff = file(f)
    return walk_up(ff, ff, levels_up)
}

def walk_up(orig, current, remaining) {
    if (remaining <= 0) return current
    def p = current.parent
    if (!p) return orig
    return walk_up(orig, p, remaining - 1)
}
