#!/usr/bin/env python3
# ******************************************************************************
# Node_Stat_Tests.py
# ******************************************************************************

# Purpose:
# This script performs paired statistical tests between SWOT node width
# observations andOPERA calculated widths.
# Author:
# Jeffrey Wade,  Renato Frasson, 2024

# ******************************************************************************
# Import Python modules
# ******************************************************************************
import sys
import os
import glob
import numpy as np
from scipy.stats import binomtest, wilcoxon
import pandas as pd
import geopandas as gpd
import matplotlib.pyplot as plt


## ******************************************************************************
## Set files paths
## ******************************************************************************
## Set input directory to SWOT observations
#comp_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#    'opera/swot_comp/opera_swot_comp_2023-07-01to2024-10-19.csv'
#
#nodes_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/' \
#    'sword/nodes/'
#
#nodes_out = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#    'opera/stat_test/node_stat_test.shp'


# ******************************************************************************
# Declaration of variables (given as command line arguments)
# ******************************************************************************
# 1 - comp_in
# 2 - nodes_in
# 3 - nodes_out


# ******************************************************************************
# Get command line arguments
# ******************************************************************************
IS_arg = len(sys.argv)
if IS_arg != 4:
    print('ERROR - 3 arguments must be used')
    raise SystemExit(22)

comp_in = sys.argv[1]
nodes_in = sys.argv[2]
nodes_out = sys.argv[3]


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
    if os.path.isdir(nodes_in):
        pass
except IOError:
    print('ERROR - '+nodes_in+' invalid folder path')
    raise SystemExit(22)


# ******************************************************************************
# Load files
# ******************************************************************************
# ------------------------------------------------------------------------------
# SWORD Nodes
# ------------------------------------------------------------------------------
# Read SWORD node shapefile
nodes_files = sorted(list(glob.iglob(nodes_in + '*.shp')))
nodes_all = [gpd.read_file(x) for x in nodes_files]

# Reproject node files to 4326
nodes_reproj = [gdf.to_crs(epsg=4326) for gdf in nodes_all]

# Combine into a single GeoDataFrame
nodes_comb = gpd.GeoDataFrame(pd.concat(nodes_reproj, ignore_index=True))

# ------------------------------------------------------------------------------
# OPERA/SWOT observations
# ------------------------------------------------------------------------------
# Load paired OPERA/SWOT observations
comp_all = pd.read_csv(comp_in)


# ******************************************************************************
# Perform Paired Signed-Rank Test on all paired SWOT/OPERA observations
# ******************************************************************************
# H0: median(diff) = 0
# HA: median(diff) != 0

# # Check symmetry in differences, which is required by the test
# plt.figure(figsize=(6, 4))
# plt.boxplot([comp_all.obs_diff], showfliers=False,
#             tick_labels=["Diff"])
# plt.axhline(0, color='gray', alpha=0.2)
# plt.ylabel("Width, m")
# plt.title("Boxplot of width_m and swot_mean")
# plt.show()

# Perform Wilcoxon signed-rank test
srt_stat, srt_p_value = wilcoxon(comp_all["width_m"], comp_all["swot_mean"])
# print(f"P-value (Paired Signed-Rank Test): {srt_p_value}")
# print("SWOT Widths are Different than OPERA widths")


# ******************************************************************************
# Perform Paired Sign Test on all paired SWOT/OPERA observations
# ******************************************************************************
# H0: X > Y = 50% probability
# HA: X > Y != 50% probability (two sided)

# Count number of positive and negative differences
n_pos = np.sum(comp_all.obs_diff > 0)
n_neg = np.sum(comp_all.obs_diff < 0)

# Perform paired sign test (binomial test)
st_p_value = binomtest(min(n_pos, n_neg), n=n_pos + n_neg,
                       p=0.5, alternative='two-sided').pvalue
# print(f"P-value (Paired Sign Test): {st_p_value}")
# print("SWOT Widths are Statistically Larger than OPERA widths")


