@echo off
setlocal enabledelayedexpansion

:: ============================
:: RGB ORTHO CLIPPER (JPEG 90%)
:: ============================

set "GDAL_PATH=C:\Program Files\QGIS 3.40.10\bin"
set "GDAL_APPS_PATH=C:\Program Files\QGIS 3.40.10\apps\gdal\bin"
set "PATH=%GDAL_PATH%;%GDAL_APPS_PATH%;%PATH%"

set "DIR_INPUT=P:\2025\MARC BRANDT PARK\02_PRODUCTION\06_EXPORTS\ORTHO\01_DRAFT\TIFF"
set "DIR_SHAPE=P:\2025\MARC BRANDT PARK\02_PRODUCTION\06_EXPORTS\ORTHO\02_INTERMEDIATE\GIS\clipping_geometry.shp"
set "DIR_OUTPUT=P:\2025\MARC BRANDT PARK\02_PRODUCTION\06_EXPORTS\ORTHO\02_INTERMEDIATE\TIFF_Clipped"

if not exist "%DIR_OUTPUT%" mkdir "%DIR_OUTPUT%"

echo ============================================================
echo Clipping RGB orthos (JPEG, quality=90, YCbCr)
echo ============================================================

for %%f in ("%DIR_INPUT%\*.tif" "%DIR_INPUT%\*.tiff") do (
    set "OUT_FILE=%DIR_OUTPUT%\%%~nf_clipped.tif"
    echo Processing: %%~nxf

    gdalwarp -overwrite ^
             -cutline "%DIR_SHAPE%" ^
             -crop_to_cutline ^
             -r near ^
             -multi -wo NUM_THREADS=ALL_CPUS ^
             -of GTiff ^
             -co TILED=YES ^
             -co COMPRESS=JPEG ^
             -co JPEG_QUALITY=90 ^
             -co PHOTOMETRIC=YCBCR ^
             -co BIGTIFF=IF_NEEDED ^
             "%%f" "!OUT_FILE!"

    if errorlevel 1 (echo [ERROR] Failed: %%~nxf) else (echo [OK] Done: %%~nxf)
    echo.
)

echo ============================================================
echo All processing complete!
echo Output: %DIR_OUTPUT%
echo ============================================================
pause