if [ -f /work/.state/active-infras.txt ]; then
    # remove the leading space and carriage char to improve Windows compatibility
    infras=$(cat /work/.state/active-infras.txt | sed -e 's/^ //' | tr -d "\r")
    for infra in $infras; do
        if [ $infra != "mariadb" ]; then
            sh /setup/create-database.sh $infra mfg
            sh /setup/load-schema-and-data.sh $infra mfg $infra ".infra"
        fi
    done
fi