# ******************************************************************************
# Perform Paired Sign Test/Signed-Rank Test at each node
# ******************************************************************************
# Retrieve number of paired observations at each node
node_ct = comp_all["node_id"].value_counts()

# Filter to nodes with at least 5 observations
node_val = node_ct.index.values[node_ct > 5]

# Create lists to store test values and mean/median width differences
st_p_vals = []
srt_test = []
srt_p_vals = []
med_diff = []
mean_diff = []
avg_width = []

# Loop through nodes in node_val
for i in range(len(node_val)):

    print(i)

    # Retrieve paired observations at node_i
    node_i = comp_all[comp_all.node_id == node_val[i]]

    # Count number of positive and negative differences at each node
    n_pos = np.sum(node_i.obs_diff > 0)
    n_neg = np.sum(node_i.obs_diff < 0)

    # Check that n_pos and n_neg are > 0
    if n_pos == 0 & n_neg == 0:
        continue

    # Perform paired sign test (binomial test)
    # H0: X > Y = 50% probability
    # HA: X > Y != 50% probability (two sided)
    st_p_vals.append(binomtest(min(n_pos, n_neg), n=n_pos + n_neg,
                               p=0.5, alternative='two-sided').pvalue)

    # Perform paired sign test (binomial test)
    # H0: X > Y = 50% probability
    # HA: X > Y != 50% probability (two sided)
    srt_i = wilcoxon(node_i["width_m"], node_i["swot_mean"])
    srt_test.append(srt_i[0])
    srt_p_vals.append(srt_i[1])

    # Calculate mean/median width differences
    med_diff.append(np.median(node_i.obs_diff))
    mean_diff.append(np.mean(node_i.obs_diff))

    # Calculate average width for OPERA + SWOT
    avg_width.append(np.mean([node_i.width_m, node_i.swot_mean]))

# Count number of nodes that have statistically significant differences
st_sig = [x < 0.05 for x in st_p_vals]
srt_sig = [x < 0.05 for x in srt_p_vals]
# print(f"% of Nodes with Significant Difference (Sign Test): \
#       {np.sum(st_sig)/len(st_p_vals)}")
# print(f"% of Nodes with Significant Difference (Signed-Rank Test):\
#       {np.sum(srt_sig)/len(srt_p_vals)}")

# print(f"Mean Difference for Statistically Different Nodes (Sign Test): \
#       {np.mean(np.array(mean_diff)[st_sig])} (m)")
# print(f"Mean Difference for Not Statistically Different Nodes (Sign Test): \
#       {np.mean(np.array(mean_diff)[~np.array(st_sig)])} (m)")

# print(f"Mean Difference for Statistically Different Nodes \
#       (Paired Signed-Rank Test): \
#       {np.mean(np.array(mean_diff)[srt_sig])} (m)")
# print(f"Mean Difference for Not Statistically Different Nodes \
#       (Paired Signed-Rank Test): \
#       {np.mean(np.array(mean_diff)[~np.array(srt_sig)])} (m)")


# ******************************************************************************
# Plot number of nodes with significant difference by average width bin
# ******************************************************************************
# Divide nodes into average width bins
bin_df = pd.DataFrame({"avg_width": avg_width, "st_p_val": st_p_vals,
                       "srt_p_val": srt_p_vals, "med_diff": med_diff})

bin_width = 30
width_bins = np.arange(0, 1500 + bin_width, bin_width)
# width_bins = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 175, 200,
#               225, 250, 275, 300, 325, 350, 375, 400, 425, 450, 475, 500,
#               550, 600, 650, 700, 800, 900, 1000, 1200, 1400,
#               1600]
bin_center = [(width_bins[i] + width_bins[i + 1]) / 2
              for i in range(len(width_bins) - 1)]
width_bins = np.append(width_bins, np.inf)
bin_center = np.append(bin_center, 1700)
bin_df["width_bin"] = pd.cut(bin_df["avg_width"], bins=width_bins, right=False)
# bin_center = width_bins[:-1] + (bin_width / 2)

