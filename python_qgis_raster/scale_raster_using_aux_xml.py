import os
import xml.etree.ElementTree as ET

# =====================================
# Configuration: Directories & Files
# =====================================

# Grid-to-Ground scale factor
SCALE_FACTOR = 1.0000

# Directory containing orthomosaic 
ORTHO_DIR = r"C:\Users\USFJ139860\Downloads\EPSG6529_Date20250213_Lat35.062004_Lon-106.581892_Mpp0.075_VertJPEG-0000"
ortho_file_read = os.path.join(ORTHO_DIR, "EPSG6529_Date20250213_Lat35.062004_Lon-106.581892_Mpp0.075_Vert.jpg")
aux_xml_file = ortho_file_read + ".aux.xml"


# =====================================
# Read GeoTransform Values from AUX.XML
# =====================================

def read_geotransform(aux_file):
    if not os.path.exists(aux_file):
        raise FileNotFoundError(f"Error: AUX.XML file not found at {aux_file}")
    
    tree = ET.parse(aux_file)
    root = tree.getroot()
    geotransform = root.find(".//GeoTransform")
    
    if geotransform is None or not geotransform.text:
        raise ValueError("Error: <GeoTransform> not found in AUX.XML file")
    
    values = list(map(float, geotransform.text.split(',')))
    if len(values) != 6:
        raise ValueError("Error: Invalid number of values in <GeoTransform>")
    
    return values

# Extract geotransform values
geo_values = read_geotransform(aux_xml_file)
x0, gsd_x, theta_x, y0, theta_y, gsd_y = geo_values


# =====================================
# Generate JGW Files
# =====================================

grid_jgw = os.path.join(ORTHO_DIR, "grid.jgw")
ground_jgw = os.path.join(ORTHO_DIR, "ground.jgw")
default_jgw = os.path.join(ORTHO_DIR, os.path.splitext(ortho_file_read)[0] + ".jgw") 


with open(grid_jgw, 'w') as f:
    f.write(f"{gsd_x}\n{theta_y}\n{theta_x}\n{gsd_y}\n{x0}\n{y0}\n")
print(f"JGW file created: {jgw_file}")

# Apply scale factor
gsd_x *= SCALE_FACTOR
gsd_y *= SCALE_FACTOR
x0 *= SCALE_FACTOR
y0 *= SCALE_FACTOR


for jgw_file in [ground_jgw, default_jgw]:
    with open(jgw_file, 'w') as f:
        f.write(f"{gsd_x}\n{theta_y}\n{theta_x}\n{gsd_y}\n{x0}\n{y0}\n")
    print(f"JGW file created: {jgw_file}")
