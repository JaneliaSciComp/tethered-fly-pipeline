#!/usr/bin/env bash

if [ -d /scratch ] ; then
  export MCR_CACHE_ROOT="/scratch/${USER}/apt_track/mcr_cache_${LSB_JOBID}_$$"
else
  export MCR_CACHE_ROOT=`mktemp -u`
fi

echo "User ${USER}"
echo "Use MCR_CACHE_ROOT ${MCR_CACHE_ROOT}"

[ -d ${MCR_CACHE_ROOT} ] || mkdir -p ${MCR_CACHE_ROOT}

umask 0002

bin_app="/app/bin/compute3Dfrom2D_compiled"
echo "Run ${bin_app} ${@}"
${bin_app} "${@}"
