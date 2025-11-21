:: ==========================================================
:: Author: Farid Javadnejad
:: Date: 2025-09-17
:: Last Update: 2025-11-20

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

:: ------------------------------
:: Configure GDAL/QGIS binaries
:: ------------------------------
set "GDAL_PATH=C:\Program Files\QGIS 3.40.10\bin"

:: Check if GDAL path exists
if exist "%GDAL_PATH%" (
    echo GDAL path found: %GDAL_PATH%
    set "PATH=%GDAL_PATH%;%PATH%"
) else (
    echo ERROR: GDAL path not found at %GDAL_PATH%
    echo Please verify QGIS/GDAL installation or update GDAL_PATH in the script.
    pause
    exit /b 1
)



:: ------------------------------
:: Project directories (edit as needed)
:: ------------------------------
set "DIR_INPUT=P:\2025\SNL-IGLOO\RS\02_PRODUCTION\06_OTHER_TOOLS\Nearmap\TrueOrthoGeoTIFF"
set "DIR_SHAPE=P:\2025\SNL-IGLOO\RS\02_PRODUCTION\06_OTHER_TOOLS\Nearmap\QGIS\Shapefile\EXPLODE"

:: Output subfolder for cropped JPEGs
set "DIR_OUTPUT=%DIR_INPUT%\TILES_JPG"

:: Create output directories if they don't exist
if not exist "%DIR_OUTPUT%" mkdir "%DIR_OUTPUT%"
if not exist "%DIR_OUTPUT%" mkdir "%DIR_OUTPUT%"

:: ------------------------------
:: GDAL progress formatting
:: ------------------------------
set "CPL_PROGRESS_FORMAT=PERCENT"

echo ==========================================
echo Input Directory:  %DIR_INPUT%
echo Output Directory: %DIR_OUTPUT%
echo Shape Directory:  %DIR_SHAPE%
echo ==========================================
echo Clip TIFFs and export as JPEG (.jpg + .jgw)

:: Process both .tif and .tiff
for %%e in (tif tiff) do (
  for %%f in ("%DIR_INPUT%\*.%%e") do (
    for %%s in ("%DIR_SHAPE%\*.shp") do (

        echo(
        echo Processing Image: %%~nxf with Shape: %%~nxs

        set "IMG_NAME=%%~nf"
        set "SHP_NAME=%%~ns"
        set "OUT_JPG=%DIR_OUTPUT%\!IMG_NAME!-!SHP_NAME!.jpg"

        gdalwarp ^
          --config CPL_PROGRESS_FORMAT PERCENT ^
          -cutline "%%~fs" ^
          -crop_to_cutline ^
          -r near ^
          -of JPEG ^
          -co QUALITY=85 ^
          -co WORLDFILE=YES ^
          "%%~ff" "!OUT_JPG!"

        :: Rename world files (.jpgw or .wld) to .jgw
        pushd "%DIR_OUTPUT%"
        for %%x in (*.wld *.jpgw) do (
            ren "%%x" "%%~nx.jgw"
        )
        popd

    )
  )
)