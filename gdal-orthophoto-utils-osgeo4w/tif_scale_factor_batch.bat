@echo off
setlocal enableextensions enabledelayedexpansion

REM =========================
REM Configuration / Dependencies
REM =========================
set "QGIS_ROOT=C:\Program Files\QGIS 3.40.12"
set "GDAL_BIN=%QGIS_ROOT%\bin"
set "PYTHON_EXE=%GDAL_BIN%\python.exe"
set "SCRIPT=%~dp0.py\calculate_scaled_bounds_tiff_scale_factor.py"

set "SCALE_FACTOR=1.0003464900"
set "INPUT_DIR=D:\Temp\TrueOrthoGeoTIFF"
set "OUTPUT_DIR=%INPUT_DIR%\scaled"

REM Environment for GDAL/PROJ
set "PATH=%GDAL_BIN%;%PATH%"
set "GDAL_DATA=%QGIS_ROOT%\share\gdal"
set "PROJ_LIB=%QGIS_ROOT%\share\proj"

REM =========================
REM Dependency sanity checks
REM =========================
if not exist "%QGIS_ROOT%" (
    echo ERROR: QGIS_ROOT not found: "%QGIS_ROOT%"
    goto :eof
)
if not exist "%GDAL_BIN%\gdal_translate.exe" (
    echo ERROR: gdal_translate.exe not found in "%GDAL_BIN%"
    goto :eof
)
if not exist "%PYTHON_EXE%" (
    echo ERROR: QGIS python.exe not found at "%PYTHON_EXE%"
    goto :eof
)
if not exist "%SCRIPT%" (
    echo ERROR: Python script not found at "%SCRIPT%"
    goto :eof
)
if not exist "%INPUT_DIR%" (
    echo ERROR: INPUT_DIR not found: "%INPUT_DIR%"
    goto :eof
)

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM Optional warnings
if not exist "%GDAL_DATA%" echo WARNING: GDAL_DATA not found: "%GDAL_DATA%"
if not exist "%PROJ_LIB%" echo WARNING: PROJ_LIB not found: "%PROJ_LIB%"

REM =========================
REM Header
REM =========================
echo Scale factor applied: %SCALE_FACTOR% > "%OUTPUT_DIR%\scale_factor.txt"
echo.
echo Applying horizontal scale factor %SCALE_FACTOR% (no resampling) to GeoTIFFs in:
echo   %INPUT_DIR%
echo Output to:
echo   %OUTPUT_DIR%
echo.

REM =========================
REM Prepare single global PRJ
REM =========================
set "PRJ_GLOBAL=%INPUT_DIR%\Tiles.prj"
set "PRJ_OUT_GLOBAL=%OUTPUT_DIR%\Tiles_scaled.prj"

if exist "%PRJ_GLOBAL%" (
    echo Using global PRJ: "%PRJ_GLOBAL%"
    echo Writing updated PRJ to: "%PRJ_OUT_GLOBAL%"

    REM ---- Safe redirection: use percent expansion for the target path
    set "OUT_PRJ=%PRJ_OUT_GLOBAL%"
    setlocal DisableDelayedExpansion
    >"%OUT_PRJ%" (
        setlocal EnableDelayedExpansion
        for /f "usebackq delims=" %%L in ("%PRJ_GLOBAL%") do (
            set "line=%%L"
            echo !line! | findstr /i /c:"PARAMETER[\"Scale_Factor\"" >nul && (
                REM If your WKT uses a trailing comma after parameters, add it here:
                REM echo PARAMETER["Scale_Factor",%SCALE_FACTOR%],
                echo PARAMETER["Scale_Factor",%SCALE_FACTOR%]
            ) || (
                echo !line!
            )
        )
        endlocal
    )
    endlocal
) else (
    echo WARNING: Global PRJ not found at "%PRJ_GLOBAL%". No PRJ will be generated.
)

REM =========================
REM Process rasters
REM (Variant B: your Python script must NOT use -outsize/-r)
REM =========================
for /f "delims=" %%f in ('
    dir /b /a:-d "%INPUT_DIR%\*.tif" "%INPUT_DIR%\*.tiff" 2^>nul
') do (
    echo Processing: %%f

    set "infile=%INPUT_DIR%\%%f"
    set "base=%%~nf"
    set "ext=%%~xf"
    set "outfile=%OUTPUT_DIR%\!base!_scaled!ext!"

    "%PYTHON_EXE%" "%SCRIPT%" "!infile!" "!outfile!" %SCALE_FACTOR%
    if errorlevel 1 (
        echo ERROR: Python returned non-zero exit for "!infile!"
    )
)

echo.
echo Done!
pause
endlocal