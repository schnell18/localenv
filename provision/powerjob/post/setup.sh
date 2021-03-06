source provision/global/libs/functions.sh

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

if [ $databaseReady -eq 1 ]; then
    initialized=$(check_database_exists $dbContainer $dbType, powerjob)
    if [[ $initialized == 'false' ]]; then
        echo "Run database setup for infrastructure powerjob..."
        refresh_infra_db $dbContainer powerjob
    else
        echo "Skip database setup for infrastructure powerjob..."
    fi
else
    echo "$dbtype is not working, try to setup database later!!!"
fi
