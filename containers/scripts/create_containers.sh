DIR=$(cd "$(dirname "$0")"; pwd)

source ${DIR}/container_versions.sh

docker buildx build --platform linux/amd64 \
    -t public.ecr.aws/janeliascicomp/huston/apt_detect:${apt_detect_version} \
    -t janeliascicomp/apt_detect:${apt_detect_version} \
    containers/apt_detect --push

docker buildx build --platform linux/amd64 \
    -t public.ecr.aws/janeliascicomp/huston/apt_track:${apt_track_version} \
    -t janeliascicomp/apt_track:${apt_track_version} \
    containers/apt_track --push
