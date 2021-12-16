function getHostIP {
    case `uname` in
        Darwin) ipconfig getifaddr en0 ;;
        Linux) ip route get 8.8.8.8 | head -1 | cut -d' ' -f7 ;;
        *) echo ""
    esac
}

function getDatabaseStatus {
    port=$(toDatabasePort $2)
    docker exec $1 sh -c "echo select \'running\' | mysql -N -h 127.0.0.1 -P $port -u root -proot"
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
        *)
            result="3306"
            ;;
    esac
   echo $result
}

function refresh_infra_db {

    # provision databases for backend service
    databaseReady=0

    dbContainer=$(docker ps -f label=database=true -q)
    if [[ -z $dbContainer ]]; then
        echo "Database is not ready..."
        exit 1
    fi

    dbType=$(docker inspect -f {{.Config.Labels.dbtype}} $dbContainer)
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
        if [[ $# == 0 ]]; then
            for infra in $basedir/provision/*/; do
                PWD=$(pwd)
                cd $infra
                if [ -f schema/schema.sql ]; then
                    db=$(head -1 schema/schema.sql | cut -d' ' -f2 | sed 's/;//')
                    echo "Prepare database ${db} for infra $(basename $infra)..."
                    docker exec -it ${dbContainer} /bin/sh /setup/create-database.sh $db mfg
                    echo "Loading schema and data using docker for project $(basename $infra)..."
                    docker exec -it ${dbContainer} /bin/sh /setup/load-schema-and-data.sh $(basename $infra) mfg $db provision
                fi
                cd $PWD
            done;
        else
            for infra in $@; do
                PWD=$(pwd)
                cd $basedir/provision/$infra
                if [ -f schema/schema.sql ]; then
                    db=$(head -1 schema/schema.sql | cut -d' ' -f2 | sed 's/;//')
                    echo "Prepare database ${db} for infra $(basename $infra)..."
                    docker exec -it ${dbContainer} /bin/sh /setup/create-database.sh $db mfg
                    echo "Loading schema and data using docker for project $(basename $infra)..."
                    docker exec -it ${dbContainer} /bin/sh /setup/load-schema-and-data.sh $(basename $infra) mfg $db provision
                fi
                cd $PWD
            done;
        fi
    else
        echo "$dbtype is not working, try to setup database later!!!"
    fi

}
