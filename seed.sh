#!/bin/bash

DB_NAME="$1"

mkdir ./tmp
cd ./tmp

# Fetch and restore N50
wget -c --user=bengler --password=data http://data.kartverket.no/bengler/pgdump/n50_arealdekke.zip
gunzip -c ./n50_arealdekke.zip | pg_restore -i -d "$DB_NAME" -v
rm n50_arealdekke.zip
cd ..
rm -rf ./tmp

# Re-project N50 to WGS84
psql -d "$DB_NAME" -f ./sql/reproject_n50.sql

