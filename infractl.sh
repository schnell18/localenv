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
                webui infra1 [infra2 infra3 ...]
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
    if [[ $PROFILE -eq "all" ]]; then
        for file in docker-compose-*; do
            compose_files="$compose_files -f $file"
        done;
    else
        for infra in $@; do
            compose_files="$compose_files -f docker-compose-infra-${infra}.yml"
        done
    fi
    docker-compose $compose_files ps

}

stop() {
    PROFILE=$1
    if [[ -z $PROFILE ]]; then
        usage_stop
        exit 1
    fi

    compose_files=""
    if [[ $PROFILE -eq "all" ]]; then
        for file in docker-compose-*; do
            compose_files="$compose_files -f $file"
        done;
    else
        for infra in $@; do
            compose_files="$compose_files -f docker-compose-infra-${infra}.yml"
        done
    fi
    docker-compose $compose_files down

}

list() {
    for file in docker-compose-infra-*; do
        if [[ $file =~ ^docker-compose-infra-(.+).yml$ ]]; then
            echo ${BASH_REMATCH[1]}
        fi
    done;
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
                xdg-open $url
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
        compose_files="$compose_files -f docker-compose-infra-${infra}.yml"
    done
    echo $compose_files > .state/compose-files.txt

    # start containers managed by docker-compose
    docker-compose $compose_files up -d --force-recreate

    # do infra-specific post setup
    for infra in $@; do
        if [[ -f provision/$infra/post/setup.sh ]]; then
            echo "Run post setup script for $infra..."
            sh provision/$infra/post/setup.sh
        fi
        if [[ -f provision/$infra/post/webui.sh ]]; then
            echo "Launch webui for $infra..."
            url=$(sh provision/$infra/post/webui.sh)
            if [[ ! -z $url ]]; then
                xdg-open $url
            fi
        fi
    done

}

refresh_db() {
    if [[ -z $1 ]]; then
        usage_refresh_db
        exit 1
    fi

    refresh_infra_db $@

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
    list)        list $@;;
    webui)       webui $@;;
    refresh-db)  refresh_db $@;;
    *) usage && exit 1;;
esac
