:: ==========================================================
:: Author: Farid Javadnejad
:: Date: 2025-05-19
:: Last Update: 2025-05-19

:: ==========================================================
:: DESCRIPTION:
:: - Applies a fixed horizontal translation (dE, dN) to GeoTIFF images
:: - Updates georeferencing metadata only (no reprojection, no resampling)
:: - Preserves original CRS and pixel values
:: - Assumes north-up rasters (no rotation or skew)
:: - Processes all GeoTIFFs in the input directory
:: - Writes shifted copies to OUT_SUBDIR
:: - Original source images remain unchanged
:: - Designed for GDAL / OSGeo4W command-line workflows

:: DISCLAIMER:
:: This script was developed with the assistance of AI tools for review,
:: simplification, and validation. Final responsibility for use and results
:: remains with the user.
:: ==========================================================

@echo off
SETLOCAL EnableDelayedExpansion

REM === Configuration ===
SET "INPUT_DIR=P:\2026\Imagery"
SET "dE=0.7"
SET "dN=0.4"

REM Create output subfolder if it does not exist
SET "OUT_SUBDIR=SHIFTED"
IF NOT EXIST "%INPUT_DIR%\%OUT_SUBDIR%" (
    mkdir "%INPUT_DIR%\%OUT_SUBDIR%"
)

echo ============================================
echo Shifting all GeoTIFFs in: %INPUT_DIR%
echo Output subfolder: %OUT_SUBDIR%
echo Delta E (Easting):  %dE%
echo Delta N (Northing): %dN%
echo ============================================
echo.

REM Process all .tif and .tiff files
FOR %%F IN ("%INPUT_DIR%\*.tif" "%INPUT_DIR%\*.tiff") DO (
    echo --------------------------------------------
    echo Processing: %%~nxF

    REM Output path (same name, new folder)
    SET "OUTPUT=%INPUT_DIR%\%OUT_SUBDIR%\%%~nxF"

    REM Get Upper Left
    FOR /F "tokens=2,3 delims=(,)" %%A IN (
        'gdalinfo "%%F" ^| findstr /C:"Upper Left"'
    ) DO (
        SET "ULX=%%A"
        SET "ULY=%%B"
    )

    REM Get Lower Right
    FOR /F "tokens=2,3 delims=(,)" %%A IN (
        'gdalinfo "%%F" ^| findstr /C:"Lower Right"'
    ) DO (
        SET "LRX=%%A"
        SET "LRY=%%B"
    )

    REM Strip spaces
    SET ULX=!ULX: =!
    SET ULY=!ULY: =!
    SET LRX=!LRX: =!
    SET LRY=!LRY: =!

    REM Compute shifted coordinates (Python handles floats safely)
    python -c ^
        "print(f'{!ULX!+%dE%} {!ULY!+%dN%} {!LRX!+%dE%} {!LRY!+%dN%}')" ^
        > "%TEMP%\coords.txt"

    SET /P NEW_COORDS=<"%TEMP%\coords.txt"
    DEL "%TEMP%\coords.txt"

    REM Apply shift (metadata-only)
    gdal_translate -of GTiff -a_ullr !NEW_COORDS! "%%F" "!OUTPUT!"

    echo   Created: !OUTPUT!
)

echo.
echo ============================================
echo Done.
echo ============================================
pause