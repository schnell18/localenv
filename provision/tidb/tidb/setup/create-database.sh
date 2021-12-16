#!/bin/sh

database=$1
user=$2

echo "Creating empty database $database..."
cat <<EOF | mysql -h 127.0.0.1 -P 4000 -u root
drop database if exists $database;
create database if not exists $database
    default character set utf8mb4
    default collate utf8mb4_general_ci;
create user if not exists $user@'%' identified by 'abc';
create user if not exists $user@'localhost' identified by 'abc';
grant all on $database.* to '$user'@'%';
grant all on $database.* to '$user'@'localhost';
EOF
