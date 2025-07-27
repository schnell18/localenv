#!/bin/bash

database=$1
user=$2
schema_file=$3
data_file=$4

if [[ -z $database || -z $user ]]; then
    echo "Usage: $0 <database> <user> [schema_file] [data_file]"
    exit 1
fi

echo "Loading schema and data into database $database..."

# Load schema if provided
if [[ -n $schema_file && -f $schema_file ]]; then
    echo "Loading schema from $schema_file..."
    PGPASSWORD=$user psql -h localhost -U $user -d $database -f $schema_file
    if [[ $? -eq 0 ]]; then
        echo "Schema loaded successfully"
    else
        echo "Failed to load schema"
        exit 1
    fi
fi

# Load data if provided
if [[ -n $data_file && -f $data_file ]]; then
    echo "Loading data from $data_file..."
    PGPASSWORD=$user psql -h localhost -U $user -d $database -f $data_file
    if [[ $? -eq 0 ]]; then
        echo "Data loaded successfully"
    else
        echo "Failed to load data"
        exit 1
    fi
fi

echo "Schema and data loading completed for database $database"