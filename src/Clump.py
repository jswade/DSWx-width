#!/usr/bin/env python3
# ******************************************************************************
# Clump.py
# ******************************************************************************

# Purpose:
# This script reclassifies pixel values in the OPERA DSWx tif and clumps
# regions of equal pixel values together

# Author:
# Jeffrey Wade, Dinuke Munasinghe, Renato Frasson, 2024


# ******************************************************************************
# Import Python modules
# ******************************************************************************
# from whitebox_workflows import WbEnvironment
import rasterio.mask
import numpy as np
import geopandas as gpd
import os
import sys
import glob
import re
from rasterio.features import shapes
from rasterio.mask import mask
from pandas import DataFrame
from geopandas import GeoDataFrame
from shapely.geometry import shape


# ******************************************************************************
# Set file paths
# ******************************************************************************
# # Set location of WBT directory
# work_dir = '../'
# os.chdir(work_dir)
# sys.path.append(work_dir)

# # Set working directory to project root
# script_dir = os.path.dirname(os.path.abspath(__file__))
# work_dir = os.path.abspath(os.path.join(script_dir, '..'))
# os.chdir(work_dir)
# sys.path.append(work_dir)

# # Import whitebox packages
# from WBT.whitebox_tools import WhiteboxTools
# wbt = WhiteboxTools()
# wbe = WbEnvironment()
# wbt.work_dir = work_dir
# wbt.set_verbose_mode(True)

work_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))  # Adjust as needed
sys.path.append(work_dir)

# Import whitebox packages
from WBT.whitebox_tools import WhiteboxTools
from whitebox_workflows import WbEnvironment

wbt = WhiteboxTools()
wbe = WbEnvironment()
wbt.work_dir = work_dir
wbt.set_verbose_mode(True)

# ******************************************************************************
# Declaration of variables (given as command line arguments)
# ******************************************************************************
# 1 - tif_in
# 2 - voronoi_in
# 3 - utm_str
# 4 - clump_out


# ******************************************************************************
# Get command line arguments
# ******************************************************************************
IS_arg = len(sys.argv)
if IS_arg != 5:
    print('ERROR - 4 arguments must be used')
    raise SystemExit(22)

tif_in = sys.argv[1]
voronoi_in = sys.argv[2]
utm_str = sys.argv[3]
clump_out = sys.argv[4]


# ******************************************************************************
# Check if inputs exist
# ******************************************************************************
try:
    if os.path.isdir(tif_in):
        pass
except IOError:
    print('ERROR - '+tif_in+' invalid folder path')
    raise SystemExit(22)

try:
    with open(voronoi_in) as file:
        pass
except IOError:
    print('ERROR - Unable to open ' + voronoi_in)
    raise SystemExit(22)


# ******************************************************************************
# Retrieve unique months from merged tiles
# ******************************************************************************
# Get list of file paths to merged tiles in UTM zone
tif_files = sorted(list(glob.iglob(tif_in + '*' + utm_str + '*.tif')))

# Retrieve unique aggregation dates
mon_yrs = sorted(list(set([re.search(r'(\d{4}-\d{2}-\d{2}_\d{4}-\d{2}-\d{2})',
                                     x).group(1) for x in tif_files])))


# ******************************************************************************
# Reclassify TIF pixel values
# ******************************************************************************
print('Reclassifying tif values')

# Set chunk size
chunk_size = 5000

# Define pixel reclassification
reclass_map = {
    0: 0,  # No data
    1: 1,  # Open Water
    2: 1,  # Partial Surface Water
    252: 252,  # Snow/Ice
    253: 0,  # Cloud/Cloud shadow
    255: 0  # No Data
}

# Set original water values
water_val = [1, 2]

# Initialize valid mon_yrs
val_mon_yrs = []

