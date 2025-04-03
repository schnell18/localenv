source .infra/global/libs/functions.sh

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

    CURRENT_PROFILES_STAT_FILE=".state/compose-files.txt"
    compose_files=""
    if [[ -f $CURRENT_PROFILES_STAT_FILE ]]; then
      compose_files=$(cat $CURRENT_PROFILES_STAT_FILE)
    else
      PROFILE=$1
      if [[ -z $PROFILE ]]; then
          usage_stop
          exit 1
      fi
      compose_files=$(get_descrptior_file_paths $PROFILE)
    fi

    podman-compose $compose_files ps
}

stop() {

    CURRENT_PROFILES_STAT_FILE=".state/compose-files.txt"
    compose_files=""
    if [[ -f $CURRENT_PROFILES_STAT_FILE ]]; then
      compose_files=$(cat $CURRENT_PROFILES_STAT_FILE)
      podman-compose $compose_files down
      # remove the profile stat file to cleanup
      rm $CURRENT_PROFILES_STAT_FILE
    else
      PROFILE=$1
      if [[ -z $PROFILE ]]; then
          usage_stop
          exit 1
      fi
      compose_files=$(get_descrptior_file_paths $PROFILE)
      podman-compose $compose_files down
    fi

}

list() {
    for file in .infra/*/descriptor.yml; do
        if [[ $file =~ ^\.infra/(.+)/descriptor.yml$ ]]; then
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
        podman machine init localenv --memory 6144 --rootful -v $HOME:$HOME:rw,security_model=mapped-xattr --now
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
        if [[ -f .infra/$infra/provision/post/webui.sh ]]; then
            echo "Launch webui for $infra..."
            url=$(sh .infra/$infra/provision/post/webui.sh)
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
        if [[ -f .infra/$infra/provision/pre/prepare.sh ]]; then
            echo "Run prepare script for $infra..."
            sh .infra/$infra/provision/pre/prepare.sh
        fi
        compose_files="$compose_files -f $(pwd)/.infra/${infra}/descriptor.yml"
    done
    echo $compose_files > .state/compose-files.txt

    # start containers managed by podman
    podman-compose $compose_files up -d --force-recreate
    # podman-compose --podman-run-args '--user 501' $compose_files up -d --force-recreate

    # do infra-specific post setup
    for infra in $@; do
        if [[ -f .infra/$infra/provision/post/setup.sh ]]; then
            echo "Run post setup script for $infra..."
            sh .infra/$infra/provision/post/setup.sh
        fi
    done

    for infra in $@; do
        if [[ -f .infra/$infra/provision/post/webui.sh ]]; then
            echo "Launch webui for $infra..."
            url=$(sh .infra/$infra/provision/post/webui.sh)
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

    CURRENT_PROFILES_STAT_FILE=".state/compose-files.txt"
    if [[ -f $CURRENT_PROFILES_STAT_FILE ]]; then
      compose_files=$(cat $CURRENT_PROFILES_STAT_FILE)
      podman-compose $compose_files exec $ARG sh
    fi


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

    CURRENT_PROFILES_STAT_FILE=".state/compose-files.txt"
    if [[ -f $CURRENT_PROFILES_STAT_FILE ]]; then
      compose_files=$(cat $CURRENT_PROFILES_STAT_FILE)
      podman-compose $compose_files exec $ARG sh
      all_infras=""
      for infra in $@; do
          all_infras=" $infra"
      done
      podman-compose $compose_files logs -f $all_infras
    fi

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
