@echo off
setlocal enabledelayedexpansion

:: Step 1: Get processing folder (default = current folder)
set "PROCESSING_DIR=%~dp0"
set /p INPUT_DIR=Enter processing folder path (default = current folder): 
if not "%INPUT_DIR%"=="" set "PROCESSING_DIR=%INPUT_DIR%"
set "PROCESSING_DIR=%PROCESSING_DIR:"=%"

:: Step 2: Copy all .jgw files to jgw_unscaled as *-unscaled.jgw
set "UNSCALED_DIR=%PROCESSING_DIR%\jgw_unscaled"
if not exist "%UNSCALED_DIR%" mkdir "%UNSCALED_DIR%"

for %%F in ("%PROCESSING_DIR%\*.jgw") do (
    set "BASENAME=%%~nF"
    copy "%%F" "%UNSCALED_DIR%\!BASENAME!-unscaled.jgw" >nul
)

:: Step 3: Get scale factor from user (default = 1.0)
set /p SCALE_FACTOR=Enter scale factor (default = 1.0): 
if "%SCALE_FACTOR%"=="" set SCALE_FACTOR=1.0

:: Step 4 & 5: Read and scale .jgw values into jgw_scaled
set "SCALED_DIR=%PROCESSING_DIR%\jgw_scaled"
if not exist "%SCALED_DIR%" mkdir "%SCALED_DIR%"

for %%F in ("%PROCESSING_DIR%\*.jgw") do (
    set "BASENAME=%%~nF"
    set "SCALED_FILE=%SCALED_DIR%\!BASENAME!-scaled.jgw"
    break > "!SCALED_FILE!" 2>nul

    set "i=0"
    for /f "usebackq delims=" %%L in ("%%F") do (
        set /a i+=1
        set "line=%%L"
        if !i! leq 4 (
            powershell -Command "[math]::Round([double](!line!) * %SCALE_FACTOR%, 10).ToString('F10')" >> "!SCALED_FILE!"
        ) else (
            echo !line! >> "!SCALED_FILE!"
        )
    )
)

:: Step 6: Delete all .jgw files in the processing directory
del "%PROCESSING_DIR%\*.jgw" >nul

:: Step 7: Get scaling mode (default = 0)
set /p SCALING_MODE=Enter scaling mode (0 = UNSCALED, 1 = SCALED, default = 0): 
if "%SCALING_MODE%"=="" set SCALING_MODE=0

:: Step 8: Copy appropriate files back to processing folder
if "%SCALING_MODE%"=="0" (
    for %%F in ("%UNSCALED_DIR%\*-unscaled.jgw") do (
        set "NEWNAME=%%~nxF"
        set "NEWNAME=!NEWNAME:-unscaled=!"
        copy "%%F" "%PROCESSING_DIR%\!NEWNAME!" >nul
    )
) else (
    for %%F in ("%SCALED_DIR%\*-scaled.jgw") do (
        set "NEWNAME=%%~nxF"
        set "NEWNAME=!NEWNAME:-scaled=!"
        copy "%%F" "%PROCESSING_DIR%\!NEWNAME!" >nul
    )
)

:: Step 9: Write scale factor to a .txt file
echo %SCALE_FACTOR% > "%PROCESSING_DIR%\scale_factor.txt"
echo %SCALE_FACTOR% > "%SCALED_DIR%\scale_factor.txt"

echo.
echo Done! JGW files processed with 10-digit precision.
pause
