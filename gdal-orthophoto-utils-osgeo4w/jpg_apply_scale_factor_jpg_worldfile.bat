:: ==========================================================
:: Author: Farid Javadnejad
:: Date: 2025-06-05
:: Last Update: 2025-11-20
:: 
:: DESCRIPTION:
:: - Script: Automates scaling across multiple files
:: - INPUT directory and SCALE_FACTOR required
:: - Generates both scaled and unscaled .jgw files
:: - Copy required files to the root:
::   - jgw_scaled → GROUND
::   - jgw_unscaled → GRID
::
:: DESCRIPTION:
:: - Script: Automates the geometric scaling of multiple World Files (.jgw).
:: - Requires a source INPUT directory containing .jgw files and a SCALE_FACTOR.
:: - Uses the full path to PowerShell for cross-compatibility (e.g., in OSGeo4W Shell).
:: - Output: Generates two subdirectories in the INPUT_DIR:
::     1. jgw_unscaled:Contains the original, unscaled worldfiles (Grid: e.g., projection coordinates).
::     2. jgw_scaledL: Contains the scaled worldfiles (Ground: e.g., scaled for use in photogrammetry/surveying).
:: - A 'scale_factor.txt' file is written to each output directory documenting the applied factor (1.0 in unscaled, specified factor in scaled).

:: DISCLAIMER:
:: This script was developed with the assistance of AI tools for debugging, reviewing, and testing.
:: ==========================================================

@echo off
setlocal EnableExtensions EnableDelayedExpansion

:: ==========================================================
:: CONFIGURATION & COMMAND DEFINITIONS
:: ==========================================================

:: === File Paths and Scale Factor ===
set "INPUT_DIR=P:\2025\ARROYO DE LOS PINOS\RS\02_PRODUCTION\08_EXPORTS\ORTHO_JPG\TILES_JPG"
set "SCALE_FACTOR=1.000408740600"

:: === Derived Paths ===
set "UNSCALED_DIR=%INPUT_DIR%\jgw_unscaled"
set "SCALED_DIR=%INPUT_DIR%\jgw_scaled"

:: === Command Definitions (for OSGeo4W/Cross-Compatibility) ===
:: Defines the full path to PowerShell to ensure it executes correctly
set "POWERSHELL_CMD=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"

:: ==========================================================
::  DISPLAY SETTINGS & USER INTERACTION
:: ==========================================================
echo
echo ============= WORLDFILE (.jgw) Processor ================
echo INPUT_DIR = %INPUT_DIR%
echo SCALE_FACTOR = %SCALE_FACTOR%
echo PowerShell = %POWERSHELL_CMD%
echo =========================================================
echo.
echo Press [Enter] to continue or [Esc] to cancel...

:: === WAIT FOR USER INPUT ===
choice /c YN /n /m "Continue? (Y=Enter / N=Esc): "
if errorlevel 2 (
    echo Operation cancelled.
    exit /b 0
)

:: ==========================================================
:: VALIDATION & SETUP
:: ==========================================================
if not exist "%INPUT_DIR%" (
    echo [ERROR] Folder does not exist:
    echo         "%INPUT_DIR%"
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
    echo        "%INPUT_DIR%"
    popd
    pause
    exit /b 0
)

:: ==========================================================
:: PROCESSING
:: ==========================================================

:: --- 1. Create and Copy Unscaled Files (GRID) ---
if not exist "%UNSCALED_DIR%" mkdir "%UNSCALED_DIR%"
echo [INFO] Copying originals to "%UNSCALED_DIR%"...
for %%F in (*.jgw) do (
    copy /Y "%%F" "%UNSCALED_DIR%\%%~nxF" >nul
)
> "%UNSCALED_DIR%\scale_factor.txt" echo 1.000000000000

:: --- 2. Create Scaled Directory and Write Factor ---
if not exist "%SCALED_DIR%" mkdir "%SCALED_DIR%"

echo [INFO] Writing SCALE_FACTOR to "%SCALED_DIR%\scale_factor.txt"...
"%POWERSHELL_CMD%" -NoProfile -Command ^
  "$sf=[double]::Parse('%SCALE_FACTOR%',[System.Globalization.CultureInfo]::InvariantCulture);" ^
  "' {0:F12}' -f $sf" > "%SCALED_DIR%\scale_factor.txt"

:: --- 3. Apply Scale Factor to .jgw Files (GROUND) ---
echo [INFO] Applying scale factor and writing scaled files to "%SCALED_DIR%"...
for %%F in (*.jgw) do (
    "%POWERSHELL_CMD%" -NoProfile -Command ^
      "$sf=[double]::Parse('%SCALE_FACTOR%',[System.Globalization.CultureInfo]::InvariantCulture);" ^
      "Get-Content -LiteralPath '%%F' | ForEach-Object { '{0:F12}' -f ([double]::Parse($_,[System.Globalization.CultureInfo]::InvariantCulture) * $sf) } | Set-Content -Encoding ASCII -LiteralPath '%SCALED_DIR%\%%~nxF'"
)

:: ==========================================================
:: CLEANUP & COMPLETION
:: ==========================================================
echo.
echo Done! Originals copied to "jgw_unscaled" and scaled files written to "jgw_scaled".
echo All numeric values written with 12 decimal places.
echo.
popd
pause