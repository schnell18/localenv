# Introduction

This project builds multi-architecture(amd64 and arm64) container images to
package the well-known OpenJDK build from [azul][1]. This project support zulu
OpenJDK build for Java 8, Java 11, Java 17 on Alpine Linux, which is ideal for
containerized Java application.  To save space, it offers JRE and JDK flavors
separately.

## catalog

| name               | type          | OpenJDK version | Zulu Version |comment   |
| ------------------ | ------------- | --------------- | ------------ |--------- |
| java-runtime-jre   | jre           | 17.0.3          | 17.34.19     |          |
| java-runtime-jdk   | jdk           | 17.0.3          | 17.34.19     |          |

## Run the container

The following command sequence is a typical example for your reference:

    podman run                                                            \
        -it                                                               \
        --rm                                                              \
        docker.io/schnell18/java-runtime-jre:17:0.3-17.34.19-3-alpine     \
        /bin/sh

## Build container image

If you wish to build the docker image from scratch, you may clone this
repository and choose appropriate sub directory containing Dockerfile
and run:

    cd alpine/17
    sh build.sh

[1]: https://www.azul.com/
[2]: https://hub.docker.com/r/schnell18/zulu-jre/
