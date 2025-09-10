#!/bin/bash

set -eux

pwd=mysecretpassword

if ! docker ps | grep -q postgres; then
  docker run --name postgres -e POSTGRES_PASSWORD=$pwd -d -p 5432:5432 postgres
fi

# test connection
# psql "host=localhost port=5432 user=postgres password=$pwd"
if ! pg_isready -h localhost -p 5432 -U postgres; then
  echo "cannot connect to postgres"
  exit 1
fi

./build/release/duckdb -unsigned < ./copy-tpch-to-pg.sql

rm ./tpch

