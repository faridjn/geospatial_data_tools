:: ==========================================================
:: Author: Farid Javadnejad
:: Date: 2025-06-05
:: Last Update: 2025-09-18
:: 
:: DESCRIPTION:
:: - Script: Automates scaling across multiple files
:: - INPUT directory and SCALE_FACTOR required
:: - Generates both scaled and unscaled .jgw files
:: - Copy required files to the root:
::   - jgw_scaled → GROUND
::   - jgw_unscaled → GRID
::
:: DISCLAIMER:
:: This script was developed with the assistance of AI tools for debugging, reviewing, and testing.
:: ==========================================================

@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: === CONFIGURATION ===
:: Directory & Scale Factor
set "INPUT_DIR=Z:\2025\NOGAL CANYON\02_PRODUCTION\06_EXPORTS\ORTHO\02_INTERMEDIATE\JPG_CLIP\ORTHO_IMAGE_TILES"
set "SCALE_FACTOR=1.0002394192"

::Other
set "UNSCALED_DIR=%INPUT_DIR%\jgw_unscaled"
set "SCALED_DIR=%INPUT_DIR%\jgw_scaled"

:: === DISPLAY SETTINGS ===
echo
echo ============= WORLDFILE (.jgw) Processor ================
echo INPUT_DIR    = %INPUT_DIR%
echo SCALE_FACTOR = %SCALE_FACTOR%
echo =========================================================
echo.
echo Press [Enter] to continue or [Esc] to cancel...

:: === WAIT FOR USER INPUT ===
choice /c YN /n /m "Continue? (Y=Enter / N=Esc): "
if errorlevel 2 (
    echo Operation cancelled.
    exit /b 0
)

:: === VALIDATION ===
if not exist "%INPUT_DIR%" (
    echo [ERROR] Folder does not exist:
    echo         "%INPUT_DIR%"
    pause
    exit /b 1
)

pushd "%INPUT_DIR%" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Cannot access "%INPUT_DIR%".
    pause
    exit /b 1
)

dir /b *.jgw >nul 2>&1
if errorlevel 1 (
    echo [INFO] No .jgw files found in:
    echo        "%INPUT_DIR%"
    popd
    pause
    exit /b 0
)

:: === PROCESSING ===
if not exist "%UNSCALED_DIR%" mkdir "%UNSCALED_DIR%"
for %%F in (*.jgw) do (
    copy /Y "%%F" "%UNSCALED_DIR%\%%~nxF" >nul
)
> "%UNSCALED_DIR%\SCALE_FACTOR.txt" echo 1.000000000000

if not exist "%SCALED_DIR%" mkdir "%SCALED_DIR%"
powershell -NoProfile -Command ^
  "$sf=[double]::Parse('%SCALE_FACTOR%',[System.Globalization.CultureInfo]::InvariantCulture);" ^
  "'{0:F12}' -f $sf" > "%SCALED_DIR%\SCALE_FACTOR.txt"

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