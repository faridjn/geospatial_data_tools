import rasterio
from rasterio.transform import Affine
import os

# Define scale factor and output directory
scale_factor = 0.999760638

DIR = r"P:\2025\NOGAL CANYON\02_PRODUCTION\04_QA_QC\SURFACE_COMPARE\2025 - 2019"
FILE_BASE = "DEM_diff_rendered.tif"

# Generate timestamped filename
output_filename = f"{FILE_BASE}_scaled.tif"
output_path = os.path.join(DIR, output_filename)

# Ensure the output directory exists
os.makedirs(DIR, exist_ok=True)

# Process the input GeoTIFF and apply scale
with rasterio.open("input_geotiff.tif") as src:
    image_data = src.read()
    original_transform = src.transform

    # Apply scale factor to pixel size
    scaled_transform = Affine(
        original_transform.a * scale_factor, original_transform.b, original_transform.c,
        original_transform.d, original_transform.e * scale_factor, original_transform.f
    )

    new_meta = src.meta.copy()
    new_meta.update({
        "transform": scaled_transform,
        "width": int(src.width / scale_factor),
        "height": int(src.height / scale_factor)
    })

    # Save the scaled GeoTIFF
    with rasterio.open(output_path, "w", **new_meta) as dst:
        dst.write(image_data)

print(f"Scaled GeoTIFF saved to: {output_path}")