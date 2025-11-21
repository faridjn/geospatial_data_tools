:: ==========================================================
:: Author: Farid Javadnejad
:: Date: 2025-09-17
:: Last Update: 2025-11-20

:: ==========================================================
:: DESCRIPTION:
:: - Script: Clips GeoTIFF images using multiple SHP files as cutlines
:: - INPUT_DIR: Source GeoTIFFs (.tif / .tiff)
:: - SHAPE_DIR: Shapefiles used for clipping
:: - OUTPUT_DIR: Cropped Images (.jpg)
:: - Output filenames include both image and shapefile names
:: - Ensures .jgw worldfiles are created
::
:: DISCLAIMER:
:: This script was developed with the assistance of AI tools for debugging, reviewing, and testing.
:: ==========================================================
@echo off
setlocal EnableDelayedExpansion

:: ==========================================
:: ⚙️ Configure GDAL/QGIS binaries
:: ==========================================
set "GDAL_PATH=C:\Program Files\QGIS 3.40.10\bin"

if exist "%GDAL_PATH%" (
    echo GDAL path found: %GDAL_PATH%
    set "PATH=%GDAL_PATH%;%PATH%"
) else (
    echo ERROR: GDAL path not found at %GDAL_PATH%
    pause
    exit /b 1
)

---

:: ==========================================
:: 📁 Project directories (edit as needed)
:: ==========================================
set "DIR_INPUT=P:\2025\SNL-IGLOO\RS\02_PRODUCTION\06_OTHER_TOOLS\Nearmap\TrueOrthoGeoTIFF"
set "DIR_OUTPUT=P:\2025\SNL-IGLOO\RS\02_PRODUCTION\06_OTHER_TOOLS\Nearmap\TrueOrthoGeoTIFF"

:: Define the SINGLE shapefile to use for clipping
set "SHAPE_FILE=P:\2025\SNL-IGLOO\RS\02_PRODUCTION\06_OTHER_TOOLS\Nearmap\QGIS\Shapefile\My_Clip_Area.shp"

:: Output subfolder for cropped JPEGs
set "DIR_JPG=%DIR_OUTPUT%\TILES_JPG"
set "DIR_TEMP=%DIR_OUTPUT%\TEMP_VRT" 

:: Get the name of the shapefile without extension
for %%s in ("%SHAPE_FILE%") do set "SHP_NAME=%%~ns"

:: Create output and temporary directories
if not exist "%DIR_OUTPUT%" mkdir "%DIR_OUTPUT%"
if not exist "%DIR_JPG%" mkdir "%DIR_JPG%"
if not exist "%DIR_TEMP%" mkdir "%DIR_TEMP%"

:: ------------------------------
:: GDAL progress formatting
:: ------------------------------
set "CPL_PROGRESS_FORMAT=PERCENT"

echo ==========================================
echo Input Directory:  %DIR_INPUT%
echo Output Directory: %DIR_JPG%
echo Clip Shapefile:   %SHAPE_FILE%
echo ==========================================
echo Clip TIFFs and export as JPEG (.jpg + .jgw)

:: Process both .tif and .tiff
for %%e in (tif tiff) do (
    for %%f in ("%DIR_INPUT%\*.%%e") do (

        echo(
        echo Processing Image: %%~nxf 

        set "IMG_NAME=%%~nf"
        set "OUT_BASE=!IMG_NAME!-!SHP_NAME!"
        set "OUT_VRT=%DIR_TEMP%\!OUT_BASE!.vrt"
        set "OUT_JPG=%DIR_JPG%\!OUT_BASE!.jpg"

        :: 1. Clip the TIFF to a VRT file (intermediate step)
        :: -of VRT handles the clipping operation without writing NO_DATA pixels.
        gdalwarp ^
          --config CPL_PROGRESS_FORMAT PERCENT ^
          -cutline "%SHAPE_FILE%" ^
          -crop_to_cutline ^
          -r near ^
          -of VRT ^
          -cblend 0 ^
          -overwrite ^
          "%%~ff" "!OUT_VRT!"
        
        :: Check if the VRT file was created successfully (i.e., the tile overlaps the shapefile)
        if exist "!OUT_VRT!" (
            
            :: 2. Translate VRT to JPEG (final step)
            :: gdal_translate automatically calculates the tight bounding box of the VRT's data,
            :: effectively cropping out the NO_DATA area from the previous step.
            :: -co WORLDFILE=YES ensures the JGW file matches this tightly cropped extent.
            gdal_translate ^
              -of JPEG ^
              -co QUALITY=85 ^
              -co WORLDFILE=YES ^
              "!OUT_VRT!" "!OUT_JPG!"

            :: 3. Rename world files (renames .jpgw to .jgw, just in case)
            pushd "%DIR_JPG%"
            for %%x in ("!OUT_BASE!.wld" "!OUT_BASE!.jpgw") do (
                if exist "%%x" ren "%%x" "!OUT_BASE!.jgw"
            )
            popd

            :: 4. Clean up the temporary VRT file
            del "!OUT_VRT!"
            
        ) else (
            echo WARNING: No overlap detected between %%~nxf and %SHP_NAME%. Skipping JPEG creation.
        )
    )
)

:: Optional: Clean up the temporary VRT directory (if empty)
rmdir "%DIR_TEMP%" 2>nul

echo ==========================================
echo Processing Complete.
echo ==========================================
endlocal