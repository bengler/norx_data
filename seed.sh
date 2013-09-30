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

wget -c --user="$HTTP_USER" --password="$HTTP_PASSWORD" http://data.kartverket.no/betatest/kartdata/n50/landsdekkende/Kartdata_Norge_WGS84_N50_geoJSON.zip
unzip Kartdata_Norge_WGS84_N50_geoJSON.zip
rm Kartdata_Norge_WGS84_N50_geoJSON.zip

echo "Processing N50 geojson"

for f in n50/*geojson;
  do
	table="n50_$(basename $f .geojson)"
	echo "Dumping $f into table $DB_NAME.$table"
	ogr2ogr -f  "PostgreSQL" PG:"host=localhost user=$DB_USER password=$DB_PASSWORD dbname=$DB_NAME" -s_srs 'EPSG:32633' -t_srs 'EPSG:4326' $f OGRGeoJSON -overwrite -nln $table
	# rm $f
	# echo "Deleted $f"
done

echo "Fetching SSR"
wget -c --user="$HTTP_USER" --password="$HTTP_PASSWORD" http://data.kartverket.no/betatest/stedsnavn/landsdekkende/Stedsavn_Norge_WGS84_geoJSON.zip
unzip Stedsavn_Norge_WGS84_geoJSON.zip
echo "Processing SSR"
table="SSR"
ogr2ogr -f  "PostgreSQL" PG:"host=localhost user=$DB_USER password=$DB_PASSWORD dbname=$DB_NAME" -s_srs 'EPSG:4326' -t_srs 'EPSG:4326' $f OGRGeoJSON -overwrite -nln $table


echo "Fetching Administration limits"
wget -c --user="$HTTP_USER" --password="$HTTP_PASSWORD" http://data.kartverket.no/betatest/grensedata/landsdekkende/Grenser_Norge_WGS84_geoJSON.zip
unzip Grenser_Norge_WGS84_geoJSON.zip
for f in abas/*geojson;
  do
	table="adm_areas_$(basename $f .geojson)"
	echo "Dumping $f into table $DB_NAME.$table"
	ogr2ogr -f  "PostgreSQL" PG:"host=localhost user=$DB_USER password=$DB_PASSWORD dbname=$DB_NAME" -s_srs 'EPSG:32633' -t_srs 'EPSG:4326' $f OGRGeoJSON -overwrite -nln $table
	echo "Deleted $f"
done

cd ..
#rm -rf ./tmp
