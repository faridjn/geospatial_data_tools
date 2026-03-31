:: ==========================================================
:: Author: Farid Javadnejad
:: Date: 2025-09-17
:: Last Update: 2025-10-31

:: ==========================================================
:: DESCRIPTION:
:: - Script: Clips and renders GeoTIFF images using shapefile cutlines
:: - INPUT_DIR: Source GeoTIFFs (.tif / .tiff)
:: - SHAPE_DIR: Shapefiles used for clipping
:: - OUTPUT_DIR: Dynamically created as INPUT_DIR + "TILES"
:: - Output filenames include both image and shapefile names with "-clipped"
:: - Resolution: Fixed to 0.167 ft (user must ensure CRS is in feet)
:: - JPEG compression at 85% quality (default)
:: - NO BIGTIFF option used
:: ==========================================================

@echo off
setlocal enabledelayedexpansion

:: Set GDAL path and update PATH (update if needed)
set "GDAL_PATH=C:\Program Files\QGIS 3.40.10\bin"
set PATH=%GDAL_PATH%;%PATH%

:: Define directories (update as needed)
set "DIR_READ=P:\2026\NM_SR_185\02_PRODUCTION\01_PIX4D\SR 185\exports"
set "DIR_SHAPE=P:\2026\NM_SR_185\02_PRODUCTION\01_PIX4D\SR 185\exports\Clip"

:: Dynamically build output directory as READ + "TILES"
set "DIR_WRITE=%DIR_READ%\TILES"

:: Fixed resolution in feet (5 cm ≈ 0.167 ft)
set "RESOLUTION=0.167"

:: Create output directory if it doesn't exist
if not exist "%DIR_WRITE%" mkdir "%DIR_WRITE%"

:: Configure GDAL progress display
set "CPL_PROGRESS_FORMAT=PERCENT"

echo ==========================================
echo Input Directory:  %DIR_READ%
echo Output Directory: %DIR_WRITE%
echo Shape Directory:  %DIR_SHAPE%
echo Fixed GSD: %RESOLUTION% ft
echo ==========================================
echo Processing: Clip and Render TIFFs with JPEG Compression
echo.

:: Process both .tif and .tiff extensions
for %%e in (tif tiff) do (
  for %%f in ("%DIR_READ%\*.%%e") do (
    echo ------------------------------------------
    echo Processing Raster: %%~nxf

    for %%s in ("%DIR_SHAPE%\*.shp") do (
        echo   Clipping with shapefile: %%~nxs

        :: Build output filename: originalname-shapename-clipped.tif
        set "IMG_NAME=%%~nf"
        set "SHP_NAME=%%~ns"
        set "OUT_FILE=%DIR_WRITE%\!IMG_NAME!-!SHP_NAME!-clipped.tif"

        :: Clip and render with gdalwarp
        gdalwarp --config CPL_PROGRESS_FORMAT "PERCENT" ^
                 -cutline "%%s" ^
                 -crop_to_cutline ^
                 -tr !RESOLUTION! !RESOLUTION! ^
                 -r bilinear ^
                 -of GTiff ^
                 -co COMPRESS=JPEG ^
                 -co JPEG_QUALITY=85 ^
                 -co PHOTOMETRIC=YCBCR ^
                 -co TILED=YES ^
                 "%%f" "!OUT_FILE!"

        if errorlevel 1 (
            echo   ERROR: Failed to process %%~nxf with %%~nxs
        ) else (
            echo   Building pyramids...
            gdaladdo -r average "!OUT_FILE!" 2 4 8 16
            echo   Completed: !OUT_FILE!
        )
        echo.
    )
  )
)

echo ==========================================
echo All processing complete!
echo Output files saved to: %DIR_WRITE%
echo ==========================================
pause
