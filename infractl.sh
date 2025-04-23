#!/bin/bash

source .infra/global/libs/functions.sh
source .infra/global/libs/libinfractl.sh


cmd=$1
if [[ -z $cmd ]]; then
    usage
    exit 1
fi
shift
case "${cmd}" in
    start)       start $@;;
    stop)        stop $@;;
    status)      status $@;;
    attach)      attach $@;;
    list)        list $@;;
    init)        init $@;;
    destroy)     destroy $@;;
    logs)        logs $@;;
    webui)       webui $@;;
    refresh-db)  refresh_db $@;;
    *) usage && exit 1;;
esac
