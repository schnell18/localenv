source provision/global/libs/functions.sh

if [[ ! -d .state/wekan/data ]]; then
    mkdir -p .state/wekan/data
    chmod o+w .state/wekan/data
fi

