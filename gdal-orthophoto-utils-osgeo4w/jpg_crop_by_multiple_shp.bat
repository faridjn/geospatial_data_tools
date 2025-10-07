:: ==========================================================
:: Author: Farid Javadnejad
:: Date: 2025-09-17
:: Last Update: 2025-09-18
::
:: DESCRIPTION:
:: - Script: Crops JPG images using multiple SHP files as cutlines
:: - INPUT_DIR: Source JPGs
:: - SHAPE_DIR: Shapefiles used for cropping
:: - OUTPUT_DIR: Cropped JPGs with .jgw worldfiles
:: - TEMP_DIR: Intermediate GeoTIFFs for processing
:: - Output filenames include both image and shapefile names
:: - Uses gdalwarp for cropping and gdal_translate for JPEG conversion
:: - Renames .wld to .jgw if needed
::
:: DISCLAIMER:
:: This script was developed with the assistance of AI tools for debugging, reviewing, and testing.
:: ==========================================================

@echo off
setlocal enabledelayedexpansion
:: Set GDAL path and update PATH
set "GDAL_PATH=C:\Program Files\QGIS 3.40.10\bin"
set PATH=%GDAL_PATH%;%PATH%

:: Define directories
set "DIR_INPUT=Z:\2025\NOGAL CANYON\02_PRODUCTION\06_EXPORTS\ORTHO\01_DRAFT\JPG"
set "DIR_OUTPUT=Z:\2025\NOGAL CANYON\02_PRODUCTION\06_EXPORTS\ORTHO\02_INTERMEDIATE\JPG_CLIP"
set "DIR_SHAPE=Z:\2025\NOGAL CANYON\02_PRODUCTION\06_EXPORTS\QGIS\Shapefile\SHP_3"

:: Output subfolders
set "DIR_JPG=%DIR_OUTPUT%\ORTHO_IMAGE_TILES"
set "DIR_TEMP=%DIR_OUTPUT%\TEMP"

:: Create output directories if they don't exist
if not exist "%DIR_OUTPUT%" mkdir "%DIR_OUTPUT%"
if not exist "%DIR_JPG%" mkdir "%DIR_JPG%"
if not exist "%DIR_TEMP%" mkdir "%DIR_TEMP%"


:: Print directory paths
echo ==========================================
echo Input Directory:  %DIR_INPUT%
echo Output Directory: %DIR_JPG%
echo Shape Directory:  %DIR_SHAPE%
echo ==========================================


:: Configs
:: Force GDAL to print only percentage ticks (no time estimates)
set "CPL_PROGRESS_FORMAT=PERCENT"

echo Step 1: Crop JPGs using multiple SHP files

setlocal enabledelayedexpansion

for %%f in ("%DIR_INPUT%\*.jpg") do (
    for %%s in ("%DIR_SHAPE%\*.shp") do (
        echo Processing Image: %%~nxf with Shape: %%~nxs

        :: Build output names
        set "IMG_NAME=%%~nf"
        set "SHP_NAME=%%~ns"
        set "TEMP_TIF=%DIR_TEMP%\temp_!IMG_NAME!-!SHP_NAME!.tif"
        set "OUT_JPG=%DIR_JPG%\!IMG_NAME!-!SHP_NAME!.jpg"

        :: Step 1a: Warp (crop) into temporary GeoTIFF
        gdalwarp --config CPL_PROGRESS_FORMAT "PERCENT" ^
                 -cutline "%%s" ^
                 -crop_to_cutline ^
                 -r near ^
                 -of GTiff ^
                 -co COMPRESS=DEFLATE ^
                 -co TILED=YES ^
                 -co BIGTIFF=IF_NEEDED ^
                 "%%f" "!TEMP_TIF!"

        :: Step 1b: Convert to JPEG and generate .jgw
        gdal_translate --config CPL_PROGRESS_FORMAT "PERCENT" ^
                       -of JPEG ^
                       -co WORLDFILE=YES ^
                       -co QUALITY=99 ^
                       "!TEMP_TIF!" "!OUT_JPG!"

        :: Step 1c: Rename .wld to .jgw if necessary
        if exist "%DIR_JPG%\!IMG_NAME!-!SHP_NAME!.wld" (
            ren "%DIR_JPG%\!IMG_NAME!-!SHP_NAME!.wld" "!IMG_NAME!-!SHP_NAME!.jgw"
        )
    )
)


echo.
echo All done! Cropped JPG + JGW created in %DIR_JPG%
echo Temporary TIF files kept in %DIR_TEMP%
pause