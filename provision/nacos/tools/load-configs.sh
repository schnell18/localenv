# script to load static/dynamic configuration into nacos
# !!! DO NOT RELOCATE THIS FILE !!!

# create dev namespace
curl -s -X POST 'http://nacos:8848/nacos/v1/console/namespaces' \
     -d 'customNamespaceId=dev&namespaceName=dev&namespaceDesc=development'

pushd ../../../ > /dev/null
basedir=$(pwd)
for app_dir in $basedir/backends/*/; do
    app=$(basename $app_dir)
    if [[ $# == 0 || $* =~ $app ]]; then
        pushd $app_dir > /dev/null
        static_conf="${app}-impl/src/main/resources/application-virtualenv.yml"
        if [ -f $static_conf ]; then
    	echo "Load static config into nacos for project $app..."
            CONTENT=$(cat $static_conf | xxd -p | tr -d \\n | sed 's/../%&/g')
            curl -s -XPOST 'http://nacos:8848/nacos/v1/cs/configs' \
                 --data-urlencode tenant=dev                       \
                 --data-urlencode dataId=${app}-static.yaml        \
                 --data-urlencode group=DEFAULT_GROUP              \
                 --data-urlencode type=yaml                        \
                 --data content=$CONTENT > /dev/null
        fi
        dynamic_conf="${app}-impl/src/main/resources/dynamic.yml"
        if [ -f $dynamic_conf ]; then
    	echo "Load dynamic config into nacos for project $app..."
            CONTENT=$(cat $dynamic_conf | xxd -p | tr -d \\n | sed 's/../%&/g')
            curl -s -XPOST 'http://nacos:8848/nacos/v1/cs/configs' \
                 --data-urlencode tenant=dev                       \
                 --data-urlencode dataId=${app}-dynamic.yaml       \
                 --data-urlencode group=DEFAULT_GROUP              \
                 --data-urlencode type=yaml                        \
                 --data content=$CONTENT > /dev/null
        fi
        popd > /dev/null
    fi
done;
popd > /dev/null
