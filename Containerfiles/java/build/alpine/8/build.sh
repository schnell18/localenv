JDK_VERSION=8.0.332
MAVEN_VERSION=3.8.6
CHECKSUM=f790857f3b1f90ae8d16281f902c689e4f136ebe584aba45e4b1fa66c80cba826d3e0e52fdd04ed44b4c66f6d3fe3584a057c26dfcac544a60b301e6d0f91c26
BASE_URL=https://mirror.sjtu.edu.cn/apache/maven/maven-3/${MAVEN_VERSION}/binaries
REV=2
REGISTRY=docker.io
USER=schnell18
IMAGE_NAME=java-build
IMAGE_TAG=${JDK_VERSION}-${MAVEN_VERSION}-${REV}-alpine
MANIFEST=${IMAGE_NAME}-8

podman manifest create ${MANIFEST}
podman build \
    --jobs 2 \
    --platform linux/amd64,linux/arm64/v8 \
    --manifest ${MANIFEST} \
    --build-arg MAVEN_VERSION=${MAVEN_VERSION} \
    --build-arg CHECKSUM=${CHECKSUM} \
    --build-arg BASE_URL=${BASE_URL} \
    --tag $REGISTRY/$USER/$IMAGE_NAME:$IMAGE_TAG \
    .

podman manifest push --all ${MANIFEST} docker://$REGISTRY/$USER/$IMAGE_NAME:$IMAGE_TAG
