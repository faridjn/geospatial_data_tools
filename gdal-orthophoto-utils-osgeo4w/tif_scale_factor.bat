@echo off
:: Set GDAL path and update PATH
set "GDAL_PATH=C:\Program Files\QGIS 3.40.10\bin"
set PATH=%GDAL_PATH%;%PATH%

REM ---- User-defined variables ----
set "scale_factor=1.0003464900"

set "input_path=P:\2025\NOGAL CANYON\02_PRODUCTION\04_QA_QC\SURFACE_COMPARE\2025 - 2019 Updated\Raster"
set "file_name=DTM2025-minus-1100980_XDTM_clipped_rendered.tif"
set "output_path=%input_path%"

REM ---- Derived paths ----
set "input_file=%input_path%\%file_name%"
set "output_file=%output_path%\%file_name:.tif=_scaled.tif%"

REM ---- Call Python script from .py subfolder ----
python ".py\calculate_scaled_bounds_tiff_scale_factor.py" "%input_file%" "%output_file%" %scale_factor%

pause