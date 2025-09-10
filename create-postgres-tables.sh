#!/bin/bash
set -eux

DUCKDB_PATH=duckdb
if test -f build/release/duckdb; then
  DUCKDB_PATH=build/release/duckdb
elif test -f build/reldebug/duckdb; then
  DUCKDB_PATH=build/reldebug/duckdb
elif test -f build/debug/duckdb; then
  DUCKDB_PATH=build/debug/duckdb
fi

echo "
CREATE SCHEMA tpch;
CREATE SCHEMA tpcds;
CALL dbgen(sf=0.01, schema='tpch');
CALL dsdgen(sf=0.01, schema='tpcds');
EXPORT DATABASE '/tmp/postgresscannertmp';
" | \
$DUCKDB_PATH

args=(--maintenance-db="user=postgres host=localhost password=mysecretpassword port=5432")
dropdb --if-exists "${args[@]}" postgresscanner
createdb "${args[@]}" postgresscanner

conn_str="user=postgres host=localhost password=mysecretpassword port=5432 dbname=postgresscanner"
psql "${conn_str[@]}" < /tmp/postgresscannertmp/schema.sql
psql "${conn_str[@]}" < /tmp/postgresscannertmp/load.sql
rm -rf /tmp/postgresscannertmp

psql "${conn_str[@]}" < test/all_pg_types.sql
psql "${conn_str[@]}" < test/decimals.sql
psql "${conn_str[@]}" < test/other.sql


psql "${conn_str[@]}" -c "CHECKPOINT"
psql "${conn_str[@]}" -c "VACUUM"
