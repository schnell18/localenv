ZOOKEEPER_VERSION=$(jq -r '.zookeeperVersion' version.json)
JRE_RUNTIME_IMG_TAG=$(jq -r '.jreRuntimeImageTag' version.json)
REV=$(jq -r '.build' version.json)


REGISTRY=docker.io
USER=schnell18
IMAGE_NAME=zookeeper
IMAGE_TAG=${ZOOKEEPER_VERSION}-${REV}-alpine
MANIFEST=${IMAGE_NAME}

# remove local manifest from previous build so that
# we don't have previous versions to pollute the new build
podman manifest exists ${MANIFEST}
if [[ $? -eq 0 ]]; then
    podman manifest rm ${MANIFEST}
fi

podman manifest create ${MANIFEST}
podman build \
    --platform linux/amd64 \
    --manifest ${MANIFEST} \
    --build-arg ZOOKEEPER_VERSION=${ZOOKEEPER_VERSION} \
    --build-arg JRE_RUNTIME_IMG_TAG=${JRE_RUNTIME_IMG_TAG} \
    --tag $REGISTRY/$USER/$IMAGE_NAME:$IMAGE_TAG \
    .

# podman manifest push --all ${MANIFEST} docker://$REGISTRY/$USER/$IMAGE_NAME:$IMAGE_TAG
