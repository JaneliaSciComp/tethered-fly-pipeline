DIR=$(cd "$(dirname "$0")"; pwd)

source ${DIR}/container_versions.sh

docker build \
    -t public.ecr.aws/janeliascicomp/huston/apt_detect:${apt_detect_version} \
    -t registry.int.janelia.org/huston/apt_detect:${apt_detect_version} \
    -t apt_detect:${apt_detect_version} \
    containers/apt_detect

# docker build \
#     -t public.ecr.aws/janeliascicomp/huston/apt_track:${apt_track_version} \
#     -t registry.int.janelia.org/huston/apt_track:${apt_track_version} \
#     -t apt_track:${apt_track_version} \
#     containers/apt_track
