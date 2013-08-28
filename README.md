# Statens Kartverk Open Data Seed

This repo is for cooking the public data released by Statens Kartverk to be used with out VM - but also for other things.

It assumes that you have a working environment with Postgresql-9.1, PostGIS 2.0, Mapnik 2.2.0 and gdal 1.7.0.

Also you need a PostGIS-enabled database to seed into.

## Installation

```git clone https://github.com/bengler/kartverk_data_seed```
```cd kartverk_data_seed```
```./seed.sh [database_name]```
