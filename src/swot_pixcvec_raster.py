#!/usr/bin/env python3
# ******************************************************************************
# swot_pixcvec_raster.py
# ******************************************************************************

# Purpose:
# This script reformats values in the SWOT PIXCVec product into a raster to
# match resolution of OPERA
# Author:
# Jeffrey Wade,  Renato Frasson, 2024


# ******************************************************************************
# Import Python modules
# ******************************************************************************
import sys
import numpy as np
import rasterio
import geopandas as gpd
from rasterio.features import rasterize


# # ******************************************************************************
# # Set file paths
# # ******************************************************************************
# # Set input file path
# pixcvec_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/'\
#     'output/opera_agg/swot_rast_diff/SWOT_L2_HR_PIXCVec_018_037_230R_'\
#     '20240711T055027_20240711T055039_PIC0_01.shp'

# opera_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'opera_agg/conwater/main_river/opera_14N_2024-06-29_2024-07-13_'\
#     'main_river.tif'

# # Set output file path
# tif_out = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/'\
#     'output/opera_agg/swot_rast_diff/SWOT_L2_HR_PIXCVec_018_037_230R_'\
#     '20240711T055027_20240711T055039_PIC0_01.tif'

# # ******************************************************************************
# # Set file paths
# # ******************************************************************************
# # Set input file path
# pixcvec_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'opera_agg/swot_rast_diff/SWOT_L2_HR_PIXCVec_020_037_230R_20240821T232036_'\
#     '20240821T232047_PIC0_01.shp'

# opera_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'opera_agg/conwater/main_river/opera_14N_2024-08-10_2024-08-24_'\
#     'main_river.tif'

# # Set output file path
# tif_out = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'opera_agg/swot_rast_diff/SWOT_L2_HR_PIXCVec_020_037_230R_20240821T232036_'\
#     '20240821T232047_PIC0_01.tif'

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
# Rasterize PIXCVec product to OPERA grid
# ******************************************************************************
print('Rasterizing PIXCVec to OPERA grid')
# Load pixc shapefile
pixcvec_shp = gpd.read_file(pixcvec_in)

# Load raster and retrieve properties
with rasterio.open(opera_in) as src:
    transform = src.transform
    shape = (src.height, src.width)
    crs = src.crs

# Reproject pixc shapefile
pixcvec_shp = pixcvec_shp.to_crs(crs)

# Extract pixc geometries
shp_val = [(geom, value) for geom, value in zip(pixcvec_shp.geometry,
                                                np.repeat(1, len(pixcvec_shp)))]

# Rasterize pixc points
pixc_rast = rasterize(shp_val, out_shape=shape, transform=transform,
                      fill=np.nan, all_touched=False, dtype='float32')

# Write raster to file
with rasterio.open(tif_out, "w", driver="GTiff", height=shape[0],
                   width=shape[1], count=1, dtype="float32",
                   crs=crs, transform=transform) as dst:
    dst.write(pixc_rast, 1)
