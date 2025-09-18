:: ==========================================================
:: Author: Farid Javadnejad
:: Date: 2025-09-17
:: Last Update: 2025-09-18
::
:: DESCRIPTION:
:: - Script: Exports each feature from the first .shp file in INPUT_DIR as an individual shapefile
:: - INPUT_DIR must contain at least one .shp file
:: - OUTPUT_DIR 'EXPLODE' is auto-created inside INPUT_DIR
:: - Uses ogrinfo to get feature count, then loops with ogr2ogr to extract by FID
:: - Output: One shapefile per feature saved in EXPLODE folder
::
:: DISCLAIMER:
:: This script was developed with the assistance of AI tools for debugging, reviewing, and testing.
:: ==========================================================

@echo off
:: Set input directory and shapefile
set "INPUT_DIR=Z:\2025\NOGAL CANYON\02_PRODUCTION\06_EXPORTS\QGIS\Shapefile"

:: Change to input directory
cd /d "%INPUT_DIR%"

:: Find the first .shp file in the directory
for %%F in (*.shp) do (
    set "SHAPEFILE=%%F"
    set "FILENAME=%%~nF"
    goto :found
)

:found
:: Create output folder named 'explode'
set "OUTPUT_DIR=%INPUT_DIR%\EXPLODE"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

:: Get feature count
for /f "tokens=*" %%C in ('ogrinfo "%SHAPEFILE%" -al -so ^| find "Feature Count"') do (
    for /f "tokens=3" %%N in ("%%C") do set COUNT=%%N
)

echo Processing %SHAPEFILE% with %COUNT% features...

:: Loop through each feature and export as individual shapefile
for /l %%I in (0,1,%COUNT%) do (
    ogr2ogr -f "ESRI Shapefile" "%OUTPUT_DIR%\%%I.shp" "%SHAPEFILE%" -where "FID=%%I" -explodecollections
)

echo Done! Files saved in %OUTPUT_DIR%
