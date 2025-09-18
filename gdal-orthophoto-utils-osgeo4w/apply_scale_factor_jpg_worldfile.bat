@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ==========================================================
:: JGW Processor
:: - Copies originals to jgw_unscaled (same filenames)
:: - Scales all 6 lines to jgw_scaled (12 decimal places)
:: - Writes scale_factor.txt in both folders
:: ==========================================================

:: === CONFIGURATION ===
:: Directories
set "INPUT_DIR=Z:\2025\NOGAL CANYON\02_PRODUCTION\06_EXPORTS\ORTHO\02_INTERMEDIATE\JPG_CLIP\ORTHO_IMAGE_TILES"
set "UNSCALED_DIR=%INPUT_DIR%\jgw_unscaled"
set "SCALED_DIR=%INPUT_DIR%\jgw_scaled"

:: Scale Factor
set "SCALE_FACTOR=1.0002394192"

echo.
echo ===== JGW Processor =====
echo INPUT_DIR    = %INPUT_DIR%
echo SCALE_FACTOR = %SCALE_FACTOR%
echo =========================
echo.

:: Validate input directory
if not exist "%INPUT_DIR%" (
    echo [ERROR] Folder does not exist:
    echo         "%INPUT_DIR%"
    echo.
    pause
    exit /b 1
)

pushd "%INPUT_DIR%" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Cannot access "%INPUT_DIR%".
    echo.
    pause
    exit /b 1
)

:: Ensure there are .jgw files
dir /b *.jgw >nul 2>&1
if errorlevel 1 (
    echo [INFO] No .jgw files found in:
    echo        "%INPUT_DIR%"
    echo.
    popd
    pause
    exit /b 0
)

:: === Create jgw_unscaled and copy originals
if not exist "%UNSCALED_DIR%" mkdir "%UNSCALED_DIR%"
for %%F in (*.jgw) do (
    copy /Y "%%F" "%UNSCALED_DIR%\%%~nxF" >nul
)

:: Write scale_factor.txt for unscaled (12 decimals, value = 1)
> "%UNSCALED_DIR%\SCALE_FACTOR.txt" echo 1.000000000000

:: === Create jgw_scaled and write scale_factor.txt with 12 decimals
if not exist "%SCALED_DIR%" mkdir "%SCALED_DIR%"
powershell -NoProfile -Command ^
  "$sf=[double]::Parse('%SCALE_FACTOR%',[System.Globalization.CultureInfo]::InvariantCulture);" ^
  "'{0:F12}' -f $sf" > "%SCALED_DIR%\SCALE_FACTOR.txt"

:: === Scale all 6 lines in each .jgw
echo [INFO] Applying scale factor...
for %%F in (*.jgw) do (
    powershell -NoProfile -Command ^
      "$sf=[double]::Parse('%SCALE_FACTOR%',[System.Globalization.CultureInfo]::InvariantCulture);" ^
      "Get-Content -LiteralPath '%%F' | ForEach-Object { '{0:F12}' -f ([double]::Parse($_,[System.Globalization.CultureInfo]::InvariantCulture) * $sf) } | Set-Content -Encoding ASCII -LiteralPath '%SCALED_DIR%\%%~nxF'"
)

echo.
echo Done! Originals copied to "jgw_unscaled" and scaled files written to "jgw_scaled".
echo All numeric values written with 12 decimal places.
echo.
popd
pause