@echo off
REM Set OSGeo4W root
set "OSGEO4W_ROOT=C:\Program Files\QGIS 3.40.12"

REM Activate OSGeo environment
call "%OSGEO4W_ROOT%\bin\o4w_env.bat"
call "%OSGEO4W_ROOT%\bin\gdalenv.bat"

REM Change directory
cd /d D:\Users\Farid\GitHub\geospatial_data_tools\gdal-orthophoto-utils-osgeo4w

REM Start interactive shell
cmd
