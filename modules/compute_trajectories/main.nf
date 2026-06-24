process COMPUTE_TRAJECTORIES {
    container 'public.ecr.aws/janeliascicomp/huston/apt_track:1.0.0'

    input:
    tuple val(flyname),
          path(side_features_filename),
          path(front_features_filename),
          path(kinemat_filename),
          path(three_d_res_filename),
          path(side_trk_filename),
          path(front_trk_filename)
    path(scratch_dir)

    output:
    tuple val(flyname),
          env('full_three_d_res'),
          env('full_side_trk'),
          env('full_front_trk')

    script:
    // Resolve every staged input back to its real (full) path. The result files
    // are outputs that may not exist yet, hence readlink -m which resolves a path
    // even when its final component is missing.
    def resolve_block = """
    full_side_features=\$(readlink -m ${side_features_filename})
    full_front_features=\$(readlink -m ${front_features_filename})
    full_kinemat=\$(readlink -m ${kinemat_filename})
    full_three_d_res=\$(readlink -m ${three_d_res_filename})
    full_side_trk=\$(readlink -m ${side_trk_filename})
    full_front_trk=\$(readlink -m ${front_trk_filename})
    """

    def run_block
    if (scratch_dir) {
        // Write the results to the scratch directory first, then move them to
        // their final locations.
        run_block = """
        full_scratch_dir=\$(readlink -m ${scratch_dir})
        echo "Use scratch dir: \${full_scratch_dir}"
        mkdir -p "\${full_scratch_dir}"
        mkdir -p "\$(dirname \${full_three_d_res})"
        mkdir -p "\$(dirname \${full_side_trk})"
        mkdir -p "\$(dirname \${full_front_trk})"

        scratch_three_d_res="\${full_scratch_dir}/${three_d_res_filename}"
        scratch_side_trk="\${full_scratch_dir}/${side_trk_filename}"
        scratch_front_trk="\${full_scratch_dir}/${front_trk_filename}"

        CMD=(
            /app/entrypoint.sh
            "\${scratch_three_d_res}"
            "\${full_front_features}"
            "\${full_side_features}"
            "\${full_kinemat}"
            "\${scratch_front_trk}"
            "\${scratch_side_trk}"
        )
        echo "CMD: \${CMD[@]}"
        (exec "\${CMD[@]}")

        mv "\${scratch_three_d_res}" "\${full_three_d_res}"
        mv "\${scratch_side_trk}" "\${full_side_trk}"
        mv "\${scratch_front_trk}" "\${full_front_trk}"
        """
    } else {
        run_block = """
        mkdir -p "\$(dirname \${full_three_d_res})"
        mkdir -p "\$(dirname \${full_side_trk})"
        mkdir -p "\$(dirname \${full_front_trk})"

        CMD=(
            /app/entrypoint.sh
            "\${full_three_d_res}"
            "\${full_front_features}"
            "\${full_side_features}"
            "\${full_kinemat}"
            "\${full_front_trk}"
            "\${full_side_trk}"
        )
        echo "CMD: \${CMD[@]}"
        (exec "\${CMD[@]}")
        """
    }

    // Skip the computation when the trace results already exist (unless forced).
    // Avoid an early `exit 0` so the output env vars are always captured.
    def compute_block = params.force_track
        ? run_block
        : """
        if [[ -f "\${full_front_trk}" && -f "\${full_side_trk}" ]]; then
            echo "Trace files \${full_front_trk} and \${full_side_trk} already exist"
        else
        ${run_block}
        fi
        """

    """
    umask 0002

    ${resolve_block}

    ${compute_block}
    """
}
