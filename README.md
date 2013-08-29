# Statens Kartverk Open Data Seed

This repo is for cooking the public data released by Statens Kartverk to be used with out VM (or standalone).

It assumes that you have a working environment with Postgresql-9.1, PostGIS 2.0, Mapnik 2.2.0 and gdal 1.7.0.

Also you need a PostGIS-2-enabled database to seed into. Give login options to this as arguments to the seed-script (see below).

You will need at least 20GB free disk space, and at about 10GB swap to do this, as the GeoJSON-files are huge!

## Performing the seed

```git clone https://github.com/bengler/kartverk_data_seed```

```cd kartverk_data_seed```

```./seed.sh [database_name] [database_user] [database_password]```
