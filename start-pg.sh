#!/bin/bash

set -eux

docker run --name postgres -e POSTGRES_PASSWORD=mysecretpassword -d -p 5432:5432 postgres

# test connection with:
# psql "host=localhost port=5432 user=postgres password=mysecretpassword"
#

