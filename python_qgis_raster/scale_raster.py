import os
from qgis.core import QgsRasterLayer

# =====================================
# Configuration: Directories & Files
# =====================================

# Grid-to-Ground scale factor
SCALE_FACTOR = 1.0003181600  # Scale factor for x and y

# Directory containing orthomosaic 
ORTHO_DIR = r"C:\Farid\Projects\20250219 - West Central\UAS\07_DELIVERABLES\orthomosaic"
ortho_file_read = os.path.join(ORTHO_DIR, "West_Central_Pix4D-orthomosaic.jpg")


# =====================================
# Extract Raster Metadata & Create JGW Files
# =====================================

# Load raster layer in QGIS
raster_layer = QgsRasterLayer(ortho_file_read, "Raster Layer")

# Validate raster layer
if not raster_layer.isValid():
    raise RuntimeError("Error: Raster layer is not valid!")

# Extract geospatial metadata
extent = raster_layer.extent()
width, height = raster_layer.width(), raster_layer.height()
gsd_x = (extent.xMaximum() - extent.xMinimum()) / width
gsd_y = (extent.yMaximum() - extent.yMinimum()) / height

# Define rotation values (assuming north-oriented data)
theta_x, theta_y = 0, 0

# Extract NW corner coordinates
x0, y0 = extent.xMinimum(), extent.yMaximum()

# Generate grid-based .jgw file
grid_jgw = os.path.join(ORTHO_DIR, "orthoimage_grid.jgw")
with open(grid_jgw, 'w') as f:
    f.write(f"{gsd_x}\n{theta_y}\n{theta_x}\n{-gsd_y}\n{x0}\n{y0}\n")

print(f"Grid .jgw file created: {grid_jgw}")

# =====================================
# Apply Scale Factor & Generate Ground JGW
# =====================================

# Compute new scaled resolution and coordinates
new_resolution_x = gsd_x * SCALE_FACTOR
new_resolution_y = gsd_y * SCALE_FACTOR
new_x0 = x0 * SCALE_FACTOR
new_y0 = y0 * SCALE_FACTOR

# Generate scaled (ground-adjusted) .jgw file
scaled_jgw = os.path.join(ORTHO_DIR, "orthoimage_ground.jgw")
with open(scaled_jgw, 'w') as f:
    f.write(f"{new_resolution_x}\n{theta_y}\n{theta_x}\n{-new_resolution_y}\n{new_x0}\n{new_y0}\n")

print(f"Scaled .jgw file created: {scaled_jgw}")