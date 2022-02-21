ZOOKEEPER_VERSION=3.5.9

ARCH=""
dockerArch=$(docker info | grep Architecture | cut -d' ' -f3 | sed -e 's/\s+//g')
case "${dockerArch}" in
    amd64)   ARCH='amd64';;
    x86_64)  ARCH='amd64';;
    arm64)   ARCH='arm64';;
    aarch64) ARCH='arm64';;
    *) echo "unsupported architecture: $dockerArch"; exit 1 ;;
esac

REV=1

docker build \
     --no-cache \
     -t schnell18/zookeeper:${ZOOKEEPER_VERSION}-${REV}-alpine-${ARCH} \
     --build-arg version=${ZOOKEEPER_VERSION} .
docker push schnell18/zookeeper:$ZOOKEEPER_VERSION-$REV-alpine-${ARCH}
