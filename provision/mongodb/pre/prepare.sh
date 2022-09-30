source provision/global/libs/functions.sh

if [[ ! -d .state/mongodb/data ]]; then
    mkdir -p .state/mongodb/data
    sudo chmod o+rwx .state/mongodb/data
fi

# if [[ ! -d .state/mongodb/logs ]]; then
#     mkdir -p .state/mongodb/logs
#     chmod o+rwx .state/mongodb/logs
# fi

