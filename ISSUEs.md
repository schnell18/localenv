# run ElasticSearch

Got error as follows:

    Error: crun: setrlimit `RLIMIT_MEMLOCK`: Operation not permitted: OCI permission denied
    exit code: 126

podman is configured with runtime `crun`.

ElasticSearch will try to bootstrap check system level limit and change limit
at runtime. However, this is privilleged operation which is forbidden by rootless
container runtime podman uses.
