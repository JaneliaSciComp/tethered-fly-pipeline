#!/usr/bin/env bash

bin_app="/app/bin/compute3Dfrom2D_compiled"
echo "Run ${bin_app} ${@}"
${bin_app} "${@}"
