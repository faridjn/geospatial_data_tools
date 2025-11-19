@echo off
REM Compress all .tif files in DIR using ZSTD and add pyramids for faster rendering
REM Usage: compress_tifs.bat [DIR] [ZSTD_LEVEL]
REM DIR = source folder containing .tif files
REM ZSTD_LEVEL = compression level (1-9), default is 6

SETLOCAL ENABLEEXTENSIONS

:: Get input parameters
SET "DIR=%~1"
IF "%DIR%"=="" SET "DIR=P:\2025\SNL-IGLOO\RS\02_PRODUCTION\06_OTHER_TOOLS\Nearmap\TrueOrthoGeoTIFF"

SET "ZSTD_LEVEL=%~2"
IF "%ZSTD_LEVEL%"=="" SET "ZSTD_LEVEL=6"

:: Create COMPRESS subfolder if it doesn't exist
SET "COMPRESS_DIR=%DIR%\COMPRESS"
IF NOT EXIST "%COMPRESS_DIR%" (
    mkdir "%COMPRESS_DIR%"
)

:: Loop through all .tif files in DIR
FOR %%F IN ("%DIR%\*.tif") DO (
    ECHO Compressing %%F to %COMPRESS_DIR%\%%~nxF using ZSTD level %ZSTD_LEVEL%...
    gdal_translate "%%F" "%COMPRESS_DIR%\%%~nxF" ^
        -co COMPRESS=ZSTD ^
        -co ZSTD_LEVEL=%ZSTD_LEVEL% ^
        -co TILED=YES

    ECHO Adding pyramids (overviews) to %COMPRESS_DIR%\%%~nxF...
    gdaladdo "%COMPRESS_DIR%\%%~nxF" 2 4 8 16 32 --config COMPRESS_OVERVIEW ZSTD --config ZSTD_LEVEL %ZSTD_LEVEL%
)

ECHO Compression and pyramid generation completed. Files saved in "%COMPRESS_DIR%".
ENDLOCAL
