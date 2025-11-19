:: ==========================================================
:: Author: Farid Javadnejad
:: Date: 2025-09-17
:: Last Update: 2025-10-31
:: ==========================================================
:: DESCRIPTION:
:: - Script: Clips GeoTIFF images using multiple SHP files as cutlines
:: - INPUT_DIR: Source GeoTIFFs (.tif / .tiff)
:: - SHAPE_DIR: Shapefiles used for clipping
:: - OUTPUT_DIR: Cropped GeoTIFFs (.tif)
:: - Output filenames include both image and shapefile names
:: - Uses gdalwarp to crop directly to GeoTIFF with JPEG compression
::
:: DISCLAIMER:
:: This script was developed with the assistance of AI tools for debugging, reviewing, and testing.
:: ==========================================================

@echo off
setlocal enabledelayedexpansion

:: Set GDAL path and update PATH (update if needed)
set "GDAL_PATH=C:\Program Files\QGIS 3.40.10\bin"
set PATH=%GDAL_PATH%;%PATH%

:: Define directories (update as needed)
set "DIR_INPUT=P:\2025\MARC BRANDT PARK\02_PRODUCTION\06_EXPORTS\ORTHO\TIFF"
set "DIR_OUTPUT=P:\2025\MARC BRANDT PARK\02_PRODUCTION\06_EXPORTS\ORTHO\TIFF_Clipped"
set "DIR_SHAPE=P:\2025\MARC BRANDT PARK\02_PRODUCTION\06_EXPORTS\ORTHO\GIS"

:: Output subfolder for cropped GeoTIFFs
set "DIR_TIF=%DIR_OUTPUT%\ORTHO_IMAGE_TILES"

:: Create output directories if they don't exist
if not exist "%DIR_OUTPUT%" mkdir "%DIR_OUTPUT%"
if not exist "%DIR_TIF%" mkdir "%DIR_TIF%"

:: Configs: force GDAL to print only percentage ticks (no time estimates)
set "CPL_PROGRESS_FORMAT=PERCENT"

echo ==========================================
echo Input Directory:  %DIR_INPUT%
echo Output Directory: %DIR_TIF%
echo Shape Directory:  %DIR_SHAPE%
echo ==========================================
echo Clip TIFFs to TIFFs (GeoTIFF) using JPEG compression

:: Helper to process both .tif and .tiff
for %%e in (tif tiff) do (
  for %%f in ("%DIR_INPUT%\*.%%e") do (
    for %%s in ("%DIR_SHAPE%\*.shp") do (
        echo Processing Image: %%~nxf with Shape: %%~nxs

        :: Build output names
        set "IMG_NAME=%%~nf"
        set "SHP_NAME=%%~ns"
        set "OUT_TIF=%DIR_TIF%\!IMG_NAME!-!SHP_NAME!.tiff"

        :: Direct crop to GeoTIFF with JPEG compression
        gdalwarp --config CPL_PROGRESS_FORMAT "PERCENT" ^
                 -cutline "%%s" ^
                 -crop_to_cutline ^
                 -r near ^
                 -of GTiff ^
                 -co COMPRESS=JPEG ^
                 -co JPEG_QUALITY=85 ^
                 -co PHOTOMETRIC=YCBCR ^
                 -co TILED=YES ^
                 "%%f" "!OUT_TIF!"

	:: Build pyramids for performance
		gdaladdo "!OUT_TIF!" 2 4 8 16

        )
    )
  )
)

echo.
echo All done! Cropped GeoTIFFs created in %DIR_TIF%
pause