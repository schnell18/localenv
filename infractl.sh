source provision/global/libs/functions.sh

usage() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Usage:
    infractl.sh start infra1 [infra2 infra3 ...]
                stop all | infra1 [infra2 infra3 ...]
                status all | infra1 [infra2 infra3 ...]
                refresh-db infra1 [infra2 infra3 ...]
                logs infra1 [infra2 infra3 ...]
                webui infra1 [infra2 infra3 ...]
                init
                destroy
                list
EOF
}

usage_list() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
List available infrastructure database/middleware.
Usage:
    infractl.sh list
EOF
}

usage_init() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Initialize local environment.
Usage:
    infractl.sh init
EOF
}

usage_destroy() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Destroy local environment forcefully.
Usage:
    infractl.sh destroy
EOF
}

usage_attach() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Attach to running infra and get a login shell.
Usage:
    infractl.sh attach infra
EOF
}

usage_logs() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
This command continuously shows logs from specified infra.
Usage:
    infractl.sh logs infra1 [infra2 infra3 ...]
EOF
}

usage_refresh_db() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Usage:
    infractl.sh refresh-db infra1 [infra2 infra3 ...]
EOF
}

usage_start() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Usage:
    infractl.sh start infra1 [infra2 infra3 ...]
EOF
}

usage_status() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Usage:
    infractl.sh status all | infra1 [infra2 infra3 ...]
EOF
}

usage_webui() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Launch webui of specified infrastructures.
Usage:
    infractl.sh webui infra1 [infra2 infra3 ...]
EOF
}

usage_stop() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Usage:
    infractl.sh stop infra1 [infra2 infra3 ...]
EOF
}

status() {
    PROFILE=$1
    if [[ -z $PROFILE ]]; then
        usage_status
        exit 1
    fi

    compose_files=""
    if [[ $PROFILE == "all" ]]; then
        for file in *-*; do
            compose_files="$compose_files -f $file"
        done;
    else
        for infra in $@; do
            compose_files="$compose_files -f infra-${infra}.yml"
        done
    fi
    podman-compose $compose_files ps

}

stop() {
    PROFILE=$1
    if [[ -z $PROFILE ]]; then
        usage_stop
        exit 1
    fi

    compose_files=""
    if [[ $PROFILE == "all" ]]; then
        for file in *-*; do
            compose_files="$compose_files -f $file"
        done;
    else
        for infra in $@; do
            compose_files="$compose_files -f infra-${infra}.yml"
        done
    fi
    podman-compose $compose_files down

}

list() {
    for file in infra-*; do
        if [[ $file =~ ^infra-(.+).yml$ ]]; then
            echo ${BASH_REMATCH[1]}
        fi
    done;
}

init() {
    if [[ `uname` == 'Darwin' ]]; then
        # podman machine init localenv --rootful --image-path /Users/user/.local/share/containers/podman/machine/qemu/fedora-coreos-36.20220511.dev.0-qemu.aarch64.qcow2.xz -v $HOME:$HOME --now
        # podman machine init localenv --image-path /Users/user/.local/share/containers/podman/machine/qemu/fedora-coreos-36.20220511.dev.0-qemu.aarch64.qcow2.xz -v $HOME:$HOME --now
        # podman machine init localenv --rootful --image-path https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/36.20221030.3.0/x86_64/fedora-coreos-36.20221030.3.0-qemu.x86_64.qcow2.xz -v $HOME:$HOME --now

        # podman machine init localenv --rootful --image-path stable -v $HOME:$HOME --now
        podman machine init localenv --rootful --image-path stable -v $HOME:$HOME:rw,security_model=mapped-xattr --now
        # Install qemu for multi-arch container image build
        podman machine ssh --username root localenv rpm-ostree install qemu-user-static
        podman machine stop localenv
        podman machine start localenv
        podman system connection default localenv-root
    elif [[ `uname` == 'Linux' ]]; then
        # Create user owned unix domain socket
        systemctl enable --now --user podman.socket
    fi
}

destroy() {
    if [[ `uname` == 'Darwin' ]]; then
        podman machine rm localenv --force
    fi
}

webui() {
    if [[ -z $1 ]]; then
        usage_webui
        exit 1
    fi

    # do infra-specific post setup
    for infra in $@; do
        if [[ -f provision/$infra/post/webui.sh ]]; then
            echo "Launch webui for $infra..."
            url=$(sh provision/$infra/post/webui.sh)
            if [[ ! -z $url ]]; then
                open_browser $url
            fi
        fi
    done
}

start() {
    PROFILE=$1
    if [[ -z $PROFILE ]]; then
        usage_start
        exit 1
    fi

    # make state directories exist
    if [[ ! -d .state ]]; then
        mkdir .state
    fi

    compose_files=""
    for infra in $@; do
        if [[ -f provision/$infra/pre/prepare.sh ]]; then
            echo "Run prepare script for $infra..."
            sh provision/$infra/pre/prepare.sh
        fi
        compose_files="$compose_files -f infra-${infra}.yml"
    done
    echo $compose_files > .state/compose-files.txt

    # start containers managed by podman
    podman-compose $compose_files up -d --force-recreate
    # podman-compose --podman-run-args '--user 501' $compose_files up -d --force-recreate

    # do infra-specific post setup
    for infra in $@; do
        if [[ -f provision/$infra/post/setup.sh ]]; then
            echo "Run post setup script for $infra..."
            sh provision/$infra/post/setup.sh
        fi
    done

    for infra in $@; do
        if [[ -f provision/$infra/post/webui.sh ]]; then
            echo "Launch webui for $infra..."
            url=$(sh provision/$infra/post/webui.sh)
            if [[ ! -z $url ]]; then
                open_browser $url
            fi
        fi
    done

}

attach() {

    ARG=$1
    if [[ -z $ARG ]]; then
        usage_attach
        exit 1
    fi

    compose_files=""
    for file in infra-*; do
        compose_files="$compose_files -f $file"
    done;

    podman-compose $compose_files exec $ARG sh

}

refresh_db() {
    if [[ -z $1 ]]; then
        usage_refresh_db
        exit 1
    fi

    refresh_infra_db $@

}

logs() {
    if [[ -z $1 ]]; then
        usage_logs
        exit 1
    fi

    all_compose_files=""
    for file in infra-*.yml; do
        all_compose_files="$all_compose_files -f $file"
    done

    all_infras=""
    for infra in $@; do
        all_infras=" $infra"
    done

    podman-compose $all_compose_files logs -f $all_infras
}

cmd=$1
if [[ -z $cmd ]]; then
    usage
    exit 1
fi
shift
case "${cmd}" in
    start)       start $@;;
    stop)        stop $@;;
    status)      status $@;;
    attach)      attach $@;;
    list)        list $@;;
    init)        init $@;;
    destroy)     destroy $@;;
    logs)        logs $@;;
    webui)       webui $@;;
    refresh-db)  refresh_db $@;;
    *) usage && exit 1;;
esac
