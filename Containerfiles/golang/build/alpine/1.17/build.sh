GOLANG_VERSION=1.17
REV=4

REGISTRY=docker.io
USER=schnell18
IMAGE_NAME=golang-build
IMAGE_TAG=${GOLANG_VERSION}-${REV}-alpine
MANIFEST=${IMAGE_NAME}

podman manifest create ${MANIFEST}
podman build \
    --jobs 2 \
    --platform linux/amd64,linux/arm64/v8 \
    --manifest ${MANIFEST} \
    --tag $REGISTRY/$USER/$IMAGE_NAME:$IMAGE_TAG \
    .

podman manifest push --all ${MANIFEST} docker://$REGISTRY/$USER/$IMAGE_NAME:$IMAGE_TAG
