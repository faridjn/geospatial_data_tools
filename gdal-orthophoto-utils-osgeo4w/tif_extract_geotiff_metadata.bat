@echo off
setlocal

:: Set default GDAL path
set "GDAL_PATH=C:\Program Files\QGIS 3.40.10\bin"

:: Set default input directory
set "INPUT_DIR=P:\2025\NOGAL CANYON\02_PRODUCTION\04_QA_QC\SURFACE_COMPARE\2025 - 2019"

echo Current INPUT directory is: %INPUT_DIR%
echo.
echo Press ENTER to proceed with this directory.
echo Or paste a new directory path and press ENTER.
echo (Press ESC to cancel)

set /p USER_INPUT="Directory: "

if not "%USER_INPUT%"=="" (
    set "INPUT_DIR=%USER_INPUT%"
)

cd /d "%INPUT_DIR%"

for %%f in (*.tif) do (
    echo Processing %%f...
    "%GDAL_PATH%\gdalinfo.exe" -json "%%f" > "%%~nf_metadata.txt"
)

echo Metadata extraction complete.
endlocal
pause