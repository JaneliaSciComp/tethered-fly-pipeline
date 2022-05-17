DIR=$(cd "$(dirname "$0")"; pwd)

source ${DIR}/container_versions.sh

docker build \
    -t registry.int.janelia.org/huston/apt_classifier:${apt_classifier_version} \
    -t apt_classifier:${apt_classifier_version} \
    containers/apt_classifier

#docker build \
#    -t registry.int.janelia.org/huston/apt_tracker:${apt_tracker_version} \
#    -t apt_tracker:${apt_tracker_version} \
#    containers/apt_tracker


