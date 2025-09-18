@echo off
REM Set input directory and shapefile
set "INPUT_DIR=Z:\2025\NOGAL CANYON\02_PRODUCTION\06_EXPORTS\QGIS\Shapefile"

REM Change to input directory
cd /d "%INPUT_DIR%"

REM Find the first .shp file in the directory
for %%F in (*.shp) do (
    set "SHAPEFILE=%%F"
    set "FILENAME=%%~nF"
    goto :found
)

:found
REM Create output folder named 'explode'
set "OUTPUT_DIR=%INPUT_DIR%\EXPLODE"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM Get feature count
for /f "tokens=*" %%C in ('ogrinfo "%SHAPEFILE%" -al -so ^| find "Feature Count"') do (
    for /f "tokens=3" %%N in ("%%C") do set COUNT=%%N
)

echo Processing %SHAPEFILE% with %COUNT% features...

REM Loop through each feature and export as individual shapefile
for /l %%I in (0,1,%COUNT%) do (
    ogr2ogr -f "ESRI Shapefile" "%OUTPUT_DIR%\%%I.shp" "%SHAPEFILE%" -where "FID=%%I" -explodecollections
)

echo Done! Files saved in %OUTPUT_DIR%
