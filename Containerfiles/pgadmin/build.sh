PGADMIN_VERSION=$(jq -r '.pgadminVersion' version.json)
REV=$(jq -r '.build' version.json)

REGISTRY=docker.io
USER=schnell18
IMAGE_NAME=pgadmin
IMAGE_TAG=${PGADMIN_VERSION}-${REV}
MANIFEST=${IMAGE_NAME}

# remove local manifest from previous build so that
# we don't have previous versions to pollute the new build
podman manifest exists ${MANIFEST}
if [[ $? -eq 0 ]]; then
    podman manifest rm ${MANIFEST}
fi

podman manifest create ${MANIFEST}

# --platform linux/amd64,linux/arm64/v8 \
podman build \
    --jobs 2 \
    --platform linux/amd64 \
    --manifest ${MANIFEST} \
    --build-arg PGADMIN_VERSION=${PGADMIN_VERSION} \
    --tag $REGISTRY/$USER/$IMAGE_NAME:$IMAGE_TAG \
    .

# podman manifest push --all ${MANIFEST} docker://$REGISTRY/$USER/$IMAGE_NAME:$IMAGE_TAG