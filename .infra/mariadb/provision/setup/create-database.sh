#!/bin/bash

database=$1
user=$2

echo "Creating empty database $database..."
cat <<EOF | mysql --defaults-file=/etc/mysql/conf.d/root.ini -u root
drop database if exists $database;
create database if not exists $database
    default character set utf8mb4
    default collate utf8mb4_general_ci;
create user if not exists $user@'%' identified by '$user';
create user if not exists $user@'localhost' identified by '$user';
grant all on $database.* to '$user'@'%';
grant all on $database.* to '$user'@'localhost';
EOF
