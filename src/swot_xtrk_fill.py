#!/usr/bin/env python3
# ******************************************************************************
# swot_xtrk_fill.py
# ******************************************************************************

# Purpose:
# This scripts fills in missing Xtrk data based on SWOT orbital parameters
# Author:
# Jeffrey Wade,  Renato Frasson, 2024

# ******************************************************************************
# Import Python modules
# ******************************************************************************
import sys
import pandas as pd
import geopandas as gpd


# # ******************************************************************************
# # Set files paths
# # ******************************************************************************
# # Set input directory to SWORD nodes
# swot_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'swot/swot_nodes_2023-07-01to2024-10-19.csv'

# # Set SWOT nadir track input shapefile
# # https://www.aviso.altimetry.fr/en/missions/current-missions/swot/orbit.html
# nadir_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/input/'\
#     'swot_orbit/swot_science_hr_Aug2021-v05_shapefile_nadir/'\
#     'swot_science_hr_2.0s_4.0s_Aug2021-v5_nadir.shp'

# node_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/' \
#           'sword/nodes/target_nodes_utm15N.shp'

# utm_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/input/'\
#     'utm_zones/missouri_utm15N.shp'

# utm_str = '15N'


# ******************************************************************************
# Declaration of variables (given as command line arguments)
# ******************************************************************************
# 1 - swot_in
# 2 - nadir_in
# 3 - node_in
# 4 - utm_in
# 5 - utm_str


# ******************************************************************************
# Get command line arguments
# ******************************************************************************
IS_arg = len(sys.argv)
if IS_arg != 6:
    print('ERROR - 5 arguments must be used')
    raise SystemExit(22)

swot_in = sys.argv[1]
nadir_in = sys.argv[2]
node_in = sys.argv[3]
utm_in = sys.argv[4]
utm_str = sys.argv[5]


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
    with open(nadir_in) as file:
        pass
except IOError:
    print('ERROR - Unable to open ' + nadir_in)
    raise SystemExit(22)

try:
    with open(node_in) as file:
        pass
except IOError:
    print('ERROR - Unable to open ' + node_in)
    raise SystemExit(22)

try:
    with open(utm_in) as file:
        pass
except IOError:
    print('ERROR - Unable to open ' + utm_in)
    raise SystemExit(22)


# ******************************************************************************
# Read files
# ******************************************************************************
print('Reading files')
# ------------------------------------------------------------------------------
# SWOT Nodes
# ------------------------------------------------------------------------------
# Read SWOT node observations
node_df = gpd.read_file(node_in)

# Remove nodes outside of UTM zone of interest
node_df = node_df[~node_df['ZONE'].astype(str).str.contains('b', na=False)]
node_df = node_df.reset_index(drop=True)

# Find unique nodes
node_uniq = list(set(node_df.node_id.astype('float').astype('int')))

# ------------------------------------------------------------------------------
# SWOT Observations
# ------------------------------------------------------------------------------
# Read SWOT node observations
swot_df = pd.read_csv(swot_in)

# Filter observations to nodes in node_df
swot_df_fil = swot_df[swot_df['node_id'].isin(node_uniq)]

# ------------------------------------------------------------------------------
# SWOT Nadir Track
# ------------------------------------------------------------------------------
# Read SWOT Nadir track shapefile
nadir_shp = gpd.read_file(nadir_in)

# ------------------------------------------------------------------------------
# UTM Zone Shapefile
# ------------------------------------------------------------------------------
# Load UTM zone of interest
utm_shp = gpd.read_file(utm_in)

# Set CRS of interest
crs_target = str(326)+utm_str[0:2]

# Reproject UTM zone of interest to match nadir_shp
utm_shp.to_crs(epsg=nadir_shp.crs.to_epsg(), inplace=True)


# ******************************************************************************
# Select SWOT nadir tracks in UTM zone
# ******************************************************************************
# Intersect nadir tracks with utm zones
nadir_utm = nadir_shp[nadir_shp.intersects(utm_shp.union_all())]

# Reproject to UTM crs
nadir_utm = nadir_utm.to_crs(epsg=crs_target)

# Reset index
nadir_utm = nadir_utm.reset_index(drop=True)


# ******************************************************************************
# Compute perpendicular Xtrk distance from nodes to each pass
# ******************************************************************************
# Compute distances between nodes and passes
# Note: These distances will always be positive, instead of +/- depending on
# which side of the nadir track the node is located.
# This has no effect on how we filter the SWOT observations
dist_list = []
for i, point in node_df.iterrows():
    for j, line in nadir_utm.iterrows():
        dist_list.append({
            "node_id": point["node_id"],
            "pass_id": line["ID_PASS"],
            "distance": line.geometry.distance(point.geometry)
        })

# Convert distance list to dictionary of points and pass_ids
dist_dict = {}
for entry in dist_list:
    node = int(float(entry["node_id"]))
    pass_id = entry["pass_id"]
    dist = entry["distance"]
    if node not in dist_dict:
        dist_dict[node] = {}
    dist_dict[node][pass_id] = dist

# Loop through rows in swot_df and fill in missing xtrk_dist values
for i, row in swot_df_fil.iterrows():
    if row['xtrk_dist'] == -999999999999:
        # Lookup the distance from dist_dict and fill in missing xtrk value
        dist_val = dist_dict.get(row['node_id'], {}).get(row['pass_id'], None)

        if dist_val is not None:
            swot_df.at[i, 'xtrk_dist'] = dist_val


# ******************************************************************************
# Write changes to file
# ******************************************************************************
swot_df.to_csv(swot_in, index=False)
