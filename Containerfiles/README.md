# Introduction

Projects to build multi-platform container images such as Java, golang etc.
Current focus of platforms are x86\_64 and Apple M1 chip. Images are made as
smaller as possible. Most images are based on [alpine][2].

## Catalog

| name               | repository                 | version                    | comment                             |
| ------------------ | -------------------------- | -------------------------- | ----------------------------------- |
| java-build         | docker.io/schnell18        | 17.0.3-3.8.6-2-alpine      | image to build Java application     |
| java-build         | docker.io/schnell18        | 8.0.332-3.8.5-5-alpine     | image to build Java app, x64 only   |
| java-runtime-jre   | docker.io/schnell18        | 17.0.3-17.34.19-3-alpine   | JRE runtime by [Azul][1]            |
| java-runtime-jdk   | docker.io/schnell18        | 17.0.3-17.34.19-3-alpine   | JDK runtime by [Azul][1]            |
| java-runtime-jre   | docker.io/schnell18        | 8.0.332-8.62.0.19-2-alpine | JRE runtime by [Azul][1], x64 only  |
| java-runtime-jdk   | docker.io/schnell18        | 8.0.332-8.62.0.19-2-alpine | JDK runtime by [Azul][1], x64 only  |
| golang-build       | docker.io/schnell18        | 1.17-4-alpine              | image to build golang application   |
| golang-runtime     | docker.io/schnell18        | 1.17-6-alpine              | golang application runtime image    |
| golang-build       | docker.io/schnell18        | 1.18-3-alpine              | image to build golang application   |
| golang-runtime     | docker.io/schnell18        | 1.18-6-alpine              | golang application runtime image    |

## Pre-requisite

This project requires:

- podman
- buildah

and qemu on Linux. The qemu package varies on different distributions. On
debian and RHEL it's named as `qemu-user-static`. While on Arch/Manjaro, it's
qemu-arch-extra. For example, to install the pre-requisite, you type:

    sudo pacman -Sy podman buildah qemu-arch-extra

On Fedora CoreOS, you type:

    rpm-ostree install qemu-user-static

## java-build

This image is based on zulu-jdk (azul version: 17.34.19, openjdk version:
17.0.3) and maven (v3.8.6).
Additional tools include:

- curl
- openssh-client
- bash

## java-runtime

This image is based on zulu-jre (alpine version: 3.15, azul version: 17.34.19,
openjdk version: 17.0.3) with additional tools such as:

- bash
- curl

## golang-build

This image is based on official golang apline image with additional features:

- local goproxy
- facilitate building with private golang repositories

## golang-runtime

This image is based on alpine with additional tools such as:

- dlv
- bash
- curl
- nc

[1]: https://www.azul.com/downloads/?package=jdk
[2]: https://alpinelinux.org/
