@echo off
setlocal enabledelayedexpansion

:: Set GDAL path
set "GDAL_PATH=C:\Program Files\QGIS 3.40.10\bin"
set PATH=%GDAL_PATH%;%PATH%

:: ==========================================================
:: Compress all GeoTIFF files in a folder using GDAL
:: Output goes to a unique, timestamped subfolder.
:: ==========================================================

:: Working directory
set "DIR=P:\2025\SNL-IGLOO\RS\02_PRODUCTION\06_OTHER_TOOLS\Nearmap\TrueOrthoGeoTIFF"

:: --- Create Timestamped Output Folder ---
:: Get date and time for unique folder name (YYYYMMDD_HHMMSS)
for /f "tokens=2-4 delims=/ " %%a in ('date /t') do (set Today=%%c%%a%%b)
for /f "tokens=1-2 delims=:" %%a in ('time /t') do (set Time=%%a%%b)

:: Format the time string (HHMMSS)
set "HH=%Time:~0,2%"
set "MM=%Time:~2,2%"
set "SS=%Time:~4,2%"
set "HHMMSS=%HH%%MM%%SS%"

set "TIMESTAMP=%Today%_%HHMMSS%"
set "OUTDIR=%DIR%\Compressed_%TIMESTAMP%"

echo ==========================================================
echo Creating unique output folder: %OUTDIR%
mkdir "%OUTDIR%"
if errorlevel 1 (
    echo ERROR: Failed to create output directory. Aborting.
    pause
    exit /b 1
)

:: Default JPEG quality
set JPEG_QUALITY=85
set /p USER_INPUT="Enter JPEG quality (1-100) or press Enter for default (%JPEG_QUALITY%): "
if not "%USER_INPUT%"=="" set JPEG_QUALITY=%USER_INPUT%

echo ==========================================================
echo Checking for .tif files in: %DIR%
echo ==========================================================

:: Check if there are any .tif files
dir "%DIR%\*.tif" >nul 2>&1
if errorlevel 1 (
    echo ERROR: No .tif files found in %DIR%.
    echo Please verify the folder path and try again.
    pause
    exit /b
)

echo ==========================================================
echo Compressing and Building Pyramids for all .tif files in: %DIR%
echo Output folder: %OUTDIR%
echo JPEG Quality: !JPEG_QUALITY!
echo ==========================================================

for %%F in ("%DIR%\*.tif") do (
    set "OUTNAME=%%~nF_compressed.tif"
    :: Define the output path variable inside the loop
    set "OUT_TIF=!OUTDIR!\!OUTNAME!"
    echo Processing: %%~nxF
    
    :: Step 1: Run gdal_translate to compress the file
    :: Using CALL "" to insulate the command for maximum reliability against special characters.
    call ""gdal_translate" -ot Byte -scale -of GTiff -co COMPRESS=JPEG -co JPEG_QUALITY=!JPEG_QUALITY! -co TILED=YES -co BIGTIFF=IF_NEEDED "%%F" "!OUT_TIF!""
    
    :: Check if gdal_translate succeeded (errorlevel 0)
    if not errorlevel 1 (
        echo Done compression: !OUTNAME!
        
        :: Step 2: Build pyramids for performance
        echo Building pyramids (2 4 8 16)...
        call ""gdaladdo" "!OUT_TIF!" 2 4 8 16"
        
        if errorlevel 1 (
            echo WARNING: gdaladdo FAILED for !OUTNAME!.
        ) else (
            echo Pyramids built successfully.
        )
    ) else (
        echo ERROR: gdal_translate failed for %%~nxF. Check for missing GDAL dependencies or file corruption.
    )
)

echo ==========================================================
echo All files processed into: %OUTDIR%
pause