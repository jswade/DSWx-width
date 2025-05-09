#!/usr/bin/env python3
# ******************************************************************************
# SWOT_Pixcvec_Decode.py
# ******************************************************************************

# Purpose:
# This script reformats values in the SWOT PIXC product from .nc to .shp

# Author:
# Jeffrey Wade,  Renato Frasson, 2024

# ******************************************************************************
# Import Python modules
# ******************************************************************************
import sys
import xarray as xr
import pandas as pd
import geopandas as gpd
from shapely import Point


# ******************************************************************************
# Declaration of variables (given as command line arguments)
# ******************************************************************************
# 1 - nc_in
# 2 - utm_in
# 3 - shp_out


# ******************************************************************************
# Get command line arguments
# ******************************************************************************
IS_arg = len(sys.argv)
if IS_arg != 4:
    print('ERROR - 3 arguments must be used')
    raise SystemExit(22)

nc_in = sys.argv[1]
utm_in = sys.argv[2]
shp_out = sys.argv[3]


# ******************************************************************************
# Check if inputs exist
# ******************************************************************************
try:
    with open(nc_in) as file:
        pass
except IOError:
    print('ERROR - Unable to open ' + nc_in)
    raise SystemExit(22)


# ******************************************************************************
# Reformat SWOT PIXCVec .nc to .shp
# ******************************************************************************
print('Converting from .nc to .shp')
# Load PIXCVEC dataset
ds = xr.open_dataset(nc_in)

# Reformat node_id values to strings
num_val = [x.decode('utf-8') if x != b'' else '0' for x in ds.node_id.values]
ds = ds.assign(node_id_str=('points', num_val))

# Retrieve lat and lon
lat_val = ds.latitude_vectorproc.values
lon_val = ds.longitude_vectorproc.values

# Retrieve heights
height_val = ds.height_vectorproc.values

# Create df from values
df = pd.DataFrame({'latitude': lat_val,
                   'longitude': lon_val,
                   'node_id': num_val,
                   'wse': height_val})

# Drop values from df if node_id is 0
df = df[df.node_id != '0']

# Convert to gdf
gdf = gpd.GeoDataFrame(df, geometry=[Point(lon, lat) for lon, lat
                                     in zip(df['longitude'], df['latitude'])],
                       crs='EPSG:4326')

# Reproject to UTM zone
gdf_utm = gdf.to_crs(epsg=utm_in)

# Save to shapefile
gdf.to_file(shp_out)
