source .infra/global/libs/functions.sh

function setup_macos {
    cat<<EOF | podman machine ssh --username root localenv
cat<<EOT > /etc/security/limits.d/elasticsearch.conf
* soft memlock -1
* hard memlock -1
* soft nproc 4096
* hard nproc 8192
EOT
sysctl -w vm.max_map_count=262144 > /dev/null
getent passwd 1000 > /dev/null
if [[ $? -ne 0 ]]; then
 useradd -u 1000 esrunner
fi
chown -R 1000 $(pwd)/.state/elasticsearch/es01
EOF
#chown -R esrunner /Users/user/localenv/.state/elasticsearch/es01

}

function setup_linux {
    sudo mkdir -p /etc/security/limits.d
    sudo cat<<EOF > /etc/security/limits.d/elasticsearch.conf
* soft memlock -1
* hard memlock -1
* soft nproc 4096
* hard nproc 8192
EOF
    sudo sysctl -w vm.max_map_count=262144
}

if [[ ! -d .state/elasticsearch/es01 ]]; then
    mkdir -p .state/elasticsearch/es01
fi

case `uname` in
    Darwin) setup_macos ;;
    Linux) setup_linux ;;
    *) echo ""
esac

