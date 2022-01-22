source provision/global/libs/functions.sh

app=poincare
echo "Load static config into nacos for project $app..."
static_conf="backends/${app}/${app}-impl/src/main/resources/application-virtualenv.yml"
load_config_into_nacos $static_conf ${app}-static.yaml

echo "Load dynamic config into nacos for project $app..."
dynamic_conf="backends/${app}/${app}-impl/src/main/resources/dynamic.yml"
load_config_into_nacos $dynamic_conf ${app}-dynamic.yaml
