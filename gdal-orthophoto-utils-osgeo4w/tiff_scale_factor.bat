@echo off
REM ---- User-defined variables ----
set "scale_factor=0.999760638"

set "input_path=P:\2025\NOGAL CANYON\02_PRODUCTION\04_QA_QC\SURFACE_COMPARE\2025 - 2019"
set "file_name=DEM_diff_rendered.tif"
set "output_path=%input_path%"

REM ---- Derived paths ----
set "input_file=%input_path%\%file_name%"
set "output_file=%output_path%\%file_name:.tif=_scaled.tif%"

REM ---- Call Python script from .py subfolder ----
python ".py\calculate_scaled_bounds.py" "%input_file%" "%output_file%" %scale_factor%

pause