function getHostIP {
    case `uname` in
        Darwin) ipconfig getifaddr en0 ;;
        Linux) ip route get 8.8.8.8 | head -1 | cut -d' ' -f7 ;;
        *) echo ""
    esac
}

function getDatabaseStatus {
    port=$(toDatabasePort $2)
    if [[ $2 == TiDB ]]; then
        docker exec $1 sh -c "echo select \'running\' | mysql -N -h 127.0.0.1 -P $port -u root" 2>/dev/null
    else
        docker exec $1 sh -c "echo select \'running\' | mysql -N -h 127.0.0.1 -P $port -u root -proot" 2>/dev/null
    fi

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
    dbContainer=$1
    shift

    basedir=$(pwd)
    if [[ $# == 0 ]]; then
        for infra in $basedir/provision/*/; do
            PWD=$(pwd)
            cd $infra
            if [ -f schema/schema.sql ]; then
                db=$(head -3 schema/schema.sql | grep -i USE | head -1 | cut -d' ' -f2 | sed 's/;//')
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

}
