
basedir=$(pwd)
for app in $basedir/provision/apps/*/; do
    PWD=$(pwd)
    cd $app
    if [ -f post/setup.sh ]; then
        echo "Run post setup for project $(basename $app)..."
        sh post/setup.sh
    fi
    cd $PWD
done;


