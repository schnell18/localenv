for sub in $(echo */); do
    OLD=$(pwd)
    cd $sub
    sh build.sh
    cd $OLD
done
