#!/usr/bin/env python3
# ******************************************************************************
# opera_dwnl.py
# ******************************************************************************

# Purpose:
# This script downloads OPERA HLS granules given a target region and
# image acquisition dates.
# Author:
# Jeffrey Wade, 2024


# ******************************************************************************
# Import Python modules
# ******************************************************************************
import geopandas as gpd
import pandas as pd
import glob
import sys
from datetime import datetime
import earthaccess
import requests


# # ******************************************************************************
# # Set file paths
# # ******************************************************************************
# # Set input file paths
# target_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/input/' \
#             'shpfiles/missouri_area.shp'

# node_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'sword/nodes/'

# date1 = '2023-07-01'
# date2 = '2024-10-19'

# # Set output file paths
# opera_out = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/input/' \
#     'opera/conf/'

# tile_out = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/input/'\
#     'opera_tiles/opera_sentinel2_tile_boundaries.kml'


# ******************************************************************************
# Declaration of variables (given as command line arguments)
# ******************************************************************************
# 1 - target_in
# 2 - date1
# 3 - date2
# 4 - opera_out


# ******************************************************************************
# Get command line arguments
# ******************************************************************************
IS_arg = len(sys.argv)
if IS_arg != 7:
    print('ERROR - 6 arguments must be used')
    raise SystemExit(22)

target_in = sys.argv[1]
node_in = sys.argv[2]
date1 = sys.argv[3]
date2 = sys.argv[4]
opera_out = sys.argv[5]
tile_out = sys.argv[6]


# ******************************************************************************
# Check if inputs exist
# ******************************************************************************
try:
    with open(target_in) as file:
        pass
except IOError:
    print('ERROR - Unable to open ' + target_in)
    raise SystemExit(22)

try:
    with open(node_in) as file:
        pass
except IOError:
    print('ERROR - Unable to open ' + node_in)
    raise SystemExit(22)


# ******************************************************************************
# Give authorization to EarthAccess
# ******************************************************************************
print('Authorizing earthaccess')
# # Authorize earthaccess with supplied credentials
# EARTHDATA_USERNAME = '****'
# EARTHDATA_PASSWORD = '****'
# auth = earthaccess.login(strategy="environment")

# Authorize earthaccess with netrc
auth = earthaccess.login(strategy="netrc")


# ******************************************************************************
# Retrieve bounding box of target area
# ******************************************************************************
print('Retrieving target area')
# Read target region shapefile
target_area = gpd.read_file(target_in)
target_area = target_area.to_crs('EPSG:4326')

# Retrieve bounding box of target area (xmin, ymin, xmax, ymax)
xmin, ymin, xmax, ymax = target_area.total_bounds


# ******************************************************************************
# Download tile boundaries and select tiles for download
# ******************************************************************************
# Download OPERA tile boundary file
# https://hls.gsfc.nasa.gov/products-description/tiling-system/
tile_url = 'https://hls.gsfc.nasa.gov/wp-content/uploads/2016/03/'\
    'S2A_OPER_GIP_TILPAR_MPC__20151209T095117_V20150622T000000_'\
    '21000101T000000_B00.kml'

response = requests.get(tile_url, stream=True)
if response.status_code == 200:
    with open(tile_out, 'wb') as file:
        file.write(response.content)
else:
    print(f"Download failed. Status code: {response.status_code}")

# Read OPERA tile boundary kml
tile_gdf = gpd.read_file(tile_out, driver='KML', layer='Features')

# Read node shapefiles
node_files = sorted(glob.glob(node_in + '*.shp'))
node_all = [gpd.read_file(x) for x in node_files]

# Reproject nodes to EPSG 4326
node_reproj = [node.to_crs(epsg=4326) for node in node_all]

# Compute union of all node geometries
node_merged = gpd.GeoDataFrame(pd.concat(node_reproj, ignore_index=True))
node_union = node_merged.union_all()

# Retrieve OPERA tiles that intersect with nodes
int_tiles = tile_gdf[tile_gdf.geometry.intersects(node_union)]
tile_nums = int_tiles.Name.values


# ******************************************************************************
# Retrieve OPERA DSWx granules for target region and dates
# ******************************************************************************
print('Querying earthaccess')
# Query earthaccess HLS product
try:
    results = earthaccess.search_data(short_name="OPERA_L3_DSWX-HLS_V1",
                                      temporal=(date1, date2),
                                      bounding_box=(str(xmin), str(ymin),
                                                    str(xmax), str(ymax)))
except (IOError, IndexError):
    # Raise error if no OPERA results returned for location/time
    print('ERROR - No OPERA results returned')
    raise SystemExit(22)


# ******************************************************************************
# Download OPERA DSWx Confidence layer
# ******************************************************************************
print('Querying earthaccess')
# Prepare query for download
dwnl_list = []

# Select B03_CONF (Confidence) layer from each queried result if tile selected
for result in results:
    for granule in earthaccess.results.DataGranule.data_links(result):
        if 'B03_CONF' in granule:
            # Retrieve tile and check if it is in selected tile_nums
            if granule.split('HLS_T')[1].split('_')[0] in tile_nums:
                dwnl_list.append(granule)

# Download OPERA layers
earthaccess.download(dwnl_list, opera_out)
