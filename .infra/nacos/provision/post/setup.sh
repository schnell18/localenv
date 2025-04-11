source .infra/global/libs/functions.sh

# create dev namespace
curl -s -X POST 'http://localhost:8848/nacos/v1/console/namespaces' \
     -d 'customNamespaceId=dev&namespaceName=dev&namespaceDesc=development'

