source provision/global/libs/functions.sh

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

if [ $databaseReady -eq 1 ]; then
    echo "Run Mariadb post setup for infrastructure powerjob..."
    refresh_infra_db $dbContainer powerjob
else
    echo "$dbtype is not working, try to setup database later!!!"
fi
