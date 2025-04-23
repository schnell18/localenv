get_python_version() {
    local python_paths=("python" "python3")
    for python_cmd in "${python_paths[@]}"; do
        if command -v "$python_cmd" &> /dev/null; then
            local ver_out
            ver_out=$("$python_cmd" --version 2>&1)
            if [ $? -eq 0 ]; then
                echo "$ver_out" | sed -E 's/[^0-9.]//g'
                return 0
            fi
        fi
    done
    return 1
}

check_podman_compose_dep() {
    /usr/bin/python -c 'import dotenv;import yaml' 2>&1
    if [ $? -ne 0 ]; then
        echo "Missing required python packages, install them now ..."
        pip install --user dotenv pyyaml
    fi
}

check_environment() {
    local req_py_major=3
    local req_py_minor=11
    # check if python is installed
    local py_ver=get_python_version
    if [ -z "$py_ver" ]; then
        echo "Python is not installed! Please install Python $req_py_major.$req_py_minor or above!"
        exit 1
    else
        local act_py_major
        local act_py_minor
        act_py_major=$(echo $py_ver | cut -d '.' -f1)
        act_py_minor=$(echo $py_ver | cut -d '.' -f2)

        if ! ([ "$act_py_major" -ge "$req_py_major" ] && [ "$act_py_minor" -ge "$req_py_minor" ]); then
            echo "Python version $act_py_major.$act_py_minor is not supported! Please install $req_py_major.$req_py_minor or above!"
            exit 1
        else
            # check if dotenv and pyyaml are installed
            check_podman_compose_dep
        fi
    fi

    if [[ `uname` == 'Darwin' ]]; then
        # check if machine exists and running
        local std_out_ls
        std_out_ls=$(podman machine ls -q)
        if echo "$std_out_ls" | grep -q "localenv"; then
            local std_out_insp
            std_out_insp=$(podman machine inspect localenv --format "{{range .}}{{.State}}{{end -}}")
            if ! echo "$std_out_insp" | grep -q "running"; then
                podman machine start localenv
            fi
        else
            echo "The machine `localenv` doesn't exist. Please run ./infractl.sh init to create the machine."
            exit 1
        fi
    fi
}

check_url_ready() {
    local url="$1"
    local max_retries="${2:-15}"
    local retry_interval="${3:-3}"

    local retry_count=0
    local success=false

    while [ $retry_count -lt $max_retries ] && [ "$success" = false ]; do
        retry_count=$((retry_count + 1))

        # Use curl with timeout, follow redirects, and only get the header
        http_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 --location "$url")

        # Check if status code is between 200 and 399
        if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 400 ]; then
            success=true
            break
        fi

        sleep "$retry_interval"
    done

    if [ "$success" = true ]; then
        echo "$url"
    else
        echo ""
    fi
}

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
            usage_status
            exit 1
        fi
        compose_files=$(get_descrptior_file_paths $PROFILE)
    fi

    bin/podman-compose $compose_files ps
}

stop() {

    CURRENT_PROFILES_STAT_FILE=".state/compose-files.txt"
    CURRENT_ACTIVE_INFRAS=".state/active-infras.txt"
    compose_files=""
    if [[ -f $CURRENT_PROFILES_STAT_FILE ]]; then
        compose_files=$(cat $CURRENT_PROFILES_STAT_FILE)
        bin/podman-compose $compose_files down
        # remove the profile stat file to cleanup
        if [ -f $CURRENT_PROFILES_STAT_FILE ]; then
            rm -f $CURRENT_PROFILES_STAT_FILE
        fi
        if [ -f $CURRENT_ACTIVE_INFRAS ]; then
            rm -f $CURRENT_ACTIVE_INFRAS
        fi
    else
        PROFILE=$1
        if [[ -z $PROFILE ]]; then
            usage_stop
            exit 1
        fi
        compose_files=$(get_descrptior_file_paths $PROFILE)
        bin/podman-compose $compose_files down
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
        if [[ -f .infra/$infra/provision/post/webui.txt ]]; then
            echo "Launch webui for $infra..."
            url=$(cat .infra/$infra/provision/post/webui.txt)
            # wait for url become ready
            url=$(check_url_ready $url)
            if [[ ! -z $url ]]; then
                open_browser $url
            fi
        fi
    done
}

start() {
    if [[ -z $1 ]]; then
        usage_start
        exit 1
    fi

    # make state directories exist
    if [[ ! -d .state ]]; then
        mkdir .state
    fi

    compose_files=""
    active_infras=""
    for infra in $@; do
        if [[ -f .infra/$infra/provision/pre/prepare.sh ]]; then
            echo "Run prepare script for $infra..."
            sh .infra/$infra/provision/pre/prepare.sh
        fi
        compose_files="$compose_files -f $(pwd)/.infra/${infra}/descriptor.yml"
        active_infras="$active_infras $infra"
    done
    echo $compose_files > .state/compose-files.txt
    echo $active_infras > .state/active-infras.txt

    # start containers managed by podman
    bin/podman-compose $compose_files up -d --force-recreate
    # bin/podman-compose --podman-run-args '--user 501' $compose_files up -d --force-recreate

    # do infra-specific post setup
    for infra in $@; do
        if [[ -f .infra/$infra/provision/post/setup.sh ]]; then
            echo "Run post setup script for $infra..."
            sh .infra/$infra/provision/post/setup.sh
        fi
    done

    for infra in $@; do
        if [[ -f .infra/$infra/provision/post/webui.txt ]]; then
            echo "Launch webui for $infra..."
            url=$(cat .infra/$infra/provision/post/webui.txt)
            # wait for url become ready
            url=$(check_url_ready $url)
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
        bin/podman-compose $compose_files exec $ARG sh
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
        bin/podman-compose $compose_files exec $ARG sh
        all_infras=""
        for infra in $@; do
            all_infras=" $infra"
        done
        bin/podman-compose $compose_files logs -f $all_infras
    fi

}
