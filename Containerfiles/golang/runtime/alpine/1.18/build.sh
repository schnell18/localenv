GOLANG_VERSION=1.18
GRPC_HEALTH_PROBE_VERSION=v0.4.11
REV=7

REGISTRY=docker.io
USER=schnell18
IMAGE_NAME=golang-runtime
IMAGE_TAG=${GOLANG_VERSION}-${REV}-alpine
MANIFEST=${IMAGE_NAME}

podman manifest create ${MANIFEST}
podman build \
    --jobs 2 \
    --platform linux/amd64,linux/arm64/v8 \
    --manifest ${MANIFEST} \
    --build-arg GRPC_HEALTH_PROBE_VERSION=${GRPC_HEALTH_PROBE_VERSION} \
    --tag $REGISTRY/$USER/$IMAGE_NAME:$IMAGE_TAG \
    .

podman manifest push --all ${MANIFEST} docker://$REGISTRY/$USER/$IMAGE_NAME:$IMAGE_TAG
