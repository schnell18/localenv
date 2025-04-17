# run ElasticSearch

Got error as follows:

    Error: crun: setrlimit `RLIMIT_MEMLOCK`: Operation not permitted: OCI permission denied
    exit code: 126

podman is configured with runtime `crun`.

ElasticSearch will try to bootstrap check system level limit and change limit
at runtime. However, this is privilleged operation which is forbidden by rootless
container runtime podman uses.

# podman-compose fail to enforce the `service_healthy` condition

Previously, podman-compose doesn't handle conditions of dependency services properly as reported
by [Fails to handle the service_healthy condition of a depends_on element][1] and [compose fails
with depends_on:service_healthy with various errors][2]. As of podman-compose 1.3.0, with the merge
of [PR #1082 Provide support for conditional dependencies][3], podman-compose supports various
dependency conditions and enforces the constraints. Specifically, it uses the `run` method to create
and start the containers w/o check dependency conditions in first pass. Then it calls the
`run_container()` where the container is started only if the conditions of its dependencies are
satisfied. This implementation is problematic with a few issues:

- Containers with dependencies that should enter into healthy state are started prematurely,
resulting in potential startup failure of the containers that tightly coupled with their
dependencies
- The `check_dep_conditions()` function doesn't take into account the fact that podman prior to
4.6.0 doesn't support --condition=healthy, leading to infinite loop in this function
- A third problem is that podman-compose attempts to stop and remove the containers defined in the
compose file when the `--force-recreate` option is specified when there are no running containers at
all.

An example is included in this issue to help reproduce and debug the aforementioned problem. This
example deploys a Java SpringBoot application backed by MySQL, which can only startup properly when
the MySQL database is ready to connect. The current implementation `run` the MySQL and Java
containers at the same time. Therefore, the Java application fails to startup in its first few
attempts.


The proposed fix is to employ the create-and-start approach, where the containers are created in the
first pass, then they are started using the `run_container()` method to make sure the dependencies'
conditions are checked. The second fix is to add a version check to skip "podman wait
--condition=health" in the `check_dep_conditions()` function to prevent podman-compose hang. BTW,
this PR also fixes a minor problem that podman-compose attempts to stop and remove the containers
defined in the compose file when the `--force-recreate` option is specified when there are no
running containers at all.

## podman-compose github action test error

The podman-compose project runs integration tests with a containerized podman 4.3.1 based on debian
12 image. Services condition on dependency healthy can't run properly as the healthcheck can't
finish properly within a container where systemd is absent. Error message looks like:

    failed to connect to syslog: Initialization
    time="2025-04-14T04:27:51Z" level=error msg="unable to get systemd connection to add healthchecks: dial unix /run/systemd/private: connect: no such file or directory"
    time="2025-04-14T04:27:51Z" level=error msg="unable to get systemd connection to start healthchecks: dial unix /run/systemd/private: connect: no such file or directory"
    deps_web_1
    7e74b2c3398140adcb536726b9180d02d8c1e9aa46a60879afcb5e5806268956

Real rootcause is the `podman wait` doesn't support the healthy condition, however, the
`check_dep_conditions()` function doesn't take account into this and enters infinite loop.

[1]: https://github.com/containers/podman-compose/issues/866
[2]: https://github.com/containers/podman-compose/issues/1119
[3]: https://github.com/containers/podman-compose/pull/1082

