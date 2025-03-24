import os
from osgeo import gdal

# =====================================
# Configuration: Directories & Files
# =====================================

# Orthoimage 
ORTHO_DIR = r"C:\Farid\Projects\20250219 - West Central\UAS\03_PHOTOGRAMETRY\Pix4D_Wingtra\exports"
ortho_file_read = os.path.join(ORTHO_DIR, "West_Central_Pix4D-orthomosaic.jpg")

# Clipping boundary shapefile
SHAPEFILE_DIR = r"C:\Farid\Projects\20250219 - West Central\UAS\06_GIS\clipping_boundary"
clipping_boundary_file = os.path.join(SHAPEFILE_DIR, "clipping_polygon.shp")

# Output directory
OUTPUT_DIR = r"C:\Farid\Projects\20250219 - West Central\UAS\07_DELIVERABLES\orthomosaic"
os.makedirs(OUTPUT_DIR, exist_ok=True)  # Ensure output directory exists
ortho_file_write = os.path.join(OUTPUT_DIR, "orthoimage.jpg")

# =====================================
# GDAL: Virtual Raster & Clipping
# =====================================

# Set GDAL cache to optimize memory usage (2GB)
gdal.SetCacheMax(2 * 1024 * 1024 * 1024)

# Create Virtual Raster (VRT) for efficient processing
vrt_path = os.path.join(OUTPUT_DIR, "virtual_raster.vrt")
vrt = gdal.Translate(vrt_path, ortho_file_read, format="VRT")

# Validate VRT creation
if vrt is None or not os.path.exists(vrt_path):
    raise RuntimeError(f"Failed to create VRT file: {vrt_path}")

# Open the VRT dataset
dataset = gdal.Open(vrt_path)
if dataset is None:
    raise RuntimeError(f"Unable to open VRT file: {vrt_path}")

# Perform clipping operation with GDAL Warp
clipped_output = gdal.Warp(
    destNameOrDestDS=ortho_file_write,
    srcDSOrSrcDSTab=dataset,
    cutlineDSName=clipping_boundary_file,
    cropToCutline=True,
    format='JPEG',
    dstNodata=0,  # Set NoData value if required
    options=["QUALITY=95", "COMPRESS=JPEG", "TILED=YES", "BLOCKXSIZE=256", "BLOCKYSIZE=256"]
)

# Validate clipping operation
if clipped_output is None:
    raise RuntimeError(f"Failed to clip raster and save to: {ortho_file_write}")

print(f"Clipped image saved to: {ortho_file_write}")

# Cleanup
dataset = None
clipped_output = None
vrt = None
