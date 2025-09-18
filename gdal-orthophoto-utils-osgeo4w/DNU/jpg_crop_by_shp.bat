@echo off
setlocal enabledelayedexpansion

REM =====================================
REM Define directories
REM =====================================
set "DIR_INPUT=C:\Farid\TEMP\West_Central_Ortho\JPG_RAW"
set "DIR_OUTPUT=C:\Farid\TEMP\West_Central_Ortho\Cropped"
set "DIR_SHAPE=C:\Farid\TEMP\West_Central_Ortho\clipping_boundary\clipping_polygon.shp"


REM Create output directory if it doesn't exist
if not exist "%DIR_OUTPUT%" mkdir "%DIR_OUTPUT%"

echo =====================================
echo Step 1: Crop JPGs using gdalwarp (via temporary TIFF)
echo =====================================

for %%f in ("%DIR_INPUT%\*.jpg") do (
    echo Processing: %%~nxf

    REM Step 1a: Warp (crop) into temporary GeoTIFF
    gdalwarp -cutline "%DIR_SHAPE%" ^
             -crop_to_cutline ^
             -r near ^
             -of GTiff ^
             -co COMPRESS=DEFLATE ^
             -co TILED=YES ^
             -co BIGTIFF=IF_NEEDED ^
             "%%f" "%DIR_OUTPUT%\temp_%%~nf.tif"

    REM Step 1b: Convert to JPEG and generate .jgw
    gdal_translate -of JPEG ^
                   -co WORLDFILE=YES ^
                   -co QUALITY=95 ^
                   "%DIR_OUTPUT%\temp_%%~nf.tif" "%DIR_OUTPUT%\%%~nf.jpg"

    REM Step 1c: Rename .wld to .jgw if necessary
    if exist "%DIR_OUTPUT%\%%~nf.wld" (
        ren "%DIR_OUTPUT%\%%~nf.wld" "%%~nf.jgw"
    )

    REM Step 1d: Clean up temp TIFF
    del /Q "%DIR_OUTPUT%\temp_%%~nf.tif"
)

echo.
echo All done! Cropped JPG + JGW created in %DIR_OUTPUT%
pause
