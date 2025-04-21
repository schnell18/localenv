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

## MariaDB setup script doesn't work in Powershell on Windows

The `setup-infra-databases.sh` script under the `/docker-entrypoint-initdb.d`
directory is intended to create database, load schema and data for the active
middlewares that require a database component. The active infras are recorded
in the `.state/active-infras.txt` which is generated using the OS-dependent
EOL. However, the `setup-infra-databases.sh` assumes the Unix/Linux style EOL.
As a result, on Windows the name of infra contains a invisible trailing
carriage return character, leading to bizarre message as follows:


    root@8f045e500115:/docker-entrypoint-initdb.d# bash setup-infra-databases.sh
    ...ating empty database nacos
    /setup/load-schema-and-data.sh: 43: cd: can't cd to /work/.infra/nacos

To diagnose this error, attaching to the MariaDB container and running the
script in debug mode reveal the root cause:

    root@8f045e500115:/docker-entrypoint-initdb.d# bash -x setup-infra-databases.sh
    + '[' -f /work/.state/active-infras.txt ']'
    ++ cat /work/.state/active-infras.txt
    ' infras=' mariadb nacos
    + for infra in $infras
    + '[' mariadb '!=' mariadb ']'
    + for infra in $infras
    + '[' $'nacos\r' '!=' mariadb ']'
    + sh /setup/create-database.sh $'nacos\r' mfg
    ...ating empty database nacos
    + sh /setup/load-schema-and-data.sh $'nacos\r' mfg $'nacos\r' .infra
    /setup/load-schema-and-data.sh: 43: cd: can't cd to /work/.infra/nacos

The root cause is failure to account for the EOL difference between Windows and
Linux. The fix is to convert the Windows EOL to Linux EOL in the
`setup-infra-databases.sh` script.

## podman port mapping listen only loopback interface on Windows

The redis-cluster creator connects to the host primary IP to establish
connection to a redis node in order to setup cluster. However, the connection
fails as the 7001 port on the host is listened on the loopback interface
rather than the primary network interface. It seems a limitation of podman
according to [this issue][4].

[1]: https://github.com/containers/podman-compose/issues/866
[2]: https://github.com/containers/podman-compose/issues/1119
[3]: https://github.com/containers/podman-compose/pull/1082
[4]: https://github.com/containers/podman/discussions/22065

