import os

# Configuration
folder = r"C:\Users\USFJ139860\Downloads\US0038705.2979 - Orthoimage\Nearmap_EPSG6529_20240601"
target_ext = ".jpg"  # Change this to your primary file extension
prefix = "tile"

# List all files
files = os.listdir(folder)

# Identify base names for the main image files
target_files = sorted([f for f in files if f.lower().endswith(target_ext)])
target_bases = [f[: -len(target_ext)] for f in target_files]  # strip .jpg only

# Rename files for each base
for idx, base in enumerate(target_bases, start=1):
    new_base = f"{prefix}_{idx:03d}"
    # Match any file starting with the original base name + the target_ext
    for f in files:
        if f.startswith(base + target_ext):
            suffix = f[len(base):]  # e.g. .jpg, .jpg.aux.xml
            old_path = os.path.join(folder, f)
            new_filename = new_base + suffix
            new_path = os.path.join(folder, new_filename)
            print(f"Renaming: {f} -> {new_filename}")
            os.rename(old_path, new_path)
