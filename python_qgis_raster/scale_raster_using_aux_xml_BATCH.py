import os
import xml.etree.ElementTree as ET

# =====================================
# Configuration
# =====================================

SCALE_FACTOR = 1.0
ORTHO_DIR = r"Z:\2025\NOGAL CANYON\02_PRODUCTION\06_EXPORTS\ORTHO\02_INTERMEDIATE\JPG\JPG_TILES"
IMAGE_FORMAT = ".jpg"

# Flags to control output
WRITE_DEFAULT_JGW = 0 # 0 = GRID_JGW, 1 = GROUND_JGW
WRITE_GRID_JGW = True
WRITE_GROUND_JGW = False

# =====================================
# Read GeoTransform Values from AUX.XML
# =====================================

def read_geotransform(aux_file):
    if not os.path.exists(aux_file):
        raise FileNotFoundError(f"AUX.XML not found: {aux_file}")
    
    tree = ET.parse(aux_file)
    root = tree.getroot()
    geotransform = root.find(".//GeoTransform")
    
    if geotransform is None or not geotransform.text:
        raise ValueError("GeoTransform tag missing or empty")

    values = list(map(float, geotransform.text.split(',')))
    if len(values) != 6:
        raise ValueError("GeoTransform must contain 6 values")
    
    return values

# =====================================
# Process Each Image and Generate JGW
# =====================================

for filename in os.listdir(ORTHO_DIR):
    if filename.lower().endswith(".jpg"):
        image_path = os.path.join(ORTHO_DIR, filename)
        aux_xml_path = image_path + ".aux.xml"

        try:
            # Read unique georeference data for this image
            x0, gsd_x, theta_x, y0, theta_y, gsd_y = read_geotransform(aux_xml_path)

            # GRID JGW (no scaling)
            grid_jgw_path = os.path.splitext(image_path)[0] + "_grid.jgw"
            if WRITE_GRID_JGW or WRITE_DEFAULT_JGW == 0:
                with open(grid_jgw_path, 'w') as f:
                    f.write(f"{gsd_x}\n{theta_y}\n{theta_x}\n{gsd_y}\n{x0}\n{y0}\n")
                print(f"Created: {grid_jgw_path}")

            # Apply scaling for ground/default JGW
            gsd_x_scaled = gsd_x * SCALE_FACTOR
            gsd_y_scaled = gsd_y * SCALE_FACTOR
            x0_scaled = x0 * SCALE_FACTOR
            y0_scaled = y0 * SCALE_FACTOR

            # GROUND JGW
            ground_jgw_path = os.path.splitext(image_path)[0] + "_ground.jgw"
            if WRITE_GROUND_JGW or WRITE_DEFAULT_JGW == 1:
                with open(ground_jgw_path, 'w') as f:
                    f.write(f"{gsd_x_scaled}\n{theta_y}\n{theta_x}\n{gsd_y_scaled}\n{x0_scaled}\n{y0_scaled}\n")
                print(f"Created: {ground_jgw_path}")

            # DEFAULT JGW
            default_jgw_path = os.path.splitext(image_path)[0] + ".jgw"
            if WRITE_DEFAULT_JGW == 0:
                # Default is GRID JGW
                with open(default_jgw_path, 'w') as f:
                    f.write(f"{gsd_x}\n{theta_y}\n{theta_x}\n{gsd_y}\n{x0}\n{y0}\n")
                print(f"Created default (grid): {default_jgw_path}")
            elif WRITE_DEFAULT_JGW == 1:
                # Default is GROUND JGW
                with open(default_jgw_path, 'w') as f:
                    f.write(f"{gsd_x_scaled}\n{theta_y}\n{theta_x}\n{gsd_y_scaled}\n{x0_scaled}\n{y0_scaled}\n")
                print(f"Created default (ground): {default_jgw_path}")

        except Exception as e:
            print(f"Error processing {filename}: {e}")

#=====================================
# Write SCALE_FACTOR to file
# =====================================
scale_file_path = os.path.join(ORTHO_DIR, "scale_factor.txt")
with open(scale_file_path, 'w') as scale_file:
    scale_file.write(f"{SCALE_FACTOR}\n")
print(f"Written scale factor to: {scale_file_path}")