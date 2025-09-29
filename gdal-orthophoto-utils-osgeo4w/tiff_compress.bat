@echo off
REM === Set your working directory and input filename ===
set "C:\Users\USFJ139860\DC\ACCDocs\WSP USA projects (AMER)\ABQ200-I-25_Nogal_Canyon\Project Files\Existing\Survey\QC\SURFACE_COMPARE\2025"
set "FILENAME=DEM_2025_Clipped.tif"

REM === Extract base name without extension ===
for %%F in ("%FILENAME%") do set BASENAME=%%~nF

REM === Set output filename ===
set OUTNAME=%BASENAME%._compressed.tif

REM === Run GDAL compression with Byte conversion ===
gdal_translate -ot Byte -scale -of GTiff -co COMPRESS=JPEG -co JPEG_QUALITY=95 "%DIR%\%FILENAME%" "%DIR%\%OUTNAME%"

echo Compression complete: %OUTNAME%
pause
