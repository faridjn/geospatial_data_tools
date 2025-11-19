:: ==========================================================
:: Author: Farid Javadnejad
:: Date: 2025-09-17
:: Last Update: 2025-10-31

:: ==========================================================
:: DESCRIPTION:
:: - Script: Clips GeoTIFF images using multiple SHP files as cutlines
:: - INPUT_DIR: Source GeoTIFFs (.tif / .tiff)
:: - SHAPE_DIR: Shapefiles used for clipping
:: - OUTPUT_DIR: Cropped Images (.jpg)
:: - Output filenames include both image and shapefile names
:: - Ensures .jgw worldfiles are created
::
:: DISCLAIMER:
:: This script was developed with the assistance of AI tools for debugging, reviewing, and testing.
:: ==========================================================

@echo off
setlocal EnableDelayedExpansion

:: ------------------------------
:: Configure GDAL/QGIS binaries
:: ------------------------------
set "GDAL_PATH=C:\Program Files\QGIS 3.40.10\bin"
set "PATH=%GDAL_PATH%;%PATH%"

:: ------------------------------
:: Project directories (edit as needed)
:: ------------------------------
set "DIR_INPUT=P:\2025\SHIPROCK US-64\02_PRODUCTION\01_PIX4D\SHIPROCK_US64_PIX4D\SHIPROCK_US64_PIX4D_251112\exports"
set "DIR_OUTPUT=P:\2025\SHIPROCK US-64\02_PRODUCTION\06_EXPORTS\ORTHO_JPG_PROCESS"
set "DIR_SHAPE=P:\2025\SHIPROCK US-64\02_PRODUCTION\06_EXPORTS\GIS\Singleparts\EXPLODE"

:: Output subfolder for cropped JPEGs
set "DIR_JPG=%DIR_OUTPUT%\ORTHO_IMAGE_TILES_JPG"

:: Create output directories if they don't exist
if not exist "%DIR_OUTPUT%" mkdir "%DIR_OUTPUT%"
if not exist "%DIR_JPG%" mkdir "%DIR_JPG%"

:: ------------------------------
:: GDAL progress formatting
:: ------------------------------
set "CPL_PROGRESS_FORMAT=PERCENT"

echo ==========================================
echo Input Directory:  %DIR_INPUT%
echo Output Directory: %DIR_JPG%
echo Shape Directory:  %DIR_SHAPE%
echo ==========================================
echo Clip TIFFs and export as JPEG (.jpg + .jgw)

:: Helper to process both .tif and .tiff
for %%e in (tif tiff) do (
  for %%f in ("%DIR_INPUT%\*.%%e") do (
    for %%s in ("%DIR_SHAPE%\*.shp") do (

        echo(
        echo Processing Image: %%~nxf  with Shape: %%~nxs

        :: Build output names
        set "IMG_NAME=%%~nf"
        set "SHP_NAME=%%~ns"
        set "OUT_JPG=%DIR_JPG%\!IMG_NAME!-!SHP_NAME!.jpg"

        :: Crop and convert to JPEG; emit world file
        gdalwarp ^
          --config CPL_PROGRESS_FORMAT "PERCENT" ^
          -cutline "%%~fs" ^
          -crop_to_cutline ^
          -r near ^
          -of JPEG ^
          -co QUALITY=85 ^
          -co WORLDFILE=YES ^
          "%%~ff" "!OUT_JPG!"

        :: If GDAL creates .jpgw (some builds do), rename to .jgw to standardize
        if exist "!OUT_JPG!w" ren "!OUT_JPG!w" "!IMG_NAME!-!SHP_NAME!.jgw"

    )
  )
)

echo(
echo All done! Cropped JPEGs (and world files) created in:
echo   %DIR_JPG%
pause
endlocal
