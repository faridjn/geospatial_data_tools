@echo off
setlocal enabledelayedexpansion

REM Define directories
set "DIR_INPUT=C:\Farid\TEMP\West_Central_Ortho\Tiff_RAW"
set "DIR_SHAPE=C:\Farid\TEMP\West_Central_Ortho\clipping_boundary\clipping_polygon.shp"
set "DIR_OUTPUT=C:\Farid\TEMP\West_Central_Ortho\Cropped"

REM Create output directory if it doesn't exist
if not exist "%DIR_OUTPUT%" mkdir "%DIR_OUTPUT%"

echo =====================================
echo Step 1: Crop TIFFs with gdalwarp
echo =====================================

for %%f in ("%DIR_INPUT%\*.tif") do (
    echo Cropping: %%~nxf
    gdalwarp -cutline "%DIR_SHAPE%" ^
             -crop_to_cutline ^
             -r near ^
             -of GTiff ^
             -co COMPRESS=JPEG ^
             -co JPEG_QUALITY=85 ^
             -co PHOTOMETRIC=YCBCR ^
             -co TILED=YES ^
             -co BIGTIFF=IF_NEEDED ^
             "%%f" "%DIR_OUTPUT%\cropped_%%~nxf"
)

echo.
echo =====================================
echo Step 2: Generate .tfw files with gdal_translate
echo =====================================

for %%f in ("%DIR_OUTPUT%\cropped_*.tif") do (
    echo Creating world file for: %%~nxf
    gdal_translate -of GTiff -co WORLDFILE=YES "%%f" "%DIR_OUTPUT%\temp_%%~nxf"
    move /Y "%DIR_OUTPUT%\temp_%%~nxf.tfw" "%DIR_OUTPUT%\%%~nxf.tfw"
    del /Q "%DIR_OUTPUT%\temp_%%~nxf"
)

echo.
echo All done!
pause
