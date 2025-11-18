@echo off
setlocal enabledelayedexpansion

:: Set GDAL path and update PATH
set "GDAL_PATH=C:\Program Files\QGIS 3.40.10\bin"
set PATH=%GDAL_PATH%;%PATH%

REM Define directories
set "DIR_INPUT=P:\2025\MARC BRANDT PARK\02_PRODUCTION\06_EXPORTS\ORTHO\01_DRAFT\TIFF"
set "DIR_SHAPE=P:\2025\MARC BRANDT PARK\02_PRODUCTION\06_EXPORTS\ORTHO\02_INTERMEDIATE\GIS\clipping_geometry.shp"
set "DIR_OUTPUT=P:\2025\MARC BRANDT PARK\02_PRODUCTION\06_EXPORTS\ORTHO\02_INTERMEDIATE\TIFF_Clipped"

REM Create output directory if it doesn't exist
if not exist "%DIR_OUTPUT%" mkdir "%DIR_OUTPUT%"

echo Step 1: Crop TIFFs with gdalwarp

for %%f in ("%DIR_INPUT%\*.tiff") do (
    echo Cropping: %%~nxf
    gdalwarp -cutline "%DIR_SHAPE%" ^
             -crop_to_cutline ^
             -r near ^
             -of GTiff ^
             -co COMPRESS=JPEG ^
             -co JPEG_QUALITY=90 ^
             -co PHOTOMETRIC=YCBCR ^
             -co TILED=YES ^
             -co BIGTIFF=IF_NEEDED ^
             "%%f" "%DIR_OUTPUT%\%%~nxf_%clipped.tiff"
)

echo.
echo All done!
pause
