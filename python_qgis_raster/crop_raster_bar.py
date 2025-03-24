import os
from osgeo import gdal
from qgis.core import (
    QgsApplication,
    QgsTask,
    QgsMessageLog,
    Qgis,
    QgsProcessingFeedback
)

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
ortho_file_write = os.path.join(OUTPUT_DIR, "orthomosaic.jpg")

# =====================================
# GDAL Processing Task with Progress Bar
# =====================================

class RasterClippingTask(QgsTask):
    """QGIS Task to run GDAL clipping operation with a progress bar."""

    def __init__(self, description, ortho_file_read, clipping_boundary_file, ortho_file_write):
        super().__init__(description, QgsTask.CanCancel)
        self.ortho_file_read = ortho_file_read
        self.clipping_boundary_file = clipping_boundary_file
        self.ortho_file_write = ortho_file_write
        self.feedback = QgsProcessingFeedback()

    def run(self):
        try:
            self.feedback.pushInfo("Starting raster clipping...")

            # Set GDAL cache (2GB)
            gdal.SetCacheMax(2 * 1024 * 1024 * 1024)

            # Create Virtual Raster (VRT) for efficient processing
            vrt_path = os.path.join(OUTPUT_DIR, "virtual_raster.vrt")
            vrt = gdal.Translate(vrt_path, self.ortho_file_read, format="VRT")

            # Validate VRT creation
            if vrt is None or not os.path.exists(vrt_path):
                self.feedback.reportError(f"Failed to create VRT file: {vrt_path}")
                return False

            # Open the VRT dataset
            dataset = gdal.Open(vrt_path)
            if dataset is None:
                self.feedback.reportError(f"Unable to open VRT file: {vrt_path}")
                return False

            self.feedback.pushInfo("VRT created successfully.")

            # Perform clipping operation with GDAL Warp
            clipped_output = gdal.Warp(
                destNameOrDestDS=self.ortho_file_write,
                srcDSOrSrcDSTab=dataset,
                cutlineDSName=self.clipping_boundary_file,
                cropToCutline=True,
                format='JPEG',
                dstNodata=0,
                options=["QUALITY=95", "COMPRESS=JPEG", "TILED=YES", "BLOCKXSIZE=256", "BLOCKYSIZE=256"],
                callback=self.gdal_progress  # Attach progress callback
            )

            # Validate clipping operation
            if clipped_output is None:
                self.feedback.reportError(f"Failed to clip raster and save to: {self.ortho_file_write}")
                return False

            self.feedback.pushInfo(f"Clipped image saved to: {self.ortho_file_write}")

            # Cleanup
            dataset = None
            clipped_output = None
            vrt = None

            return True

        except Exception as e:
            self.feedback.reportError(f"Error: {str(e)}")
            return False

    def finished(self, result):
        if result:
            QgsMessageLog.logMessage("Raster clipping completed successfully!", "Raster Clipping", Qgis.Success)
        else:
            QgsMessageLog.logMessage("Raster clipping failed!", "Raster Clipping", Qgis.Critical)

    def gdal_progress(self, complete, message, data):
        """Updates progress bar in QGIS based on GDAL's progress callback."""
        progress_percent = int(complete * 100)
        self.feedback.setProgress(progress_percent)
        return 1  # Continue processing

# =====================================
# Run the Task in QGIS
# =====================================

task = RasterClippingTask("Clipping Raster", ortho_file_read, clipping_boundary_file, ortho_file_write)
QgsApplication.taskManager().addTask(task)
