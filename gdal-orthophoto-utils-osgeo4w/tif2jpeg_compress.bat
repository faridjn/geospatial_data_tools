@echo off
setlocal EnableDelayedExpansion

:: === CONFIGURATION ===
set "DIR_INPUT=P:\2025\SNL-IGLOO\RS\02_PRODUCTION\06_OTHER_TOOLS\Nearmap\TrueOrthoGeoTIFF"
set "DIR_OUTPUT=%DIR_INPUT%\Compressed"
set "JPEG_QUALITY=85"

if not exist "%DIR_OUTPUT%" (
    mkdir "%DIR_OUTPUT%"
)

echo.
echo ============================================================
echo  Converting GeoTIFF → JPEG (.jpg) + JGW world files
echo ------------------------------------------------------------
echo  Input : "%DIR_INPUT%"
echo  Output: "%DIR_OUTPUT%"
echo  Quality: %JPEG_QUALITY%
echo ============================================================
echo.

:: ================================================
:: PROCESS ALL TIFF FILES
:: ================================================
for %%f in ("%DIR_INPUT%\*.tif") do (
    echo ------------------------------------------------------------
    echo Processing: %%~nxf

    :: Detect if the TIFF has an alpha channel
    gdalinfo "%%f" 2>&1 | findstr /i "ColorInterp=Alpha" >NUL
    set "HAS_ALPHA=!ERRORLEVEL!"

    if "!HAS_ALPHA!"=="0" (
        echo Alpha channel detected: Converting RGB only
        gdal_translate "%%f" "%DIR_OUTPUT%\%%~nf.jpg" ^
            -b 1 -b 2 -b 3 ^
            -of JPEG ^
            -co QUALITY=%JPEG_QUALITY% ^
            -co WORLDFILE=YES
    ) else (
        echo No alpha channel: Standard JPEG conversion
        gdal_translate "%%f" "%DIR_OUTPUT%\%%~nf.jpg" ^
            -of JPEG ^
            -co QUALITY=%JPEG_QUALITY% ^
            -co WORLDFILE=YES
    )
)

:: ================================================
:: FIX WORLD FILE EXTENSIONS
:: Normalize .wld or .jpgw → .jgw
:: ================================================
pushd "%DIR_OUTPUT%"

for %%x in (*.wld *.jpgw) do (
    echo Renaming: %%x → %%~nx.jgw
    ren "%%x" "%%~nx.jgw" 2>NUL
)

popd

echo.
echo Done!
pause
