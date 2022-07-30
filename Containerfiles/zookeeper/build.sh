ZOOKEEPER_VERSION=3.5.9
REV=4


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
    --jobs 2 \
    --platform linux/amd64,linux/arm64/v8 \
    --manifest ${MANIFEST} \
    --build-arg version=${ZOOKEEPER_VERSION} \
    --tag $REGISTRY/$USER/$IMAGE_NAME:$IMAGE_TAG \
    .

podman manifest push --all ${MANIFEST} docker://$REGISTRY/$USER/$IMAGE_NAME:$IMAGE_TAG
