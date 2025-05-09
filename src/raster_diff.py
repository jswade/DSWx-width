#!/usr/bin/env python3
# ******************************************************************************
# Raster_Diff.py
# ******************************************************************************
# Purpose:
# Produces a raster of difference between OPERA DSWx main river and SWOT
# rasterized PIXCVec

# Author:
# Jeffrey Wade,  Renato Frasson, 2024

# ******************************************************************************
# Import Python modules
# ******************************************************************************
import sys
import numpy as np
import rasterio


# ******************************************************************************
# Declaration of variables (given as command line arguments)
# ******************************************************************************
# 1 - pixcvec_in
# 2 - opera_in
# 3 - tif_out


# ******************************************************************************
# Get command line arguments
# ******************************************************************************
IS_arg = len(sys.argv)
if IS_arg != 4:
    print('ERROR - 3 arguments must be used')
    raise SystemExit(22)

pixcvec_in = sys.argv[1]
opera_in = sys.argv[2]
tif_out = sys.argv[3]


# ******************************************************************************
# Check if inputs exist
# ******************************************************************************
try:
    with open(pixcvec_in) as file:
        pass
except IOError:
    print('ERROR - Unable to open ' + pixcvec_in)
    raise SystemExit(22)

try:
    with open(opera_in) as file:
        pass
except IOError:
    print('ERROR - Unable to open ' + opera_in)
    raise SystemExit(22)


# ******************************************************************************
# Create difference raster between SWOT PIXCVec and OPERA rasters
# ******************************************************************************
print('Creating raster of difference between SWOT and OPERA')
# Load rasters
pixcvec_tif = rasterio.open(pixcvec_in)
opera_tif = rasterio.open(opera_in)

# Read rasters as arrays
pixcvec_arr = pixcvec_tif.read(1)
opera_arr = opera_tif.read(1)

# Create output array
output_arr = np.zeros_like(pixcvec_arr, dtype=np.uint8)

# Apply conditions to identify overlap between raster
# 1: Both OPERA and PIXC VEC Water
# 2: Only OPERA Water
# 3: Only SWOT Water
output_arr[(opera_arr == 2) | (opera_arr == 4) & (pixcvec_arr == 1)] = 1
output_arr[((pixcvec_arr == 0) | np.isnan(pixcvec_arr)) &
           ((opera_arr == 2) | (opera_arr == 4))] = 2
output_arr[(pixcvec_arr == 1) & ~((opera_arr == 2) | (opera_arr == 4))] = 3

# Write raster to file
with rasterio.open(tif_out, "w", driver="GTiff",
                   height=pixcvec_tif.height, width=pixcvec_tif.width,
                   count=1, dtype="uint8", crs=pixcvec_tif.crs,
                   transform=pixcvec_tif.transform) as dst:
    dst.write(output_arr, 1)

# Close raster files
pixcvec_tif.close()
opera_tif.close()
