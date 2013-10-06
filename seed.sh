#!/bin/bash

DB_NAME="$1"
DB_USER="$2"
DB_PASSWORD="$3"
HTTP_USER="bengler" # This is, believe it or not, the official username at data.kartverket.no/betatest
HTTP_PASSWORD="data" # And the password

if [ ! -d "tmp" ]; then
  mkdir tmp
fi
cd ./tmp


# Create swapfile of 30GB with block size 1MB
dd if=/dev/zero of=/swapfile bs=1024 count=31457280
# Set up the swap file
mkswap /swapfile

# Enable swap file immediately
swapon /swapfile

# Fetch and process N50 geojson into Postgresql

if [ ! -f '../.done_n50' ]; then

  echo "    * Generating and activating humongous!! (30 GB) swapfile needed to parse BIG GeoJSON files. Some of these JSON files are as big as 12 GB!"

  echo "Fetching N50 geojson archive"

  wget --quiet -c --user="$HTTP_USER" --password="$HTTP_PASSWORD" http://data.kartverket.no/betatest/kartdata/n50/landsdekkende/Kartdata_Norge_WGS84_N50_geoJSON.zip
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
  cd n50
  table="n50_arealdekkeflate"
  for f in arealdekkeflate/*geojson;
    do
    echo "Dumping $f into table $DB_NAME.$table"
    ogr2ogr -f  "PostgreSQL" PG:"host=localhost user=$DB_USER password=$DB_PASSWORD dbname=$DB_NAME" -s_srs 'EPSG:32633' -t_srs 'EPSG:4326' $f OGRGeoJSON -append -nln $table
    # rm $f
    # echo "Deleted $f"
  done
  cd..
  touch ../.done_n50
fi

if [ ! -f '../.done_ssr' ]; then

  echo "Fetching SSR"
  wget --quiet -c --user="$HTTP_USER" --password="$HTTP_PASSWORD" http://data.kartverket.no/betatest/stedsnavn/landsdekkende/Stedsavn_Norge_WGS84_geoJSON.zip
  unzip Stedsavn_Norge_WGS84_geoJSON.zip
  echo "Processing SSR"
  table="ssr"
  ogr2ogr -f  "PostgreSQL" PG:"host=localhost user=$DB_USER password=$DB_PASSWORD dbname=$DB_NAME" -s_srs 'EPSG:4326' -t_srs 'EPSG:4326' stedsnavn.geojson OGRGeoJSON -overwrite -nln $table
  # rm stedsnavn.geojson
  touch ../.done_ssr
fi

if [ ! -f '../.done_adm_limits' ]; then
  echo "Fetching Administration limits"
  wget --quiet -c --user="$HTTP_USER" --password="$HTTP_PASSWORD" http://data.kartverket.no/betatest/grensedata/landsdekkende/Grenser_Norge_WGS84_geoJSON.zip
  unzip Grenser_Norge_WGS84_geoJSON.zip
  for f in abas/*geojson;
    do
  	table="adm_areas_$(basename $f .geojson)"
  	echo "Dumping $f into table $DB_NAME.$table"
  	ogr2ogr -f  "PostgreSQL" PG:"host=localhost user=$DB_USER password=$DB_PASSWORD dbname=$DB_NAME" -s_srs 'EPSG:32633' -t_srs 'EPSG:4326' $f OGRGeoJSON -overwrite -nln $table
  done
  rm  -rf ./abas
  touch ../.done_adm_limits
fi


rm -rf ./*

echo "    * Deactivating and removing swap file"
swapoff /swapfile
rm -rf /swapfile  

# Create swapfile of 10GB with block size 1MB
dd if=/dev/zero of=/swapfile bs=1024 count=10485760
# Set up the swap file
mkswap /swapfile

# Enable swap file immediately
swapon /swapfile

if [ ! -f '../.done_terrain' ]; then


  echo "Getting 10m terrain data"
  wget --quiet -c --user="$HTTP_USER" --password="$HTTP_PASSWORD"  -r -np -nH –cut-dirs=3 -R index.html http://data.kartverket.no/betatest/terrengdata/10m/

  mkdir ../terrain/10m/original

  echo "Processsing utm32 dem files"
  for f in betatest/terrengdata/10m/utm32/*zip;
    do
    unzip $f
    rm $f
  done
  mkdir ../terrain/10m/original/sone32
  mv *.dem ../terrain/10m/original/sone32

  echo "Processsing utm33 dem files"
  for f in betatest/terrengdata/10m/utm33/*zip;
    do
    unzip $f
    rm $f
  done
  mkdir ../terrain/10m/original/sone33
  mv *.dem ../terrain/10m/original/sone33

  echo "Processsing utm35 dem files"
  for f in betatest/terrengdata/10m/utm35/*zip;
    do
    unzip $f
    rm $f
  done
  mkdir ../terrain/10m/original/sone35
  mv *.dem ../terrain/10m/original/sone35

  rm -rf betatest
  cd ../terrain/10m/conversion
  sudo -u norx ./convert.sh
fi

cd /home/norx/data

echo "Adding indexes to postgres database"
psql -d norx -a -f ./sql/create_indexes.sql

echo "    * Deactivating and removing swap file"
swapoff /swapfile
rm -rf /swapfile  
