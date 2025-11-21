@echo off
REM === Configuration ===
set "GDAL_PATH=C:\Program Files\QGIS 3.40.9\bin"
set "DIR_INPUT=D:\Temp\TrueOrthoGeoTIFF\scaled"
set "DIR_OUTPUT=%DIR_INPUT%\Compressed"
set "JPEG_QUALITY=85"

if not exist "%DIR_OUTPUT%" mkdir "%DIR_OUTPUT%"
set PATH=%GDAL_PATH%;%PATH%

echo Starting JPEG compression and overview generation...

for %%f in ("%DIR_INPUT%\*.tif") do (
    echo Processing: %%~nxf

    REM Check band count
    for /f "tokens=*" %%b in ('gdalinfo "%%f" ^| find "Band 4"') do set HAS_ALPHA=1

    if defined HAS_ALPHA (
        echo RGBA detected -> Dropping alpha channel
        gdal_translate "%%f" "%DIR_OUTPUT%\%%~nxf" ^
            -b 1 -b 2 -b 3 ^
            -co COMPRESS=JPEG ^
            -co JPEG_QUALITY=%JPEG_QUALITY% ^
            -co TILED=YES
    ) else (
        echo RGB or other -> Compressing as JPEG
        gdal_translate "%%f" "%DIR_OUTPUT%\%%~nxf" ^
            -co COMPRESS=JPEG ^
            -co JPEG_QUALITY=%JPEG_QUALITY% ^
            -co TILED=YES
    )

    REM Build overview pyramids (JPEG for consistency)
    gdaladdo "%DIR_OUTPUT%\%%~nxf" 4 8 16 --config COMPRESS_OVERVIEW JPEG --config JPEG_QUALITY_OVERVIEW %JPEG_QUALITY%

    REM Reset HAS_ALPHA for next file
    set HAS_ALPHA=
)

echo Done!
pause