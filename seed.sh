#!/bin/bash

DB_NAME="$1"
DB_USER="$2"
DB_PASSWORD="$3"
HTTP_USER="bengler"
HTTP_PASSWORD="data"

if [ ! -d "tmp" ]; then
  mkdir tmp
fi
cd ./tmp

# Fetch and process N50 geojson into Postgresql

echo "Fetching N50 geojson archive"

wget -c --user="$HTTP_USER" --password="$HTTP_PASSWORD" http://data.kartverket.no/bengler/geojson/Kartdata/n50.zip
unzip n50.zip
rm n50.zip

echo "Processing N50 geojson"

for f in n50/*geojson;
  do
	table="n50_$(basename $f .geojson)"
	echo "Dumping $f into table $DB_NAME.$table"
	ogr2ogr -f  "PostgreSQL" PG:"host=localhost user=$DB_USER password=$DB_PASSWORD dbname=$DB_NAME" -s_srs 'EPSG:32633' -t_srs 'EPSG:4326' $f OGRGeoJSON -overwrite -nln $table
	rm $f
	echo "Deleted $f"
done

echo "Fetching SSR"
wget -c --user="$HTTP_USER" --password="$HTTP_PASSWORD" http://data.kartverket.no/bengler/geojson/SSR_stedsnavn.zip
unzip SSR_stedsnavn.zip
echo "Processing SSR"
table="SSR"
ogr2ogr -f  "PostgreSQL" PG:"host=localhost user=$DB_USER password=$DB_PASSWORD dbname=$DB_NAME" -s_srs 'EPSG:32633' -t_srs 'EPSG:4326' $f OGRGeoJSON -overwrite -nln $table



# Fetch and restore N50
#wget -c --user="$HTTP_USER" --password="$HTTP_PASSWORD" http://data.kartverket.no/bengler/pgdump/n50_arealdekke.zip
#gunzip -c ./n50_arealdekke.zip | pg_restore -i -d "$DB_NAME" -v
#rm n50_arealdekke.zip

# Re-project N50 to WGS84
#psql -d "$DB_NAME" -f ../sql/reproject_n50.sql

# Fetch and bake administrative borders
#wget -c --user="$HTTP_USER" --password="$HTTP_PASSWORD" http://data.kartverket.no/bengler/geojson/Administrative_grenser.zip
#unzip Administrative_grenser.zip
#rm Administrative_grenser.zip
# Clean up

cd ..
rm -rf ./tmp
