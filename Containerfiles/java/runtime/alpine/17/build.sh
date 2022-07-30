AZUL_VERSION=17.34.19
OPENJDK_VERSION=17.0.3
REV=4

REGISTRY=docker.io
USER=schnell18

pushd jre

IMAGE_NAME=java-runtime-jre
IMAGE_TAG=${OPENJDK_VERSION}-${AZUL_VERSION}-${REV}-alpine
MANIFEST=${IMAGE_NAME}-17

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
    --build-arg OPENJDK_VERSION=${OPENJDK_VERSION} \
    --build-arg ZULU_VERSION=${AZUL_VERSION} \
    --tag $REGISTRY/$USER/$IMAGE_NAME:$IMAGE_TAG \
    .

podman manifest push --all ${MANIFEST} docker://$REGISTRY/$USER/$IMAGE_NAME:$IMAGE_TAG
popd

pushd jdk

IMAGE_NAME=java-runtime-jdk
IMAGE_TAG=${OPENJDK_VERSION}-${AZUL_VERSION}-${REV}-alpine
MANIFEST=${IMAGE_NAME}-17
# MANIFEST=${REGISTRY}/${USER}/${IMAGE_NAME}:${IMAGE_TAG}

# remove local manifest from previous build so that
# we don't have previous versions to pollute the new build
podman manifest exists ${MANIFEST}
if [[ $? -eq 0 ]]; then
    podman manifest rm ${MANIFEST}
fi

podman manifest create ${MANIFEST}
podman build \
    --platform linux/amd64,linux/arm64/v8 \
    --manifest ${MANIFEST} \
    --build-arg OPENJDK_VERSION=${OPENJDK_VERSION} \
    --build-arg ZULU_VERSION=${AZUL_VERSION} \
    --tag $REGISTRY/$USER/$IMAGE_NAME:$IMAGE_TAG \
    .

podman manifest push --all ${MANIFEST} docker://$REGISTRY/$USER/$IMAGE_NAME:$IMAGE_TAG
popd
