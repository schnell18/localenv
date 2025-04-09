#!/bin/bash

load_schema() {
    # load schema if any
    if [ -f schema/schema.sql ]; then
        echo "Loading schema..."
        mysql --defaults-file=/work/.infra/mariadb/provision/appuser.ini -u $user -D $database < schema/schema.sql
    fi
    if [ -f schema/add_foreign_keys.sql ]; then
        echo "Loading foreign key..."
        mysql --defaults-file=/work/.infra/mariadb/provision/appuser.ini -u $user -D $database < schema/add_foreign_keys.sql
    fi
}

load_data() {
    # load data for test data if any
    if [ -d schema/data ]; then
        cd schema/data
        cnt=$(ls *.csv 2>/dev/null | wc -l)
        if [ "$cnt" != "0" ]; then
            echo "Loading data files..."
            for d in *.csv
            do
                tab=$(echo $d | cut -d . -f 1 | cut -d - -f 2)
                cat <<EOF | mysql --defaults-file=/work/.infra/mariadb/provision/appuser.ini -u $user -D $database
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
else
  cd /work/$basedir/$app
fi

load_schema
load_data
cd $PWD

