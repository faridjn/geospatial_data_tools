:: ==========================================================
:: Author: Farid Javadnejad
:: Date: 2025-09-17
:: Last Update: 2026-04-06

:: ==========================================================
:: DESCRIPTION:
:: - Clips GeoTIFF images using shapefiles as clipping geometry
:: - OPTIONAL: Handles 4-band images by converting to 3-band RGB first
:: - Resamples to specified GSD (Ground Sample Distance)
:: - Exports JPEG-compressed GeoTIFFs at 85% quality
:: - Optimized for Autodesk Civil 3D compatibility

:: DISCLAIMER:
:: This script was developed with the assistance of AI tools for debugging, reviewing, and testing.
:: ==========================================================


@echo off
setlocal enabledelayedexpansion
set "GDAL_PATH=C:\Program Files\QGIS 3.40.10\bin"
set PATH=%GDAL_PATH%;%PATH%

:: ==========================================================
:: CONFIGURATION SECTION
:: ==========================================================
:: GSD (Ground Sample Distance) - pixel resolution in CRS units
:: Common values:
::   0.0417 ft (0.5 inch ≈ 0.0127 m)
::   0.0656 ft (0.8 inch ≈ 0.020 m)
::   0.0833 ft (1 inch   ≈ 0.0254 m) [DEFAULT]
::   0.1667 ft (2 inches ≈ 0.0508 m)
::   0.25   ft (3 inches ≈ 0.0762 m)
set "GSD=0.0833"
set "GSD_UNIT=ft"

:: Resampling method for resolution change
:: Options: near (fastest), bilinear (balanced), cubic (best quality, slowest)
set "RESAMPLE_METHOD=cubic"

:: Convert to 3-band RGB (TRUE/FALSE)
set "CONVERT_TO_RGB=FALSE"

:: ==========================================================
:: DIRECTORY CONFIGURATION
:: ==========================================================
set "DIR_INPUT=P:\2026\DAC_CARVER_RD\02_PRODUCTION\01_PIX4D\DAC CARVER RD-260326AGW\exports"
set "DIR_SHAPE=P:\2026\DAC_CARVER_RD\02_PRODUCTION\05_GIS\Shapefiles"


:: Create directories
set "DIR_OUTPUT=%DIR_INPUT%\TILES"
set "DIR_TEMP=%DIR_OUTPUT%\TEMP"
if not exist "%DIR_OUTPUT%" mkdir "%DIR_OUTPUT%"
if not exist "%DIR_TEMP%" mkdir "%DIR_TEMP%"

set "CPL_PROGRESS_FORMAT=PERCENT"

:: ==========================================================
:: PROCESSING START
:: ==========================================================
echo ==========================================
echo Input Directory:  %DIR_INPUT%
echo Output Directory: %DIR_OUTPUT%
echo Shape Directory:  %DIR_SHAPE%
echo ------------------------------------------
echo GSD Resolution:   %GSD% %GSD_UNIT%
echo Resampling:       %RESAMPLE_METHOD%
echo Convert to RGB:   %CONVERT_TO_RGB%
echo ==========================================
echo.

:: Process .tif and .tiff files
for %%e in (tif tiff) do (
  for %%f in ("%DIR_INPUT%\*.%%e") do (
    for %%s in ("%DIR_SHAPE%\*.shp") do (
        echo Processing: %%~nxf with %%~nxs

        set "IMG_NAME=%%~nf"
        set "SHP_NAME=%%~ns"
        set "TEMP_RGB=%DIR_TEMP%\!IMG_NAME!_TEMP.tif"
        set "OUT_TIF=%DIR_OUTPUT%\!IMG_NAME!-!SHP_NAME!.tif"

        if /I "!CONVERT_TO_RGB!"=="TRUE" (
            echo   [1/3] Converting to 3-band RGB...
            gdal_translate -b 1 -b 2 -b 3 ^
                           -co COMPRESS=NONE ^
                           -co TILED=YES ^
                           "%%f" "!TEMP_RGB!"
        ) else (
            echo   [1/3] Skipping RGB conversion...
            set "TEMP_RGB=%%f"
        )

        echo   [2/3] Clipping and resampling to %GSD% %GSD_UNIT% GSD...
        gdalwarp -cutline "%%s" ^
                 -crop_to_cutline ^
                 -tr %GSD% %GSD% ^
                 -r %RESAMPLE_METHOD% ^
                 -of GTiff ^
                 -co COMPRESS=JPEG ^
                 -co JPEG_QUALITY=85 ^
                 -co PHOTOMETRIC=YCBCR ^
                 -co TILED=YES ^
                 -co BIGTIFF=NO ^
                 "!TEMP_RGB!" "!OUT_TIF!"

        echo   [3/3] Building pyramids...
        gdaladdo -r average "!OUT_TIF!" 2 4 8 16 32

        echo   Completed: !OUT_TIF!
        echo.
    )
  )
)

:: Remove temp directory if RGB conversion was used
if /I "%CONVERT_TO_RGB%"=="TRUE" (
    if exist "%DIR_TEMP%" rmdir /s /q "%DIR_TEMP%"
)

echo ==========================================
echo All done! Files created in:
echo %DIR_OUTPUT%
echo ==========================================
pause