# Loop through merged files
for i in range(len(tif_files)):

    print(i)

    # Set file path for reclassified tif
    fp_reclass = clump_out + 'reclass/opera_' + utm_str + '_' + mon_yrs[i] +   \
        '_reclassified.tif'

    # Reclassify OPERA DSWx
    with rasterio.open(tif_files[i]) as src:

        # Read profile and array
        profile = src.profile
        data = src.read()

        # Add compression to raster
        profile.update({
            'compress': 'LZW'
        })

        # Check if raster has any water pixels
        if np.sum(np.isin(data, water_val)) > 0:

            # Add mon_yr to new list
            val_mon_yrs.append(mon_yrs[i])

            # Create output raster
            with rasterio.open(fp_reclass, 'w', **profile) as dst:
                for j in range(0, src.height, chunk_size):

                    # print(j)

                    # Read a horizontal chunk of data
                    window = rasterio.windows.Window(0, j, src.width,
                                                     min(chunk_size,
                                                         src.height - j))
                    array = src.read(window=window)

                    # Reclassify pixel values
                    vector_reclass = np.vectorize(reclass_map.get)
                    array_reclass = vector_reclass(array)

                    # Write the reclassified chunk to the output file
                    dst.write(array_reclass, window=window)

        # If no water pixels, skip to next file
        else:
            print('No water pixels')
            # continue


# ******************************************************************************
# Clump regions of similar pixels
# ******************************************************************************
print('Clump similar pixels')
# Read in the Thiessen Polygons
thiessen_polygons = gpd.read_file(voronoi_in)

# Retrieve polygon geometries of thiessen polygons
poly_shapes = [feature["geometry"] for feature in
               thiessen_polygons.__geo_interface__["features"]]

for i in range(len(val_mon_yrs)):

    print(i)

    # Generate reclassified raster fp
    fp_reclass = clump_out + 'reclass/opera_' + utm_str + '_' +                \
        val_mon_yrs[i] + '_reclassified.tif'

    # Generate clumped raster fp
    fp_clump = clump_out + 'clumpedras_poly/opera_' + utm_str + '_' +          \
        val_mon_yrs[i] + '_clumpedRas.tif'
    fp_clip = clump_out + 'clumpedras_poly/opera_' + utm_str + '_' +           \
        val_mon_yrs[i] + '_clumpedRas_clip.tif'
    fp_shp = clump_out + 'clumpedras_poly/opera_' + utm_str + '_' +            \
        val_mon_yrs[i] + '_clumpedRas_poly.shp'

    # # Use the clump tool to create regions
    # wbt.clump(fp_reclass, fp_clump, diag=True, zero_back=True)
    
    ret_code = wbt.clump(fp_reclass, fp_clump, diag=True, zero_back=True)

    if ret_code != 0 or not os.path.exists(fp_clump):
        print(f"Clump failed or output missing for: {fp_reclass}")
        continue

    # Clip clumped raster to thiessen polygons
    with rasterio.open(fp_clump) as src:

        clip_image, clip_transform = mask(src, poly_shapes, crop=True)

        # Update raster metadata
        clip_meta = src.meta.copy()
        clip_meta.update({
            "driver": "GTiff",
            "height": clip_image.shape[1],
            "width": clip_image.shape[2],
            "transform": clip_transform,
            "compress": "LZW"
        })

        # Write clipped raster to file
        with rasterio.open(fp_clip, "w", **clip_meta) as dest:
            dest.write(clip_image)

    # Convert the raster into polygons
    with rasterio.open(fp_clip) as src:
        data = src.read(1, masked=True)
        shape_gen = ((shape(s), v) for s, v in shapes(data,
                                                      transform=src.transform))
        df = DataFrame(shape_gen, columns=['geometry', 'class'])
        df = df.loc[df['class'] != 0]
        gdf = GeoDataFrame(df['class'], geometry=df.geometry, crs=src.crs)
        gdf.to_file(fp_shp,
                    driver='ESRI Shapefile')

    # Delete clumped and clipped raster to save space
    os.remove(fp_clump)
    os.remove(fp_clip)
