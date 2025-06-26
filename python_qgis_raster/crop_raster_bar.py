import os
from qgis.core import (
    QgsProject,
    QgsVectorLayer,
    QgsRasterLayer,
    QgsProcessingFeedback,
    QgsCoordinateReferenceSystem,
    QgsApplication,
    QgsProcessingParameterRasterLayer
)
import processing

# =====================================
# CONFIGURATION
# =====================================
READ_FOLDER = r'C:\Farid\TEMP\West_Central_Ortho'
READ_FILE_EXT = ".tiff"

OUTPUT_FOLDER = r'C:\Farid\TEMP\West_Central_Ortho\Cropped'

GIS_FOLDER = r'C:\Farid\TEMP\West_Central_Ortho\clipping_boundary'
CLIP_SHAPEFILE = os.path.join(GIS_FOLDER, 'clipping_polygon.shp')

# =====================================
# Load Shapefile
# =====================================
clip_layer = QgsVectorLayer(CLIP_SHAPEFILE, 'clip_layer', 'ogr')
if not clip_layer.isValid():
    raise Exception('Invalid clipping shapefile.')

# =====================================
# Processing Feedback
# =====================================
feedback = QgsProcessingFeedback()

# =====================================
# Loop Through GeoTIFF Files
# =====================================
for filename in os.listdir(READ_FOLDER):
    if filename.lower().endswith(READ_FILE_EXT):
        tif_path = os.path.join(READ_FOLDER, filename)
        raster_layer = QgsRasterLayer(tif_path, filename)

        if not raster_layer.isValid():
            print(f"Skipping invalid raster: {filename}")
            continue

        output_basename = os.path.splitext(filename)[0]
        output_jpg = os.path.join(OUTPUT_FOLDER, f"{output_basename}.jpg")

        # Clip Raster by Polygon
        result = processing.run("gdal:cliprasterbymasklayer", {
            'INPUT': tif_path,
            'MASK': CLIP_SHAPEFILE,
            'SOURCE_CRS': raster_layer.crs().authid(),
            'TARGET_CRS': None,
            'NODATA': None,
            'ALPHA_BAND': False,
            'CROP_TO_CUTLINE': True,
            'KEEP_RESOLUTION': True,
            'OPTIONS': 'COMPRESS=JPEG',
            'DATA_TYPE': 0,  # Use same as input
            'EXTRA': '',
            'OUTPUT': output_jpg
        }, feedback=feedback)

        print(f"Saved clipped raster: {result['OUTPUT']}")
