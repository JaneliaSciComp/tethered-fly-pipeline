// Reads the body axis lookup CSV (params.body_axis_lookup_filename).
// Each line looks like:
//   90,/groups/huston/hustonlab/flp-chrimson_experiments/bodyAxis_APT_projects/fly090_bodyData.lbl
// The second field is the path to a per-fly body data .lbl file.
// This emits (space-separated) the distinct parent directories of those .lbl
// files so they can be appended to detect_aux_files and mounted into the
// detect container.
//
// This runs as a process (not a plain function) because the lookup file and the
// paths it references may only be accessible from the compute node, not the
// Nextflow head node.
process EXTRACT_BODY_AXIS_DATA_DIRS {
    label 'low_cpu'
    label 'low_memory'
    container 'public.ecr.aws/janeliascicomp/huston/apt_detect:1.1.0'

    input:
    path(body_axis_lookup_file)

    output:
    env('data_dirs')

    script:
    """
    full_lookup_file=\$(readlink -m ${body_axis_lookup_file})
    data_dirs=\$(
        awk -F, 'NF > 1 { gsub(/\\r/, "", \$2); if (\$2 != "") print \$2 }' "\${full_lookup_file}" \\
        | xargs -r -n1 dirname \\
        | sort -u \\
        | tr '\\n' ' '
    )
    """
}
