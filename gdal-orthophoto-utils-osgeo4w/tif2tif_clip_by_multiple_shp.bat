:: ==========================================================
:: Author: Farid Javadnejad
:: Date: 2025-09-17
:: Last Update: 2026-03-31

:: ==========================================================
:: DESCRIPTION:
:: - Clips GeoTIFF images using shapefiles as cutlines
:: - Handles 4-band images by converting to 3-band RGB first
:: - Resamples to specified GSD (Ground Sample Distance)
:: - OUTPUT: JPEG-compressed GeoTIFFs at 85% quality
:: - Optimized for Autodesk Civil 3D compatibility
:: ==========================================================

@echo off
setlocal enabledelayedexpansion
set "GDAL_PATH=C:\Program Files\QGIS 3.40.10\bin"
set PATH=%GDAL_PATH%;%PATH%

:: ==========================================================
:: CONFIGURATION SECTION
:: ==========================================================

:: RGB Conversion Flag
:: true  = Convert to 3-band RGB (drops alpha channel if exists)
:: false = Skip conversion, use original input file directly
set "ENABLE_RGB_CONVERSION=false"

:: GSD Preservation Flag
:: true  = Keep input image GSD (no resampling)
:: false = Resample to specified GSD value below
set "PRESERVE_GSD=true"

:: GSD (Ground Sample Distance) - pixel resolution in CRS units
:: Default: 0.0833 feet (1 inch ≈ 0.0254 meters)
:: Assumes CRS is in feet (e.g., State Plane)
:: Common values:
::   0.0417 ft (0.5 inch ≈ 0.0127 m)
::   0.0656 ft (0.8 inch ≈ 0.020 m)
::   0.0833 ft (1 inch   ≈ 0.0254 m) [DEFAULT]
::   0.1667 ft (2 inches ≈ 0.0508 m)
::   0.25   ft (3 inches ≈ 0.0762 m)
:: NOTE: Only used if PRESERVE_GSD=false
set "GSD=0.0656"
set "GSD_UNIT=ft"

:: Resampling method for resolution change
:: Options: near (fastest), bilinear (balanced), cubic (best quality, slowest)
set "RESAMPLE_METHOD=cubic"

:: ==========================================================
:: DIRECTORY CONFIGURATION
:: ==========================================================

set "DIR_INPUT=P:\2026\NM_SR_185\02_PRODUCTION\01_PIX4D\SR 185\exports"
set "DIR_SHAPE=P:\2026\NM_SR_185\02_PRODUCTION\01_PIX4D\SR 185\exports\Clip"
set "DIR_OUTPUT=%DIR_INPUT%\TILES"
set "DIR_TEMP=%DIR_OUTPUT%\TEMP"

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
echo RGB Conversion:   %ENABLE_RGB_CONVERSION%
echo Preserve GSD:     %PRESERVE_GSD%

if /i "%PRESERVE_GSD%"=="true" (
  echo GSD Resolution:   %GSD% %GSD_UNIT%
  echo Resampling:       %RESAMPLE_METHOD%
	) else (
		echo GSD Resolution:   [Using input resolution]
	)
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
        
        :: Determine source file for clipping step
        set "SOURCE_FILE=%%f"

        :: Step 1: Convert to 3-band RGB (optional based on flag)
        if /i "%ENABLE_RGB_CONVERSION%"=="true" (
            echo   [1/3] Converting to 3-band RGB...
            gdal_translate -b 1 -b 2 -b 3 ^
                           -co COMPRESS=NONE ^
                           -co TILED=YES ^
                           "%%f" "!TEMP_RGB!"
            
            :: Update source file to temp RGB for next step
            set "SOURCE_FILE=!TEMP_RGB!"
        ) else (
            echo   [1/3] Skipping RGB conversion (using original input)
        )

        :: Step 2: Clip and optionally resample based on GSD flag
        if /i "%PRESERVE_GSD%"=="true" (
            echo   [2/3] Clipping with original GSD preserved...
            gdalwarp -cutline "%%s" ^
                     -crop_to_cutline ^
                     -of GTiff ^
                     -co COMPRESS=JPEG ^
                     -co JPEG_QUALITY=85 ^
                     -co PHOTOMETRIC=YCBCR ^
                     -co TILED=YES ^
                     -co BIGTIFF=NO ^
                     "!SOURCE_FILE!" "!OUT_TIF!"
        ) else (
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
                     "!SOURCE_FILE!" "!OUT_TIF!"
        )

        :: Step 3: Build pyramids for Civil 3D
        echo   [3/3] Building pyramids...
        gdaladdo -r average "!OUT_TIF!" 2 4 8 16 32

        echo   Completed: !OUT_TIF!
        echo.
    )
  )
)

:: Remove temp directory
if exist "%DIR_TEMP%" rmdir /