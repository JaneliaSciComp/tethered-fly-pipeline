DIR=$(cd "$(dirname "$0")"; pwd)

source ${DIR}/container_versions.sh

docker push \
    registry.int.janelia.org/huston/apt_detect:${apt_detect_version}

docker push \
    public.ecr.aws/janeliascicomp/huston/apt_detect:${apt_detect_version}

docker push \
    registry.int.janelia.org/huston/apt_track:${apt_track_version} \

docker push \
    public.ecr.aws/janeliascicomp/huston/apt_track:${apt_track_version}
