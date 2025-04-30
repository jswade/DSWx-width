#!/usr/bin/env python3
# ******************************************************************************
# node_comp_bitwise.py
# ******************************************************************************

# Purpose:
# This script compares SWOT node width observations to OPERA calculated widths
# using bitwise quality filters.
# Author:
# Jeffrey Wade,  Renato Frasson, 2024

# ******************************************************************************
# Import Python modules
# ******************************************************************************
import sys
from datetime import datetime
import glob
import numpy as np
import pandas as pd


# # ******************************************************************************
# # Set files paths
# # ******************************************************************************
# # Set input directory to SWOT observations
# swot_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'swot/swot_nodes_2023-07-01to2024-10-19.csv'

# qual_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'swot/swot_nodes_2023-07-01to2024-10-19_bit_qual.csv'

# # Set input directiony to OPERA widths
# opera_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'opera/width/'

# comp_out = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'opera/swot_comp/opera_swot_comp_2023-07-01to2024-10-19.csv'

# # Set input directory to SWOT observations
# swot_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'swot/swot_nodes_2023-07-01to2024-10-19.csv'

# qual_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'swot/swot_nodes_2023-07-01to2024-10-19_bit_qual.csv'

# # Set input directiony to OPERA widths
# opera_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'opera/width/'

# comp_out = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'opera/swot_comp/opera_swot_comp_2023-07-01to2024-10-19.csv'


# ******************************************************************************
# Declaration of variables (given as command line arguments)
# ******************************************************************************
# 1 - swot_in
# 2 - qual_in
# 3 - opera_in
# 4 - comp_out


# ******************************************************************************
# Get command line arguments
# ******************************************************************************
IS_arg = len(sys.argv)
if IS_arg != 5:
    print('ERROR - 4 arguments must be used')
    raise SystemExit(22)

swot_in = sys.argv[1]
qual_in = sys.argv[2]
opera_in = sys.argv[3]
comp_out = sys.argv[4]


# ******************************************************************************
# Check if inputs exist
# ******************************************************************************
try:
    with open(swot_in) as file:
        pass
except IOError:
    print('ERROR - Unable to open ' + swot_in)
    raise SystemExit(22)

try:
    with open(qual_in) as file:
        pass
except IOError:
    print('ERROR - Unable to open ' + qual_in)
    raise SystemExit(22)

try:
    with open(opera_in) as file:
        pass
except IOError:
    print('ERROR - Unable to open ' + opera_in)
    raise SystemExit(22)


# ******************************************************************************
# Load files
# ******************************************************************************
print('Reading files')
# ------------------------------------------------------------------------------
# OPERA
# ------------------------------------------------------------------------------
# Get file paths to OPERA width files
opera_files = sorted(list(glob.iglob(opera_in + '*.csv')))

# Read OPERA widths
opera_all = [pd.read_csv(i) for i in opera_files]

# Retrieve unique node ids
node_ids = np.unique(opera_all[0].node_id)

# Retrieve node types
node_types = opera_all[0].node_id % 10
type1 = node_types[node_types == 1].index.values

# Retrieve start, middle, and end date of each 2 week OPERA window
start_dt = [datetime.strptime(i.startdate[0], '%Y-%m-%d') for i in opera_all]
mid_dt = [datetime.strptime(i.middate[0], '%Y-%m-%d')for i in opera_all]
end_dt = [datetime.strptime(i.enddate[0], '%Y-%m-%d') for i in opera_all]

# ------------------------------------------------------------------------------
# SWOT
# ------------------------------------------------------------------------------
# Load SWOT observation file
swot_df = pd.read_csv(swot_in)

swot_df = swot_df.drop_duplicates()

# Convert times to datetime
swot_df['time_dt'] = pd.to_datetime(swot_df['time_str'],
                                    format='%Y-%m-%dT%H:%M:%SZ',
                                    errors='coerce')

# Load SWOT quality flags
qual_df = pd.read_csv(qual_in)

# Join SWOT quality flags to swot_df
swot_df = swot_df.join(qual_df.iloc[:, 2:], how="left")


# ------------------------------------------------------------------------------
# Filter SWOT Observations
# ------------------------------------------------------------------------------
# # Remove dark frack > 0.3
# dark_frac = (swot_df.dark_frac > 0.3).astype(int)

