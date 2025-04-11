if [ -f /work/.state/active-infras.txt ]; then
    infras=$(cat /work/.state/active-infras.txt)
    for infra in $infras; do
        if [ $infra != "mariadb" ]; then
            sh /setup/create-database.sh $infra mfg
            sh /setup/load-schema-and-data.sh $infra mfg $infra ".infra"
        fi
    done
fi

