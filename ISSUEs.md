# run ElasticSearch

Got error as follows:

    Error: crun: setrlimit `RLIMIT_MEMLOCK`: Operation not permitted: OCI permission denied
    exit code: 126

podman is configured with runtime `crun`.

ElasticSearch will try to bootstrap check system level limit and change limit
at runtime. However, this is privilleged operation which is forbidden by rootless
container runtime podman uses.

# podman-compose fail to enforce the `service_healthy` condition

Previously, podman-compose doesn't handle the condition of dependency services
properly as reported by [Fails to handle the service_healthy condition of a
depends_on element][1] and [compose fails with depends_on:service_healthy with
various errors][2]. As of podman-compose 1.3.0, with the merge of [PR #1082
Provide support for conditional dependencies][3], podman-compose supports
various dependency conditions and enforces the constraints. However, the
implementation in the `compose_up` function is problematic as it uses `run`
method to create and start the containers w/o check dependency conditions in
first pass. Then it calls the `run_container()` where the container is started
only if the conditions of its dependencies are satisfied. In this
implementation, containers with dependencies that should enter the healthy
state are started regardless the conditions of their dependencies, resulting
in unsuccessful startup. For example, assume we have a Java SpringBoot
application backed by MySQL, which can only startup properly when the MySQL
database is ready to connect. The current implementation `run` the MySQL and
Java containers at the same time. Therefore, the Java application fails to
startup in its first few attempts. The proposed fix is to employ the
create-and-start approach, where the containers are created in the first pass,
then they are started using the `run_container()` method to make sure the
dependencies' conditions are checked.
BTW, this PR also fixes a minor problem that podman-compose attempts to
shutdown the containers listed in the compose file when the `--force-recreate`
option is specified and there are no running containers.

[1]: https://github.com/containers/podman-compose/issues/866
[2]: https://github.com/containers/podman-compose/issues/1119
[3]: https://github.com/containers/podman-compose/pull/1082
