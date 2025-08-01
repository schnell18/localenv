#!/bin/bash

load_schema() {
    # load schema if any
    if [ -f schema/schema.sql ]; then
        echo "Loading schema for database $database ..."
        PGPASSWORD=$user psql -h localhost -U $user -d $database -f schema/schema.sql
    fi
    if [ -f schema/add_foreign_keys.sql ]; then
        echo "Loading foreign key for database $database ..."
        PGPASSWORD=$user psql -h localhost -U $user -d $database -f schema/add_foreign_keys.sql
    fi
}

load_data() {
    # load data for test data if any
    if [ -d schema/data ]; then
        cd schema/data
        cnt=$(ls *.csv 2>/dev/null | wc -l)
        if [ "$cnt" != "0" ]; then
            echo "Loading data files for database $database ..."
            for d in *.csv; do
                tab=$(echo $d | cut -d . -f 1 | cut -d - -f 2)
                cat <<EOF | mysql --defaults-file=/etc/mysql/conf.d/appuser.ini -u $user -D $database
load data local infile "$d"
    into table $tab
    fields terminated by '|';
EOF
            done
        fi
    fi
}

app=$1
user=$2
database=$3
basedir=$4
PWD=$(pwd)

if [ -d /work/$basedir/$app/provision ]; then
    cd /work/$basedir/$app/provision
elif [ -d /work/$basedir/$app/project_root ]; then
    cd /work/$basedir/$app/project_root
else
    echo "Nothing to load"
    exit 0
fi

load_schema
# load_data
cd $PWD
