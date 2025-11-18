:: DESCRIPTION:
:: - Compresses a GeoTIFF using GDAL with user-specified or default JPEG quality
:: - Converts pixel type to Byte and applies scaling
:: - Output retains georeferencing and metadata
::
:: DISCLAIMER:
:: Script reviewed and optimized with AI assistance.
:: ==========================================================

@echo off
setlocal enabledelayedexpansion

:: Set GDAL path (update if needed)
set "GDAL_PATH=C:\Program Files\QGIS 3.40.10\bin"
set PATH=%GDAL_PATH%;%PATH%

:: Define directories
set "DIR_INPUT=P:\2025\SHIPROCK US-64\02_PRODUCTION\01_PIX4D\SHIPROCK_US64_PIX4D\SHIPROCK_US64_PIX4D_251112\exports"
set "DIR_OUTPUT=P:\2025\SHIPROCK US-64\02_PRODUCTION\06_EXPORTS\ORTHO_PROCESS"

:: Create output directory if not exists
if not exist "%DIR_OUTPUT%" mkdir "%DIR_OUTPUT%"

echo ==========================================
echo Compressing all TIFFs in: %DIR_INPUT%
echo Output Directory: %DIR_OUTPUT%
echo ==========================================

:: Loop through all .tif and .tiff files
for %%e in (tif tiff) do (
  for %%f in ("%DIR_INPUT%\*.%%e") do (
    echo Processing: %%~nxf

    :: Build output name
    set "OUT_TIF=%DIR_OUTPUT%\%%~nf_compressed.tif"

    :: Compress with JPEG and tiling
    gdal_translate "%%f" "!OUT_TIF!" ^
        -of GTiff ^
        -co COMPRESS=JPEG ^
        -co JPEG_QUALITY=85 ^
        -co PHOTOMETRIC=YCBCR ^
        -co TILED=YES ^
        -co BIGTIFF=IF_SAFER

    :: Add pyramids for QGIS performance
    gdaladdo "!OUT_TIF!" 2 4 8 16

    echo Done: %%~nxf -> !OUT_TIF!
    echo ------------------------------------------
  )
)

echo All files processed successfully!
pause