# # Remove ice_clim > 0
# ice_clim = (swot_df.ice_clim_f > 0).astype(int)

# # Remove xtrk_dist > 5000 m or xtrk_dist < -5000 m
# xtrk_dist = ((np.abs(swot_df.xtrk_dist) < 10000) |
#              (np.abs(swot_df.xtrk_dist) > 60000)).astype(int)

# # Create dataframe of filters
# fil_df = pd.DataFrame({
#     'dark_frac_fil': dark_frac,
#     'ice_clim_fil': ice_clim,
#     'xtrk_dist_fil': xtrk_dist
# })

# # Join with swot_df
# swot_df = swot_df.join(fil_df, how="left")

# Remove negative widths (set negative widths to 0)
swot_df_fil = swot_df.copy()
swot_df_fil.loc[swot_df_fil.width < 0, 'width'] = 0

# Filter SWOT observations
swot_df_fil = swot_df_fil[swot_df_fil.lake_flagged == 0]
swot_df_fil = swot_df_fil[swot_df_fil.classification_qual_degraded == 0]
swot_df_fil = swot_df_fil[swot_df_fil.geolocation_qual_degraded == 0]
swot_df_fil = swot_df_fil[swot_df_fil.dark_frac <= 0.3]
swot_df_fil = swot_df_fil[swot_df_fil.ice_clim_f == 0]
swot_df_fil = swot_df_fil[(np.abs(swot_df_fil.xtrk_dist) >= 10000) &
                          (np.abs(swot_df_fil.xtrk_dist) <= 60000)]


# ******************************************************************************
# Pair SWOT and OPERA observations for each OPERA window
# ******************************************************************************
print('Pairing SWOT and OPERA observations')
# Initialize dataframe
merged_all = opera_all[0].iloc[0:0]

for i in range(len(start_dt)):

    print(i)

    # Load OPERA width file
    opera_i = opera_all[i]

    # Drop all non-type 1 nodes
    opera_i = opera_i.iloc[type1, :]

    # Drop OPERA nodes with > 20% no_data_fraction
    opera_i = opera_i[opera_i.no_data_frac < .2]

    # Retrieve node_ids with valid OPERA widths
    node_ids = np.unique(opera_i.node_id)

    # Retrieve valid OPERA nodes from SWOT observations
    swot_i = swot_df_fil[swot_df_fil.node_id.isin(node_ids)]

    # Filter swot_i to OPERA observation window
    swot_i = swot_i[(swot_i.time_dt >= start_dt[i]) &
                    (swot_i.time_dt <= end_dt[i])]

    # Aggregate SWOT observations at each node by mean and max
    swot_agg = swot_i.groupby('node_id').agg({
        'width': ['max', 'mean', 'count'],
        'p_width': ['first']}).reset_index()
    swot_agg.columns = ['node_id', 'max', 'mean', 'count',
                        'p_width']

    # Align opera_i and swot_agg dataframes
    merged_df = opera_i.merge(swot_agg[['node_id', 'max', 'mean', 'count',
                                        'p_width']],
                              on='node_id', how='left')
    merged_df[['max', 'mean', 'count']] = merged_df[['max', 'mean',
                                                     'count']].fillna(0)

    # Rename merged_df columns
    merged_df.rename(columns={'max': 'swot_max',
                              'mean': 'swot_mean',
                              'count': 'swot_count'}, inplace=True)

    # Add values to opera_i_all
    merged_all = pd.concat([merged_all, merged_df])

# Drop columns from merged_all where there are no swot observations
merged_all = merged_all.dropna(subset=['p_width'])

# Calculate difference between swot_max and Opera width
merged_all['obs_diff'] = merged_all.swot_mean - merged_all.width_m
merged_all['abs_diff'] = np.abs(merged_all.swot_mean - merged_all.width_m)
merged_all['avg_width'] = merged_all[['width_m', 'swot_mean']].mean(axis=1)
merged_all['rel_diff'] = merged_all.obs_diff / merged_all.avg_width
merged_all['abs_rel_diff'] = merged_all.abs_diff / merged_all.avg_width


# ******************************************************************************
# Write paired observations to file
# ******************************************************************************
print('Writing paired observations to file')
merged_all.to_csv(comp_out, index=False)
