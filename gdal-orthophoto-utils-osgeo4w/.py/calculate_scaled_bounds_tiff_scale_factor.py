import sys
import os
from osgeo import gdal

input_file = sys.argv[1]
output_file = sys.argv[2]
scale_factor = float(sys.argv[3])

ds = gdal.Open(input_file)
if ds is None:
    raise FileNotFoundError(f"❌ Could not open input file: {input_file}")

gt = ds.GetGeoTransform()

# Original bounds
ulx = gt[0]
uly = gt[3]
lrx = ulx + gt[1] * ds.RasterXSize
lry = uly + gt[5] * ds.RasterYSize

# Scaled bounds
new_ulx = ulx * scale_factor
new_uly = uly * scale_factor
new_lrx = lrx * scale_factor
new_lry = lry * scale_factor

# Scaled dimensions
new_width = int(ds.RasterXSize / scale_factor)
new_height = int(ds.RasterYSize / scale_factor)

# Run gdal_translate with scaled bounds and output size
cmd = f'gdal_translate -a_ullr {new_ulx} {new_uly} {new_lrx} {new_lry} -co COMPRESS=LZW -co TILED=YES -co BIGTIFF=IF_SAFER "{input_file}" "{output_file}"'

print(f"Running:\n{cmd}")
os.system(cmd)