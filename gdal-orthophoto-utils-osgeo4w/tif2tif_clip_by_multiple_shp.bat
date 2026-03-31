:: ==========================================================
:: Author: Farid Javadnejad
:: Date: 2025-09-17
:: Last Update: 2026-03-31

:: ==========================================================
:: DESCRIPTION:
:: - Clips GeoTIFF images using shapefiles as cutlines
:: - Handles 4-band images by converting to 3-band RGB after clipping
:: - Resamples to specified GSD (Ground Sample Distance)
:: - OUTPUT: JPEG-compressed GeoTIFFs at 90% quality
:: - Optimized for Autodesk Civil 3D compatibility
:: ==========================================================

@echo off
setlocal enabledelayedexpansion
set "GDAL_PATH=C:\Program Files\QGIS 3.40.10\bin"
set PATH=%GDAL_PATH%;%PATH%

:: ==========================================================
:: DESCRIPTION:
:: - Converts 4-band TIFFs to 3-band RGB
:: - Clips using shapefiles
:: - Resamples to specified GSD (Ground Sample Distance)
:: - Applies JPEG compression
:: - Builds pyramids for Civil 3D
:: ==========================================================

@echo off
setlocal enabledelayedexpansion
set "GDAL_PATH=C:\Program Files\QGIS 3.40.10\bin"
set PATH=%GDAL_PATH%;%PATH%

:: ==========================================================
:: CONFIGURATION SECTION
:: ==========================================================
:: GSD (Ground Sample Distance) - pixel resolution in CRS units
:: Default: 0.0833 feet (1 inch ≈ 0.0254 meters)
:: Assumes CRS is in feet (e.g., State Plane)
:: Common values:
::   0.0417 ft (0.5 inch ≈ 0.0127 m)
::   0.0833 ft (1 inch   ≈ 0.0254 m)
::   0.1667 ft (2 inches ≈ 0.0508 m)
::   0.25   ft (3 inches ≈ 0.0762 m)
set "GSD=0.0833"
set "GSD_UNIT=ft"

:: Resampling method for resolution change
:: Options: near (fastest), bilinear (balanced), cubic (best quality, recommended for UAS orthophotos)
set "RESAMPLE_METHOD=cubic"
set "JPEG_QUALITY=85"

:: ==========================================================
:: DIRECTORY CONFIGURATION
:: ==========================================================
set "DIR_INPUT=P:\2026\NM_SR_185\02_PRODUCTION\01_PIX4D\SR 185\exports"
set "DIR_SHAPE=P:\2026\NM_SR_185\02_PRODUCTION\01_PIX4D\SR 185\exports\Clip"
set "DIR_OUTPUT=%DIR_INPUT%\TILES"
set "DIR_TEMP=%DIR_INPUT%\TEMP"

:: Create directories
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
echo JPEG Quality:     %JPEG_QUALITY%
echo ==========================================
echo.

:: Process .tif and .tiff files
for %%e in (tif tiff) do (
  for %%f in ("%DIR_INPUT%\*.%%e") do (
    for %%s in ("%DIR_SHAPE%\*.shp") do (
        echo Processing: %%~nxf with %%~nxs

        set "IMG_NAME=%%~nf"
        set "SHP_NAME=%%~ns"
        set "TEMP_RGB=%DIR_TEMP%\!IMG_NAME!_RGB.tif"
        set "OUT_TIF=%DIR_OUTPUT%\!IMG_NAME!-!SHP_NAME!.tif"

        :: Step 1: Convert to 3-band RGB (drop alpha if exists)
        echo   [1/3] Converting to 3-band RGB...
        gdal_translate -b 1 -b 2 -b 3 ^
                       -co COMPRESS=NONE ^
                       -co TILED=YES ^
                       "%%f" "!TEMP_RGB!"

        :: Step 2: Clip, resample, and apply JPEG compression
        echo   [2/3] Clipping, resampling to %GSD% %GSD_UNIT%, and compressing...
        gdalwarp -overwrite ^
                 -cutline "%%s" ^
                 -crop_to_cutline ^
                 -tr %GSD% %GSD% ^
                 -r %RESAMPLE_METHOD% ^
                 -of GTiff ^
                 -co COMPRESS=JPEG ^
                 -co JPEG_QUALITY=%JPEG_QUALITY% ^
                 -co PHOTOMETRIC=YCBCR ^
                 -co TILED=YES ^
                 -co BIGTIFF=NO ^
                 "!TEMP_RGB!" "!OUT_TIF!"

        :: Step 3: Build pyramids for Civil 3D
        echo   [3/3] Building pyramids...
        gdaladdo -r average -overwrite "!OUT_TIF!" 2 4 8 16 32

        :: Cleanup temp file
        del "!TEMP_RGB!"

        echo   Completed: !OUT_TIF!
        echo.
    )
  )
)

:: Remove temp directory
rmdir "%DIR_TEMP%"

echo ==========================================
echo All done! Files created in:
echo %DIR_OUTPUT%
echo ==========================================
pause
