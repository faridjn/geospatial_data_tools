@echo off

:: Set GDAL path and update PATH
set "GDAL_PATH=C:\Program Files\QGIS 3.40.10\bin"
set PATH=%GDAL_PATH%;%PATH%

:: DESCRIPTION:
:: - Compresses a GeoTIFF using GDAL with user-specified or default JPEG quality
:: - Converts pixel type to Byte and applies scaling
:: - Output retains georeferencing and metadata
::
:: DISCLAIMER:
:: Script reviewed and optimized with AI assistance.
:: ==========================================================

:: Set working directory and input file
set "DIR=P:\2025\MARC BRANDT PARK\02_PRODUCTION\03_TOPODOT\NEARMAP\TrueOrtho_EPSG6529_Date20240601_GeoTIFF"
set "FILENAME=TrueOrtho.tif"

:: Set default JPEG quality
set JPEG_QUALITY=95

:: Prompt user (optional override)
set /p USER_INPUT="Enter JPEG quality (1-100) or press Enter for default (%JPEG_QUALITY%): "
if not "%USER_INPUT%"=="" set JPEG_QUALITY=%USER_INPUT%

:: Extract base name without extension
for %%F in ("%FILENAME%") do set BASENAME=%%~nF

:: Set output filename
set OUTNAME=%BASENAME%_compressed.tif

:: Print info
echo Processing file: %FILENAME%
echo JPEG Quality: %JPEG_QUALITY%

:: Run GDAL compression
gdal_translate -ot Byte -scale -of GTiff -co COMPRESS=JPEG -co JPEG_QUALITY=%JPEG_QUALITY% "%DIR%\%FILENAME%" "%DIR%\%OUTNAME%"

echo Compression complete: %OUTNAME%
pause