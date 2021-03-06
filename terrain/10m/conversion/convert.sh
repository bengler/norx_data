echo "Reproject utm32, convert to tiff"

export GDAL_CACHEMAX=8000

dem_dir="../original"
layer_dir="./layers"
odir="./dtm_tiff"

if [ ! -d "$odir" ]; then
  mkdir "$odir"
fi


for f in $dem_dir/sone32/*.dem
  do
    echo "Doing $f. Hang on.";
    base=$(basename $f .dem)

    if [ ! -f "$odir/$base.tif" ]
    then
      gdalwarp -wm 8000 -r bilinear -s_srs EPSG:32632 -t_srs EPSG:32633 -dstnodata -32768 -co "TILED=YES" -co COMPRESS=DEFLATE -co ZLEVEL=9 -r bilinear -of GTiff $f "$odir/$base.tif"
      rm $f
    else
      echo "! File $f is already converted."
    fi
done

echo "Reproject utm35, convert to tiff"

for f in $dem_dir/sone35/*.dem
  do
    echo "Doing $f. Hang on."
    base=$(basename $f .dem)

    if [ ! -f "$odir/$base.tif" ]
    then
      gdalwarp -wm 8000 -r bilinear -s_srs EPSG:32635 -t_srs EPSG:32633 -dstnodata -32768 -co "TILED=YES" -co COMPRESS=DEFLATE -co ZLEVEL=9 -r bilinear -of GTiff $f "$odir/$base.tif"
      rm $f
    else
      echo "! File $f is already converted."
    fi

done

echo "Convert utm33 DEM tiles to tiff"

for f in $dem_dir/sone33/*.dem
  do
    echo "Doing $f. Hang on."
    base=$(basename $f .dem)

    if [ ! -f "$odir/$base.tif" ]
    then
      gdal_translate -of GTiff -a_nodata -32768 -co "TILED=YES" -co COMPRESS=DEFLATE -co ZLEVEL=9 $f "$odir/$base.tif"
      rm $f
    else
      echo "File $f is already converted."
    fi
done


echo "Generating internal tif pyramids in $odir"

for f in $odir/*.tif
  do
    echo "Doing $f. Hang on."
    base=$(basename $f .dem)
    #gdaladdo -r average --config COMPRESS_OVERVIEW DEFLATE $f 2 4 8 16 32 64
    gdaladdo -r average --config COMPRESS_OVERVIEW JPEG --config JPEG_QUALITY_OVERVIEW 90 $f 2 4 8 16 32 64
done

echo "Build vrt $odir"

gdalbuildvrt dtm.vrt $odir/*.tif

if [ ! -d "$layer_dir" ]; then
  mkdir "$layer_dir"
fi


echo "Color relief"

echo "$layer_dir/color_relief.tiff"
gdaldem color-relief dtm.vrt stylesheets/color-ramps/color_ramp.txt "$layer_dir/color_relief.tiff" -of GTiff -co COMPRESS=JPEG -co JPEG_QUALITY=90 -co TILED=YES

echo "Hillshade"

gdaldem hillshade dtm.vrt ./layers/hillshade.tiff -of GTiff -co COMPRESS=JPEG -co JPEG_QUALITY=90 -co TILED=YES -compute_edges

echo "And finally slope"

gdaldem slope dtm.vrt layers/slope.tiff -of GTiff -compute_edges
gdaldem color-relief -co compress=JPEG -co BIGTIFF=YES -co JPEG_QUALITY=90 -co TILED=YES -of GTiff layers/slope.tiff stylesheets/slope-ramp.txt layers/slopes_shade_deflate.tiff

echo "Then generate pyramids for shading rasters"

gdaladdo -r average --config COMPRESS_OVERVIEW JPEG --config JPEG_QUALITY_OVERVIEW 90 $layer_dir/hillshade.tiff 2 4 8 16 32 64 128
gdaladdo -r average --config COMPRESS_OVERVIEW JPEG --config JPEG_QUALITY_OVERVIEW 90 $layer_dir/color_relief.tiff 2 4 8 16 32 64 128
gdaladdo -r average --config COMPRESS_OVERVIEW JPEG --config JPEG_QUALITY_OVERVIEW 90 $layer_dir/slopes_shade_deflate.tiff 2 4 8 16 32 64 128
