source .infra/global/libs/functions.sh

usage() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Usage:
  appctl.sh build app1 [app2 app3 ...]
            start app1 [app2 app3 ...]
            stop app1 [app2 app3 ...]
            refresh-db app1 [app2 app3 ...]
            logs app1 [app2 app3 ...]
            validate app1 [app2 app3 ...]
            attach app1
            list
EOF
}

usage_refresh_db() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
This command recreate and reload database of specified apps from source.
Usage:
    appctl.sh refresh-db app1 [app2 app3 ...]
EOF
}

usage_list() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
List available applications managed by virtual environment.
Usage:
    appctl.sh list
EOF
}

usage_attach() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
Attach to running app and get a login shell.
Usage:
    appctl.sh attach app
EOF
}

usage_build() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
This command builds container image of specified apps from source.
Usage:
    appctl.sh build app1 [app2 app3 ...]
EOF
}

usage_start() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
This command start container of specified apps.
Usage:
    appctl.sh starts app1 [app2 app3 ...]
EOF
}

usage_stop() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
This command stops container of specified apps.
Usage:
    appctl.sh stop app1 [app2 app3 ...]
EOF
}

usage_validate() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
This command validate specified apps.
Usage:
    appctl.sh validate app1 [app2 app3 ...]
EOF
}

usage_logs() {
    cat <<EOF
Infrastructure control tool for Virtual development environment.
Crafted by Justin Zhang <schnell18@gmail.com>
This command continuously shows logs from specified apps.
Usage:
    appctl.sh logs app1 [app2 app3 ...]
EOF
}

build() {

    ARG=$1
    if [[ -z $ARG ]]; then
        usage_build
        exit 1
    fi

    ID_FILE=""
    if [[ -f ~/.ssh/id_ed25519 ]]; then
        ID_FILE=id_ed25519
    elif [[ -f ~/.ssh/id_ecdsa ]]; then
        ID_FILE=id_ecdsa
    elif [[ -f ~/.ssh/id_rsa ]]; then
        ID_FILE=id_rsa
    else
        echo "Please setup ssh key to access git properly!"
        exit 2
    fi

    for APP in $@; do
        if [[ ! -d ./.apps/$APP ]]; then
            echo "Project '$APP' does not exist under .apps!"
            exit 3
        fi
    done

    all_compose_files=""
    for file in *-*.yml; do
        all_compose_files="$all_compose_files -f $file"
    done

    for APP in $@; do
        TMP_PRIV_DIR="./.apps/$APP/.ssh"
        TMP_PRIV_FILE="$TMP_PRIV_DIR/$ID_FILE"
        mkdir -p $TMP_PRIV_DIR
        cp ~/.ssh/$ID_FILE $TMP_PRIV_FILE

        TMP_MVN_DIR="./.apps/$APP/.m2"
        if [[ -f ~/.m2/settings.xml ]]; then
            mkdir -p $TMP_MVN_DIR
            TMP_MVN_SETTINGS="./.apps/$APP/.m2/settings.xml"
            cp ~/.m2/settings.xml $TMP_MVN_SETTINGS
        fi

        podman-compose $all_compose_files build --build-arg ID_FILE=$ID_FILE $APP

        rm -fr $TMP_PRIV_DIR
        rm -fr $TMP_MVN_DIR
    done
}

attach() {

    ARG=$1
    if [[ -z $ARG ]]; then
        usage_attach
        exit 1
    fi

    podman-compose -f "app-${ARG}.yml" exec $ARG sh

}

list() {
    for file in app-*; do
        if [[ $file =~ ^app-(.+).yml$ ]]; then
            echo ${BASH_REMATCH[1]}
        fi
    done;
}

start() {
    if [[ -z $1 ]]; then
        usage_start
        exit 1
    fi

    all_compose_files=""
    for file in *-*.yml; do
        all_compose_files="$all_compose_files -f $file"
    done

    all_apps=""
    for app in $@; do
        all_apps="$all_apps $app"
    done
    podman-compose $all_compose_files up -d $all_apps

    # do app-specific post setup
    for app in $@; do
        if [[ -f provision/apps/$app/post/setup.sh ]]; then
            echo "Run post setup script for $app..."
            sh provision/apps/$app/post/setup.sh
        fi
    done

}

stop() {
    if [[ -z $1 ]]; then
        usage_stop
        exit 1
    fi

    all_compose_files=""
    for file in *-*.yml; do
        all_compose_files="$all_compose_files -f $file"
    done

    all_apps=""
    for app in $@; do
        all_apps="$all_apps $app"
    done
    podman-compose $all_compose_files stop $all_apps
}

logs() {
    if [[ -z $1 ]]; then
        usage_logs
        exit 1
    fi

    all_compose_files=""
    for file in *-*.yml; do
        all_compose_files="$all_compose_files -f $file"
    done

    all_apps=""
    for app in $@; do
        all_apps=" $app"
    done

    podman-compose $all_compose_files logs -f $all_apps
}

validate() {
    if [[ -z $1 ]]; then
        usage_validate
        exit 1
    fi

    basedir=$(pwd)
    for app in $@; do
        echo "Validating $app..."
        PWD=$(pwd)
        app_dir="$basedir/provision/$app"
        cd $app_dir
        if [[ -f $app_dir/validate.sh ]]; then
            echo "Validating running status for project: $app"
            sh $app_dir/validate.sh
        fi
        cd $PWD
    done

}

refresh_db() {
    # make state directories exist
    if [[ ! -d .state ]]; then
        mkdir .state
    fi

    # provision databases for backend service
    databaseReady=0

    dbContainer=$(podman ps -f label=database=true -q)
    if [[ -z $dbContainer ]]; then
        echo "Database is not ready..."
        exit 1
    fi

    dbType=$(podman inspect -f {{.Config.Labels.dbtype}} $dbContainer)
    printf "Checking $dbType readiness"
    for attempt in {1..20}; do
        printf "."
        stat=$(getDatabaseStatus $dbContainer $dbType)
        if [[ $stat == *"running"* ]]; then
            echo ""
            echo "$dbType is ready!"
            databaseReady=1
            break;
        fi
        sleep 1
    done

    basedir=$(pwd)
    if [ $databaseReady -eq 1 ]; then
        for app in $basedir/.apps/*/; do
            if [[ $# == 0 || $* =~ $(basename $app) ]]; then
                PWD=$(pwd)
                cd $app
                if [ -f project_root/schema/schema.sql ]; then
                    db=$(head -3 project_root/schema/schema.sql | grep -i USE | head -1 | cut -d' ' -f2 | sed 's/;//')
                    echo "Prepare database ${db} for project $(basename $app)..."
                    podman exec -it ${dbContainer} /bin/sh /setup/create-database.sh $db localenv
                    echo "Loading schema and data using podman for project $(basename $app)..."
                    podman exec -it ${dbContainer} /bin/sh /setup/load-schema-and-data.sh $(basename $app) localenv $db .apps
                fi
                cd $PWD
            fi
        done;
    else
        echo "$dbtype is not working, try to setup database later!!!"
    fi
}


cmd=$1
if [[ -z $cmd ]]; then
    usage
    exit 1
fi
shift
case "${cmd}" in
    build)      build $@;;
    start)      start $@;;
    stop)       stop $@;;
    logs)       logs $@;;
    list)       list $@;;
    attach)     attach $@;;
    validate)   validate $@;;
    refresh-db) refresh_db $@;;
    *) usage && exit 1;;
esac