# # Divide nodes into average width bins based on quantiles
# n_bins = 25
# quantile_bins = pd.qcut(bin_df['avg_width'], q=n_bins)
# bin_edges = quantile_bins.cat.categories
# bin_center = [(interval.left + interval.right) / 2 for interval in bin_edges]
# bin_df['bin_quant'] = quantile_bins.apply(lambda x: (x.left + x.right) / 2)

# Count numbef of values in each bin
ct_bin = bin_df.groupby("width_bin", observed=False)["med_diff"].count()

# Compute percentage of st_p_vals > 0.05 in each bin (widths agree)
st_percent = \
    bin_df.groupby("width_bin", observed=False)["st_p_val"].\
    apply(lambda x: (x > 0.05).mean() * 100)

# Compute percentage of srt_p_vals > 0.05 in each bin (widths agree)
srt_percent = \
    bin_df.groupby("width_bin", observed=False)["srt_p_val"].\
    apply(lambda x: (x > 0.05).mean() * 100)

# Compute mean median node difference in each width bin
med_diff_bin = bin_df.groupby("width_bin", observed=False)["med_diff"].mean()

# # Plot percent of values that are statistically different
# plt.figure(figsize=(10, 6))
# plt.plot(bin_center, st_percent,
#          marker='o', c='black', label='Paired Sign Test')
# plt.plot(bin_center, srt_percent,
#          marker='o', c='#1984c5', label='Paired Signed-Rank Test')
# plt.xlabel('Average SWOT/OPERA River Width (m)')
# plt.ylabel('Percent of Nodes With No Significant Difference in Widths')
# plt.title('Percent of Nodes Where OPERA/SWOT Widths Agree')
# plt.ylim([0, 100])
# plt.legend()
# plt.show()

# fig, ax1 = plt.subplots(figsize=(10, 6))
# ax1.plot(bin_center, st_percent, marker='o', c='black',
#          label='Paired Sign Test')
# ax1.plot(bin_center, srt_percent, marker='o', c='#1984c5',
#          label='Paired Signed-Rank Test')
# ax1.set_xlabel('Average SWOT/OPERA River Width (m)')
# ax1.set_ylabel('Percent of Nodes With No Significant Difference in Widths')
# ax1.set_ylim([0, 100])
# ax2 = ax1.twinx()
# ax2.plot(bin_center, ct_bin, marker='o', c='green', label='Number of Nodes',
#          alpha=0.2)
# ax2.set_ylim([0, 20000])
# ax2.set_ylabel('Number of Nodes')
# plt.title('Percent of Nodes Where OPERA/SWOT Widths Agree')
# ax1.legend(loc='upper left')
# ax2.legend(loc='upper right')
# plt.tight_layout()
# plt.show()


# # Plot median node difference by width bin
# plt.figure(figsize=(10, 6))
# plt.axhline(0, color='k', linestyle='--', linewidth=1)
# plt.plot(bin_center, med_diff_bin/bin_center,
#          marker='o', c='black', label='Median Node Difference')
# plt.xlabel('Average SWOT/OPERA River Width (m)')
# plt.ylabel('SWOT - OPERA Width Difference, m')
# plt.ylim([-1, 1])
# plt.legend()
# plt.show()

# ******************************************************************************
# Posthoc Tests: Mean/Median Difference
# ******************************************************************************
# Calculate mean/median difference between SWOT and OPERA
# print(f"Mean Difference: {np.mean(comp_all.obs_diff)} m")
# print(f"Median Difference: {np.median(comp_all.obs_diff)} m")


# ******************************************************************************
# Output Statistical Tests to Nodes
# ******************************************************************************
# Create dataframe from statistical tests and and node_vals
st_df = pd.DataFrame({'node_id': node_val, 'st_p_val': st_p_vals,
                      'srt_p_val': srt_p_vals})

# Join statistical tests to node shapefile
nodes_comb.node_id = nodes_comb.node_id.astype('float').astype(int)
nodes_comb = nodes_comb.merge(st_df, on='node_id', how='left')

# Write to file
nodes_comb.to_file(nodes_out)
