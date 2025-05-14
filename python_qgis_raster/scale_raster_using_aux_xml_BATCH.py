import os
import xml.etree.ElementTree as ET

# =====================================
# Configuration
# =====================================

SCALE_FACTOR = 1.0000
ORTHO_DIR = r"C:\Farid\Orthoimage\Nearmap_EPSG6529_20240601"

# Flags to control output
WRITE_DEFAULT_JGW = True
WRITE_GRID_JGW = False
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
    if filename.lower().endswith('.jpg'):
        image_path = os.path.join(ORTHO_DIR, filename)
        aux_xml_path = image_path + ".aux.xml"

        try:
            # Read unique georeference data for this image
            x0, gsd_x, theta_x, y0, theta_y, gsd_y = read_geotransform(aux_xml_path)

            # GRID JGW (no scaling)
            if WRITE_GRID_JGW:
                grid_jgw_path = os.path.splitext(image_path)[0] + "_grid.jgw"
                with open(grid_jgw_path, 'w') as f:
                    f.write(f"{gsd_x}\n{theta_y}\n{theta_x}\n{gsd_y}\n{x0}\n{y0}\n")
                print(f"Created: {grid_jgw_path}")

            # Apply scaling for ground/default JGW
            gsd_x_scaled = gsd_x * SCALE_FACTOR
            gsd_y_scaled = gsd_y * SCALE_FACTOR
            x0_scaled = x0 * SCALE_FACTOR
            y0_scaled = y0 * SCALE_FACTOR

            # GROUND JGW
            if WRITE_GROUND_JGW:
                ground_jgw_path = os.path.splitext(image_path)[0] + "_ground.jgw"
                with open(ground_jgw_path, 'w') as f:
                    f.write(f"{gsd_x_scaled}\n{theta_y}\n{theta_x}\n{gsd_y_scaled}\n{x0_scaled}\n{y0_scaled}\n")
                print(f"Created: {ground_jgw_path}")

            # DEFAULT JGW
            if WRITE_DEFAULT_JGW:
                default_jgw_path = os.path.splitext(image_path)[0] + ".jgw"
                with open(default_jgw_path, 'w') as f:
                    f.write(f"{gsd_x_scaled}\n{theta_y}\n{theta_x}\n{gsd_y_scaled}\n{x0_scaled}\n{y0_scaled}\n")
                print(f"Created: {default_jgw_path}")

        except Exception as e:
            print(f"Error processing {filename}: {e}")
