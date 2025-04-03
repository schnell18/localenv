source .infra/global/libs/functions.sh

# podman volume inspect logs-vol > /dev/null 2>&1
# if [[ $? -ne 0 ]]; then
#     echo "Creating share volumes for logs under .state/logs ..."
#     podman volume create --driver local \
#         --opt type=none \
#         --opt device=.state/logs \
#         --opt o=bind logs-vol
# fi


if [[ ! -d .state/filebeat/logs-vol ]]; then
    mkdir -p .state/filebeat/logs-vol
fi

