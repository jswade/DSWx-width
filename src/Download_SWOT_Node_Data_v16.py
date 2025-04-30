#!/usr/bin/env python3
# ******************************************************************************
# Download_SWOT_Node_Data_v16.py
# ******************************************************************************

# Purpose:
# This script downloads SWOT observations aggregated to selected SWORD nodes
# Author:
# Jeffrey Wade,  Renato Frasson, 2024

# ******************************************************************************
# Import Python modules
# ******************************************************************************
import xarray as xr
import sys
import os
from datetime import datetime
import requests
import glob
from io import StringIO
import numpy as np
import pandas as pd
import geopandas as gpd
import rasterio
import earthaccess
from shapely.geometry import Polygon, Point


## ******************************************************************************
## Set files paths
## ******************************************************************************
## Set input directory to SWORD nodes
#node_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#    'sword/nodes/'
#
## Set beginning and end dates for data acquisition
#date1 = '2023-07-01'
#date2 = '2024-10-19'
#
## Set output file path
#swot_out = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#    'swot/'
#

# ******************************************************************************
# Declaration of variables (given as command line arguments)
# ******************************************************************************
# 1 - pixel_num_in
# 2 - tif_opt
# 3 - width_out


# ******************************************************************************
# Get command line arguments
# ******************************************************************************
IS_arg = len(sys.argv)
if IS_arg != 5:
    print('ERROR - 4 arguments must be used')
    raise SystemExit(22)

node_in = sys.argv[1]
date1 = sys.argv[2]
date2 = sys.argv[3]
swot_out = sys.argv[4]


# ******************************************************************************
# Check if inputs exist
# ******************************************************************************
try:
    if os.path.isdir(node_in):
        pass
except IOError:
    print('ERROR - '+node_in+' invalid folder path')
    raise SystemExit(22)


# ******************************************************************************
# Read files
# ******************************************************************************
print('Reading files')
# Read target SWORD nodes
node_files = sorted(list(glob.iglob(node_in + '*.shp')))
node_all = [gpd.read_file(x) for x in node_files]

# Retrieve SWORD node ids from all UTM zones
node_id = np.concatenate([x.node_id.values.astype('float').astype('int')
                          for x in node_all])

# Set aquisition dates
startdate = datetime.strptime(date1, '%Y-%m-%d')
enddate = datetime.strptime(date2, '%Y-%m-%d')


# ******************************************************************************
# Retrieve SWOT node data for desired time period using Hydrocron
# ******************************************************************************
# Set desired node attributes for retrieval
attrs = ['node_id', 'reach_id', 'time_str', 'width', 'width_u', 'area_total',
         'area_tot_u', 'area_detct', 'area_det_u', 'node_dist', 'node_q',
         'node_q_b', 'dark_frac', 'ice_clim_f', 'ice_dyn_f', 'n_good_pix',
         'xovr_cal_q', 'p_width', 'p_wid_var', 'p_length', 'p_dam_id',
         'p_n_ch_max', 'p_n_ch_mod', 'xtrk_dist', 'crid']

# Prepare dates as timestamps
startdt = startdate.strftime('%Y-%m-%dT%H:%M:%SZ')
enddt = enddate.strftime('%Y-%m-%dT%H:%M:%SZ')

# Initiliaze df_list
df_list = []

# Loop through SWORD nodes
for i in range(len(node_id)):

    print(i)

    # Prepare Hydrocron query
    hydrocron_str = 'https://soto.podaac.earthdatacloud.nasa.gov/hydrocron/v1/'\
        'timeseries?feature=Node&feature_id=' + str(node_id[i]) +              \
        '&start_time=' + startdt + '&end_time=' + enddt + '&output=csv&'       \
        'fields=' + ','.join(attrs)

    # Make call to hydrocron
    hydrocron_resp = requests.get(hydrocron_str).json()

    # Catch error results
    if 'error' in hydrocron_resp:
        continue

    hydrocron_data = pd.read_csv(StringIO(hydrocron_resp['results']['csv']))

    # Drop columns that contain 'units'
    hydrocron_df = hydrocron_data.drop(columns=hydrocron_data.
                                       filter(regex='units').columns)

    # Drop rows with no data
    hydrocron_df = hydrocron_df[hydrocron_df['time_str'] != 'no_data']

    # Add combined column of node_id and date
    hydrocron_df['node_date'] = hydrocron_df['node_id'].astype(str) + '_' +    \
        hydrocron_df['time_str'].str[:10]

    # Append df to list
    df_list.append(hydrocron_df)

# Concatenate all dataframes
sword_df = pd.concat(df_list, axis=0)

# Drop rows with CRID PIC2
sword_df = sword_df[sword_df["crid"] != "PIC2"]

# Format output path
fp_out = swot_out + 'swot_nodes_' + date1 + 'to' + date2 + '.csv'

# Write retrieved data to file
sword_df.to_csv(fp_out)
