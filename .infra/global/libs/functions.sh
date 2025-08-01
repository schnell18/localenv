function getHostIP {
    case `uname` in
        Darwin) ipconfig getifaddr en0 ;;
        # Darwin) podman machine ssh localenv ip route get 8.8.8.8 | head -1 | cut -d' ' -f7 ;;
        Linux) ip route get 8.8.8.8 | head -1 | cut -d' ' -f7 ;;
        *) echo ""
    esac
}

function getDatabaseStatus {
    port=$(toDatabasePort $2)
    if [[ $2 == TiDB ]]; then
        podman exec $1 sh -c "echo select \'running\' | mysql -N -h 127.0.0.1 -P $port -u root" 2>/dev/null
    elif [[ $2 == PostgreSQL ]]; then
        podman exec $1 sh -c "PGPASSWORD=localenv psql -h 127.0.0.1 -p $port -U localenv -d localenv -c 'SELECT '\''running'\'' as status' -t" 2>/dev/null
    else
        podman exec $1 sh -c "echo select \'running\' | mysql -N -h 127.0.0.1 -P $port -u root -proot" 2>/dev/null
    fi
}

function waitDatabaseReady {
    databaseReady=0
    dbContainer=$(podman ps -f label=database=true -q)
    if [[ -z $dbContainer ]]; then
        echo "Database is not ready..."
        echo 0
        return
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
    echo $databaseReady
}

function toDatabasePort {
    dbType=$1
    result=3306
    case $dbType in
        TiDB)
            result="4000"
            ;;
        MariaDB)
            result="3306"
            ;;
        PostgreSQL)
            result="5432"
            ;;
        *)
            result="3306"
            ;;
    esac
    echo $result
}

function refresh_infra_db {
    dbContainer=$1
    shift

    basedir=$(pwd)
    for infra in $@; do
        PWD=$(pwd)
        cd $basedir/.infra/$infra/provision
        if [ -f schema/schema.sql ]; then
            db=$(head -1 schema/schema.sql | cut -d' ' -f2 | sed 's/;//')
            echo "Prepare database ${db} for infra $(basename $infra)..."
            podman exec -it ${dbContainer} /bin/sh /setup/create-database.sh $db mfg
            echo "Loading schema and data using podman for project $(basename $infra)..."
            podman exec -it ${dbContainer} /bin/sh /setup/load-schema-and-data.sh $(basename $infra) mfg $db .infra
        fi
        cd $PWD
    done;

}

function setup_job_scheduler {
    app=$1
    pass=$2

    # check if job scheduler is running
    jobSchedulerContainer=$(podman ps -f label=job_scheduler=true -q)
    if [[ -z $jobSchedulerContainer ]]; then
        echo "Job scheduler is not running, skip app registration"
    else
        exist=$(curl -s "http://127.0.0.1:7700/appInfo/list?condition=${app}" | jq -r '.data[] | .appName')
        if [[ ! $exist = ${app} ]]; then
            printf "Setup PowerJob app $app ..."
            ret=$(curl -s -H 'Content-Type: application/json' 'http://127.0.0.1:7700/appInfo/save' --data-raw \{\"appName\":\"${app}\",\"password\":\"${pass}\"\} | jq '.success' | grep true)
            if [[ -z $ret ]]; then
                echo "FAILED"
            else
                echo "OK"
            fi
        fi
    fi

}

function load_config_into_nacos {
    config=$1
    dataId=$2
    CONTENT=$(cat $config | xxd -p | tr -d \\n | sed 's/../%&/g')
    curl -s -XPOST 'http://nacos:8848/nacos/v1/cs/configs' \
         --data-urlencode tenant=dev                       \
         --data-urlencode dataId=${dataId}                 \
         --data-urlencode group=DEFAULT_GROUP              \
         --data-urlencode type=yaml                        \
         --data content=$CONTENT > /dev/null

}

function open_browser {
    url=$1
    os=$(uname)
    case $os in
        Darwin) open $url;;
        Linux) xdg-open $url;;
        *) echo "Unsupported OS: $os"
    esac
}


function check_database_exists {
    port=$(toDatabasePort $2)
    database=$3
    result="true"
    if [[ $2 == TiDB ]]; then
        ret=$(podman exec $1 sh -c "echo show databases | mysql -N -h 127.0.0.1 -P $port -u root | grep $database" 2>/dev/null)
        if [[ -z $ret ]]; then
            result="false"
        fi
    elif [[ $2 == PostgreSQL ]]; then
        ret=$(podman exec $1 sh -c "PGPASSWORD=localenv psql -h 127.0.0.1 -p $port -U localenv -d postgres -lqt | cut -d \| -f 1 | grep -w $database" 2>/dev/null)
        if [[ -z $ret ]]; then
            result="false"
        fi
    else
        ret=$(podman exec $1 sh -c "echo show databases | mysql -N -h 127.0.0.1 -P $port -u root -proot | grep $database" 2>/dev/null)
        if [[ -z $ret ]]; then
            result="false"
        fi
    fi
    echo $result
}


function setup_topic {
    TOPICS=$1
    # check if broker is running
    mqBrokerContainer=$(podman ps -f label=mq_broker=true -q)
    if [[ -z $mqBrokerContainer ]]; then
        echo "RocketMQ broker is not running, skip topic creation"
    else
        for t in $TOPICS; do
            echo "Setup RocketMQ topic $t ..."
            podman exec -it ${mqBrokerContainer} \
                sh /home/rocketmq/rocketmq-4.9.2/bin/mqadmin updateTopic \
                   -c devCluster -t $t -w 4 -r 4 > /dev/null
        done
    fi
}

function get_descrptior_file_paths {
    if [[ $1 == "all" ]]; then
        for file in .infra/*/descriptor.yml; do
            compose_files="$compose_files -f $(pwd)/$file"
        done;
    else
        for infra in $@; do
            compose_files="$compose_files -f $(pwd)/.infra/${infra}/descriptor.yml"
        done
    fi
    echo $compose_files
}
