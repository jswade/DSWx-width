#!/usr/bin/env python3
# ******************************************************************************
# node_comp_metrics.py
# ******************************************************************************

# Purpose:
# This script calculates metrics to compare SWOT and OPERA widths by node
# Author:
# Jeffrey Wade,  Renato Frasson, 2024

# ******************************************************************************
# Import Python modules
# ******************************************************************************
import sys
import os
import glob
import numpy as np
import pandas as pd
import geopandas as gpd
import matplotlib.pyplot as plt


# ******************************************************************************
# Set files paths
# ******************************************************************************
# comp_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'opera/swot_comp/opera_swot_comp_2023-07-01to2024-10-19.csv'

# # Set input to node shapefile
# node_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'sword/nodes/'

# # Set output file paths
# node_out_csv = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/'\
#     'output/opera/node_metrics/swot_opera_node_metrics_2023-07-01'\
#     'to2024-10-19.csv'

# node_out_shp = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/'\
#     'output/opera/node_metrics/swot_opera_node_metrics_2023-07-01'\
#     'to2024-10-19.shp'


# ******************************************************************************
# Declaration of variables (given as command line arguments)
# ******************************************************************************
# 1 - comp_in
# 2 - node_in
# 3 - node_out_csv
# 4 - node_out_shp


# ******************************************************************************
# Get command line arguments
# ******************************************************************************
IS_arg = len(sys.argv)
if IS_arg != 5:
    print('ERROR - 4 arguments must be used')
    raise SystemExit(22)

comp_in = sys.argv[1]
node_in = sys.argv[2]
node_out_csv = sys.argv[3]
node_out_shp = sys.argv[4]


# ******************************************************************************
# Check if inputs exist
# ******************************************************************************
try:
    with open(comp_in) as file:
        pass
except IOError:
    print('ERROR - Unable to open ' + comp_in)
    raise SystemExit(22)

try:
    if os.path.isdir(node_in):
        pass
except IOError:
    print('ERROR - '+node_in+' invalid folder path')
    raise SystemExit(22)


# ******************************************************************************
# Load files
# ******************************************************************************
print('Reading files')
# ------------------------------------------------------------------------------
# OPERA/SWOT Observations
# ------------------------------------------------------------------------------
# Read OPERA/SWOT width comparisons
comp_df = pd.read_csv(comp_in)

# Retrieve unique node ids
node_ids = np.unique(comp_df.node_id)

# ------------------------------------------------------------------------------
# SWORD Node Shapefiles
# ------------------------------------------------------------------------------
# Read SWOT node shapefiles
node_files = sorted(list(glob.iglob(node_in + '*.shp')))
node_all = [gpd.read_file(x) for x in node_files]

# Reproject shapefiles to EPSG 4326
node_reproj = [gdf.to_crs(epsg=4326) for gdf in node_all]

# Merge all node shapefiles
node_merge = gpd.pd.concat(node_reproj, ignore_index=True)


# ******************************************************************************
# Calculate difference metrics between SWOT and OPERA observations by node
# ******************************************************************************
print('Summarizing difference metrics')
# Initialize dataframe
node_df = pd.DataFrame(np.full((len(node_ids), 7), -9999.),
                       index=node_ids,
                       columns=['n_obs', 'opera_mean', 'swot_mean', 'mrd',
                                'mard', 'md',  'mad'])
node_df = node_df.rename_axis('node_id')

# Loop through unique nodes
for i in range(len(node_ids)):

    print(i)

    # Filter paired SWOT/OPERA widths by node
    node_i = comp_df[comp_df.node_id == node_ids[i]]

    # Count number of observations
    node_df.loc[node_ids[i], 'n_obs'] = len(node_i)

    # If reach has less than 5 valid paired observations, leave metrics as nan
    if len(node_i) <= 5:
        continue

    # Calculate OPERA and SWOT means
    node_df.loc[node_ids[i], 'opera_mean'] = \
        np.round(np.mean(node_i.width_m), 4)
    node_df.loc[node_ids[i], 'swot_mean'] = \
        np.round(np.mean(node_i.swot_mean), 4)

    # Calculate difference metrics
    # Mean Absolute Relative Difference
    node_df.loc[node_ids[i], 'mard'] = \
        np.round(np.mean(np.abs((node_i.width_m - node_i.swot_mean)) /
                         ((node_i.width_m + node_i.swot_mean) / 2)), 4) * 100

    # Mean Relative Difference
    node_df.loc[node_ids[i], 'mrd'] = \
        np.round(np.mean((node_i.width_m - node_i.swot_mean) /
                         ((node_i.width_m + node_i.swot_mean) / 2)), 4) * 100

    # Mean Difference
    node_df.loc[node_ids[i], 'md'] = np.round(np.mean(node_i.swot_mean -
                                                      node_i.width_m), 4)

    # Mean Absolute Difference
    node_df.loc[node_ids[i], 'mad'] = np.round(np.mean(np.abs(node_i.swot_mean -
                                                       node_i.width_m)), 4)


# ******************************************************************************
# Export nodes to CSV and Shapefile
# ******************************************************************************
print('Writing files')
# Write to CSV
node_df.to_csv(node_out_csv, index=True)

# Merge metrics with shapefile
node_merge.index = node_merge["node_id"].astype("float").astype("int")
node_out_gdf = node_merge.merge(node_df[['opera_mean', 'swot_mean',
                                         'n_obs', 'mrd', 'mard', 'md', 'mad']],
                                left_index=True, right_index=True,
                                how='left')
node_out_gdf = node_out_gdf.reset_index(drop=True)

# Replace NaN with -9999
node_out_gdf = node_out_gdf.fillna(-9999)

# Write merged node shapefile
node_out_gdf.to_file(node_out_shp)
