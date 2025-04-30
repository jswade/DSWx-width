#!/usr/bin/env python3
# ******************************************************************************
# node_comp_plots.py
# ******************************************************************************

# Purpose:
# This script plots comparisons between SWOT and OPERA width observation
# Author:
# Jeffrey Wade,  Renato Frasson, 2024

# ******************************************************************************
# Import Python modules
# ******************************************************************************
import sys
import numpy as np
import pandas as pd
import matplotlib as mpl
import matplotlib.pyplot as plt
import glob
from matplotlib.colors import LogNorm
import matplotlib.patches as mpatches


# # ******************************************************************************
# # Set files paths
# # ******************************************************************************
# # Set input directory to width paired observations
# comp_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'opera/swot_comp/opera_swot_comp_2023-07-01to2024-10-19.csv'

# # Set input directory to SWOT observations
# swot_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'swot/swot_nodes_2023-07-01to2024-10-19.csv'

# qual_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'swot/swot_nodes_2023-07-01to2024-10-19_bit_qual.csv'

# # Set input directiony to OPERA widths
# opera_in = '/Users/jwade/jpl/computing/opera/RiverWidths_v16/missouri/output/'\
#     'opera/width/'


# ******************************************************************************
# Declaration of variables (given as command line arguments)
# ******************************************************************************
# 1 - comp_in
# 2 - swot_in
# 3 - qual_in
# 4 - opera_in


# ******************************************************************************
# Get command line arguments
# ******************************************************************************
IS_arg = len(sys.argv)
if IS_arg != 2:
    print('ERROR - 1 arguments must be used')
    raise SystemExit(22)

comp_in = sys.argv[1]
swot_in = sys.argv[2]
qual_in = sys.argv[3]
opera_in = sys.argv[4]


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
# Read paired observations
comp_all = pd.read_csv(comp_in)

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
# Remove negative widths (set negative widths to 0)
swot_df_fil = swot_df.copy()
swot_df_fil.loc[swot_df_fil.width < 0, 'width'] = 0

# Filter SWOT observations (except dark fraction)
swot_df_fil = swot_df_fil[swot_df_fil.lake_flagged == 0]
swot_df_fil = swot_df_fil[swot_df_fil.classification_qual_degraded == 0]
swot_df_fil = swot_df_fil[swot_df_fil.geolocation_qual_degraded == 0]
swot_df_fil = swot_df_fil[swot_df_fil.ice_clim_f == 0]
swot_df_fil = swot_df_fil[(np.abs(swot_df_fil.xtrk_dist) >= 10000) &
                          (np.abs(swot_df_fil.xtrk_dist) <= 60000)]


# ******************************************************************************
# Generate Plots
# ******************************************************************************
# ------------------------------------------------------------------------------
# Plot histogram of SWOT dark fraction
# ------------------------------------------------------------------------------
# Drop rows from swot_df_fil with nan values
swot_df_darkfrac = swot_df_fil[swot_df_fil.dark_frac >= 0]

plt.figure()
plt.hist(swot_df_darkfrac['dark_frac'], bins=20, color='lightgray', alpha=0.7,
         edgecolor='black', zorder=2)
plt.axvline(x=0.3, linewidth=2)
plt.xlabel('SWOT Dark Fraction')
plt.ylabel('Frequency')
plt.grid(axis='y', linestyle='--', alpha=0.7, zorder=1)
plt.grid(axis='x', linestyle='--', alpha=0.7, zorder=1)
# plt.yscale('log')
plt.show()

# ------------------------------------------------------------------------------
# Plot histogram of OPERA cloud fraction
# ------------------------------------------------------------------------------
# Aggregate OPERA cloud fraction values
no_data_frac = np.concatenate([opera.no_data_frac.values
                               for opera in opera_all]).tolist()

mpl.rcParams['svg.fonttype'] = 'none'
mpl.rcParams['font.family'] = 'Arial'
mpl.rcParams['font.size'] = 12
plt.figure()
plt.hist(no_data_frac, bins=20, color='lightgray', alpha=0.7,
         edgecolor='black', zorder=2)
plt.axvline(x=0.2, linewidth=2)
plt.xlabel('DSWx Cloud/No Data Fraction')
plt.ylabel('Frequency')
plt.grid(axis='y', linestyle='--', alpha=0.7, zorder=1)
plt.grid(axis='x', linestyle='--', alpha=0.7, zorder=1)
plt.yscale('log')
plt.show()

# ------------------------------------------------------------------------------
# Plot CDF of SWOT-OPERA absolute difference
# ------------------------------------------------------------------------------
# Sort abs relative differences
abs_rd = np.sort(comp_all.abs_rel_diff)

# Filter by average width
abs_rd_0_50 = np.sort(comp_all.abs_rel_diff[comp_all.avg_width <= 50])
abs_rd_50_100 = np.sort(comp_all.abs_rel_diff[(comp_all.avg_width > 50) &
                                              (comp_all.avg_width <= 100)])
abs_rd_100_500 = np.sort(comp_all.abs_rel_diff[(comp_all.avg_width > 100) &
                                               (comp_all.avg_width <= 500)])
abs_rd_500 = np.sort(comp_all.abs_rel_diff[comp_all.avg_width > 500])

# Compute cumulative probabilities
cdf_all = np.arange(1, len(abs_rd) + 1) / len(abs_rd)
cdf_0_50 = np.arange(1, len(abs_rd_0_50) + 1) / len(abs_rd_0_50)
cdf_50_100 = np.arange(1, len(abs_rd_50_100) + 1) / len(abs_rd_50_100)
cdf_100_500 = np.arange(1, len(abs_rd_100_500) + 1) / len(abs_rd_100_500)
cdf_500 = np.arange(1, len(abs_rd_500) + 1) / len(abs_rd_500)

# Find x-values at 68% cumulative probability
x_68_all = np.interp(0.68, cdf_all, abs_rd)
x_68_0_50 = np.interp(0.68, cdf_0_50, abs_rd_0_50)
x_68_50_100 = np.interp(0.68, cdf_50_100, abs_rd_50_100)
x_68_100_500 = np.interp(0.68, cdf_100_500, abs_rd_100_500)
x_68_500 = np.interp(0.68, cdf_500, abs_rd_500)

# Plot CDF
mpl.rcParams['svg.fonttype'] = 'none'
mpl.rcParams['font.family'] = 'Arial'
mpl.rcParams['font.size'] = 12
plt.figure(figsize=(5, 5))
plt.plot(abs_rd * 100, cdf_all, color='black', label='All', linestyle='--')
plt.plot(abs_rd_0_50 * 100, cdf_0_50, color='#e31a1c', label='Width: 0-50m')
plt.plot(abs_rd_50_100 * 100, cdf_50_100, color='#ff7f00',
         label='Width: 50-100m')
plt.plot(abs_rd_100_500 * 100, cdf_100_500, color='#1f78b4',
         label='Width: 100-500m')
plt.plot(abs_rd_500 * 100, cdf_500, color='#33a02c', label='Width: 500m+')
plt.scatter([x_68_all * 100, x_68_0_50 * 100, x_68_50_100 * 100,
             x_68_100_500 * 100, x_68_500 * 100],
            [0.68, 0.68, 0.68, 0.68, 0.68],
            color=['black', '#e31a1c', '#ff7f00', '#1f78b4', '#33a02c'],
            edgecolor='none', zorder=3, label="68% Markers", s=50)
plt.xlabel('Absolute Relative Difference, %')
plt.ylabel('Cumulative Probability')
plt.grid(True, linestyle='--', alpha=0.6)
plt.legend()
plt.ylim([0, 1])
plt.xlim([0, 202.5])
plt.show()

# ------------------------------------------------------------------------------
# Plot number of valid paired observations in each time window
# ------------------------------------------------------------------------------
# Find number of observations in each time window
wind_ct = comp_all['middate'].value_counts().sort_index()

# Plot valid paired observations
mpl.rcParams['svg.fonttype'] = 'none'
mpl.rcParams['font.family'] = 'Arial'
mpl.rcParams['font.size'] = 12
plt.figure(figsize=(8, 5))
plt.plot(wind_ct, marker='o', c='black')
plt.xlabel('Date Windows')
plt.ylabel('Number of Paired Observations')
plt.title('Observations in Each Date Window with Valid DSWx/SWOT Obs.')
plt.grid(True, linestyle='--', alpha=0.6)
plt.xticks(rotation=90)
plt.tight_layout()
plt.show()

# ------------------------------------------------------------------------------
# Three Panel Histograms of Difference
# ------------------------------------------------------------------------------
# Calculate difference by node
node_agg = comp_all.groupby('node_id').agg({
    'obs_diff': ['mean', 'std', 'count']}).reset_index()
node_agg.columns = ['node_id', 'mean_diff', 'std_diff', 'count']

mpl.rcParams['svg.fonttype'] = 'none'
mpl.rcParams['font.family'] = 'Arial'
mpl.rcParams['font.size'] = 12
fig, ax = plt.subplots(nrows=1, ncols=3, figsize=(10, 5), sharex=False)

bin_width = 25
bins_0 = np.arange(-500, 500 + bin_width, bin_width)
bins_1 = np.arange(-500, 500 + bin_width, bin_width)
bins_2 = np.arange(0, 500 + bin_width/2, bin_width/2)

means = [
    np.mean(comp_all['obs_diff']),
    np.mean(node_agg['mean_diff']),
    np.mean(node_agg['std_diff'])
]

ax[0].hist(comp_all['obs_diff'], bins=bins_0, color='lightgray', alpha=0.7,
           edgecolor='black', zorder=2, density=True)
ax[0].axvline(means[0], color='darkblue', linestyle='--', lw=1.5)
ax[0].set_xlabel('Width Difference, m\n(SWOT-DSWx)')
ax[0].set_ylabel('Frequency')
ax[0].grid(axis='y', linestyle='--', alpha=0.5, zorder=1)
ax[0].grid(axis='x', linestyle='--', alpha=0.5, zorder=1)
ax[0].set_xlim([-500, 500])
ax[0].set_ylim([0, .014])
ax[0].text(0.05, 0.95, f"Mean: \n{means[0]:.1f} m", transform=ax[0].transAxes,
           fontsize=12, verticalalignment='top', horizontalalignment='left')

ax[1].hist(node_agg['mean_diff'], bins=bins_1, color='lightgray', alpha=0.7,
           edgecolor='black', zorder=2, density=True)
ax[1].axvline(means[1], color='darkblue', linestyle='--', lw=1.5)
ax[1].set_xlabel('Mean Node Difference, m\n(SWOT-DSWx)')
ax[1].grid(axis='y', linestyle='--', alpha=0.5, zorder=1)
ax[1].grid(axis='x', linestyle='--', alpha=0.5, zorder=1)
ax[1].set_xlim([-500, 500])
ax[1].set_ylim([0, .014])
ax[1].text(0.05, 0.95, f"Mean: \n{means[1]:.1f} m", transform=ax[1].transAxes,
           fontsize=12, verticalalignment='top', horizontalalignment='left')

ax[2].hist(node_agg['std_diff'], bins=bins_2, color='lightgray', alpha=0.7,
           edgecolor='black', zorder=2, density=True)
ax[2].axvline(means[2], color='darkblue', linestyle='--', lw=1.5)
ax[2].set_xlabel('Std. Dev. Node Difference, m\n(SWOT-DSWx)')
ax[2].grid(axis='y', linestyle='--', alpha=0.5, zorder=1)
ax[2].grid(axis='x', linestyle='--', alpha=0.5, zorder=1)
ax[2].set_xlim([0, 500])
ax[2].set_ylim([0, .014])
ax[2].text(0.95, 0.95, f"Mean: \n{means[2]:.1f} m", transform=ax[2].transAxes,
           fontsize=12, verticalalignment='top', horizontalalignment='right')

plt.tight_layout()
plt.show()

# ------------------------------------------------------------------------------
# Plot SWOT - OPERA relative difference boxplots by average width bin
# ------------------------------------------------------------------------------
# Compute relative difference within bins
avg_width_bins = [0, 20, 40, 60, 80, 100, 125, 150, 175,
                  200, 225, 250, 275, 300, 325, 350, 375, 400, 425, 450, 475,
                  500, 550, 600, 650, 700, 800, 900, 1000]
avg_width_bins = np.append(avg_width_bins, np.inf)
comp_all['avg_width_bin'] = pd.cut(comp_all['avg_width'],
                                   bins=avg_width_bins,
                                   right=False)
avg_wid_groups = comp_all.groupby('avg_width_bin', observed=False)

comp_all['rel_diff'] = 100 * comp_all['obs_diff']/comp_all['avg_width']
rel_diff_data = [group['rel_diff'].dropna().values
                 for _, group in avg_wid_groups]


# Reformat bin labels
avg_wid_names = []
for interval in avg_wid_groups.groups.keys():
    start, end = interval.left, interval.right
    if np.isinf(end):
        avg_wid_names.append(f"{int(start)}+")
    else:
        avg_wid_names.append(f"{int(start)}-{int(end)}")

outlier_style = dict(marker='.', markerfacecolor='gray', markersize=1,
                     linestyle='none')

x_pos_diff = np.arange(len(avg_wid_names))
x_pos_diff = avg_width_bins[:-1]/10

mpl.rcParams['svg.fonttype'] = 'none'
mpl.rcParams['font.family'] = 'Arial'
mpl.rcParams['font.size'] = 12
plt.figure(figsize=(12, 6))
plt.axhline(0, c='black')
plt.boxplot(rel_diff_data, positions=x_pos_diff, widths=1,
            patch_artist=True,
            boxprops=dict(facecolor='lightgray'),
            medianprops=dict(color='black'),
            flierprops=outlier_style)
diff_patch = mpatches.Patch(facecolor='lightgray', edgecolor='black')
plt.xticks(ticks=x_pos_diff + 0.4, labels=avg_wid_names, rotation=45,
           ha='right', rotation_mode='anchor')
plt.xlabel('Mean SWOT-DSWx Width, m')
plt.ylabel('Relative Difference, % \n (SWOT - DSWX)')
plt.xlim([-2, 102])
plt.tight_layout()
plt.show()


# # ------------------------------------------------------------------------------
# # Analyze agreement between OPERA and SWOT using relative difference threshold
# # ------------------------------------------------------------------------------
# merged_diff = comp_all.copy()

# # Set agreement threshold
# agree_15 = 0.15
# agree_25 = 0.25
# agree_50 = 0.50

# merged_diff['wid_agree_15'] = merged_diff['rel_diff'] <= agree_15
# merged_diff['wid_agree_25'] = merged_diff['rel_diff'] <= agree_25
# merged_diff['wid_agree_50'] = merged_diff['rel_diff'] <= agree_50

# # Bin agreement of widths (by OPERA width)
# # width_bins = np.arange(0, 1500 + 50, 50)
# width_bins = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 125, 150, 175, 200,
#               225, 250, 275, 300, 325, 350, 375, 400, 425, 450, 475, 500,
#               550, 600, 650, 700, 800, 900, 1000, 1200, 1400,
#               1600]
# width_bins = np.append(width_bins, np.inf)
# merged_diff['width_bin'] = pd.cut(merged_diff['avg_width'], bins=width_bins,
#                                   right=False)
# agree_bin_15 = \
#     merged_diff.groupby('width_bin', observed=False)['wid_agree_15'].\
#     mean().reset_index()
# agree_bin_15['center'] = agree_bin_15['width_bin'].apply(lambda x: x.mid)
# agree_bin_25 = \
#     merged_diff.groupby('width_bin', observed=False)['wid_agree_25'].\
#     mean().reset_index()
# agree_bin_25['center'] = agree_bin_15['width_bin'].apply(lambda x: x.mid)
# agree_bin_50 = \
#     merged_diff.groupby('width_bin', observed=False)['wid_agree_50'].\
#     mean().reset_index()
# agree_bin_50['center'] = agree_bin_50['width_bin'].apply(lambda x: x.mid)

# # Plot metric of agreement
# plt.figure(figsize=(10, 6))
# plt.plot(agree_bin_15['center'], agree_bin_15['wid_agree_15'],
#          marker='o', c='black', label='15% Rel. Diff.')
# plt.plot(agree_bin_25['center'], agree_bin_25['wid_agree_25'],
#          marker='o', c='#1984c5', label='25% Rel. Diff.')
# plt.plot(agree_bin_50['center'], agree_bin_50['wid_agree_50'],
#          marker='o', c='#b04238', label='50% Rel. Diff.')
# plt.xlabel('Average SWOT/OPERA River Width (m)')
# plt.ylabel('Fraction of Observations Within Relative Difference Threshold')
# plt.title('Agreement Between OPERA and SWOT by River Width Bin')
# plt.legend()
# plt.show()

# # ------------------------------------------------------------------------------
# # Plot difference between all SWOT/OPERA observations
# # ------------------------------------------------------------------------------
# plt.figure()
# plt.hist(comp_all['obs_diff'], bins=4001, color='lightgray', alpha=0.7,
#          edgecolor='black', zorder=2)
# plt.xlabel('Width Difference (SWOT-OPERA), m')
# plt.ylabel('Frequency')
# plt.grid(axis='y', linestyle='--', alpha=0.7, zorder=1)
# plt.grid(axis='x', linestyle='--', alpha=0.7, zorder=1)
# plt.xlim([-500, 500])
# plt.title('Difference for each Observation (SWOT - OPERA)')
# plt.show()

# # ------------------------------------------------------------------------------
# # Plot mean of difference between SWOT/OPERA by node
# # ------------------------------------------------------------------------------
# # Plot histogram of mean node difference between SWOT and OPERA
# plt.figure()
# plt.hist(node_agg['mean_diff'], bins=400, color='lightgray', alpha=0.7,
#          edgecolor='black', zorder=2)
# plt.xlabel('Average Node Difference (SWOT-OPERA), m')
# plt.ylabel('Frequency')
# plt.grid(axis='y', linestyle='--', alpha=0.7, zorder=1)
# plt.grid(axis='x', linestyle='--', alpha=0.7, zorder=1)
# plt.xlim([-500, 500])
# plt.title('Mean Difference at Each Node (SWOT - OPERA)')
# plt.show()

# # ------------------------------------------------------------------------------
# # Plot std of difference between SWOT/OPERA by node_id
# # ------------------------------------------------------------------------------
# # Plot histogram of STD node difference between SWOT and OPERA
# plt.figure()
# plt.hist(node_agg['std_diff'], bins=400, color='lightgray', alpha=0.7,
#          edgecolor='black', zorder=2)
# plt.xlabel('Std Node Difference (SWOT-OPERA), m')
# plt.ylabel('Frequency')
# plt.grid(axis='y', linestyle='--', alpha=0.7, zorder=1)
# plt.grid(axis='x', linestyle='--', alpha=0.7, zorder=1)
# plt.title('Standard Deviation of Difference at Each Node (SWOT - OPERA)')
# plt.xlim([0, 500])
# plt.show()


# # ------------------------------------------------------------------------------
# # Plot SWOT vs OPERA observations (Log Heatmap)
# # ------------------------------------------------------------------------------
# hb_opera_df_i = comp_all[(comp_all.width_m != 0) &
#                          (comp_all.swot_max != 0)]
# plt.figure()
# x_bins = np.logspace(np.log10(3), np.log10(100000), 201)
# y_bins = np.logspace(np.log10(3), np.log10(100000), 201)
# plt.hist2d(hb_opera_df_i.width_m, hb_opera_df_i.swot_mean,
#            bins=[x_bins, y_bins], cmap='viridis', norm=LogNorm())
# plt.plot([.5, 100000], [.5, 100000], c='black', linestyle='--', alpha=0.3)
# cb = plt.colorbar()
# cb.set_label('log10(Frequency)')
# plt.xlabel('OPERA Width, m')
# plt.ylabel('SWOT Width, m')
# plt.xscale('log')
# plt.yscale('log')
# plt.show()

# # ------------------------------------------------------------------------------
# # Plot SWOT vs OPERA observations (Non-log Heatmap)
# # ------------------------------------------------------------------------------
# hb_opera_df = comp_all[np.isfinite(comp_all.width_m) &
#                        np.isfinite(comp_all.swot_mean)]
# plt.figure()
# x_bins = np.linspace(0, 1000, 201)
# y_bins = np.linspace(0, 1000, 201)
# plt.hist2d(hb_opera_df .width_m, hb_opera_df.swot_mean,
#            bins=[x_bins, y_bins], cmap='viridis', norm=LogNorm())
# plt.plot([0, 2000], [0, 2000], c='black', linestyle='--', alpha=0.3)
# cb = plt.colorbar()
# cb.set_label('log10(Frequency)')
# plt.xlabel('OPERA Width, m')
# plt.ylabel('SWOT Width, m')
# plt.show()

# # ------------------------------------------------------------------------------
# # Plot SWOT vs OPERA observations histograms by average width bin
# # ------------------------------------------------------------------------------
# avg_width_bins = np.arange(0, 1500 + 25, 25)
# avg_width_bins = np.append(avg_width_bins, np.inf)
# comp_all['avg_width_bin'] = pd.cut(comp_all['avg_width'],
#                                    bins=avg_width_bins,
#                                    right=False)
# avg_wid_groups = comp_all.groupby('avg_width_bin', observed=False)

# opera_data = [group['width_m'].dropna().values for _, group in avg_wid_groups]
# swot_data = [group['swot_mean'].dropna().values for _, group in avg_wid_groups]
# avg_wid_names = [str(category) for category in avg_wid_groups.groups.keys()]
# outlier_style = dict(marker='.', markerfacecolor='gray', markersize=1,
#                      linestyle='none')

# x_pos_opera = np.arange(len(avg_wid_names)) * 2
# x_pos_swot = x_pos_opera + 0.8

# plt.figure(figsize=(16, 6))
# plt.boxplot(opera_data, positions=x_pos_opera, widths=0.6,
#             patch_artist=True,
#             boxprops=dict(facecolor='tab:blue'),
#             medianprops=dict(color='black'),
#             flierprops=outlier_style)
# plt.boxplot(swot_data, positions=x_pos_swot, widths=0.6,
#             boxprops=dict(facecolor='tab:orange'),
#             medianprops=dict(color='black'),
#             patch_artist=True,
#             flierprops=outlier_style)
# opera_patch = mpatches.Patch(facecolor='tab:blue', edgecolor='black',
#                              label='OPERA Width')
# swot_patch = mpatches.Patch(facecolor='tab:orange', edgecolor='black',
#                             label='SWOT Width')
# plt.legend(handles=[opera_patch, swot_patch], loc='upper left')
# plt.xticks(ticks=x_pos_opera + 0.4, labels=avg_wid_names, rotation=45)
# plt.xlabel('Average SWOT/OPERA Width')
# plt.ylabel('Width (m)')
# plt.ylim([-50, 3000])
# plt.tight_layout()
# plt.show()

# # ------------------------------------------------------------------------------
# # Plot SWOT - OPERA difference histograms by average width bin
# # ------------------------------------------------------------------------------
# diff_data = [group['obs_diff'].dropna().values for _, group in avg_wid_groups]

# # Reformat bin labels
# avg_wid_names = []
# for interval in avg_wid_groups.groups.keys():
#     start, end = interval.left, interval.right
#     if np.isinf(end):
#         avg_wid_names.append(f"{int(start)}+")
#     else:
#         avg_wid_names.append(f"{int(start)}-{int(end)}")

# outlier_style = dict(marker='.', markerfacecolor='gray', markersize=1,
#                      linestyle='none')

# x_pos_diff = np.arange(len(avg_wid_names))
# x_pos_diff = avg_width_bins[:-1]/10

# plt.figure(figsize=(16, 6))
# plt.axhline(0, c='black')
# plt.boxplot(diff_data, positions=x_pos_diff, widths=1,
#             patch_artist=True,
#             boxprops=dict(facecolor='gray'),
#             medianprops=dict(color='black'),
#             flierprops=outlier_style)
# diff_patch = mpatches.Patch(facecolor='gray', edgecolor='black',
#                             label='Diff Width')
# # plt.legend(handles=[opera_patch, swot_patch], loc='upper left')
# plt.xticks(ticks=x_pos_diff + 0.4, labels=avg_wid_names, rotation=45)
# plt.xlabel('Average SWOT/OPERA Width')
# plt.ylabel('Diff Width (m)')
# plt.ylim([-3000, 3000])
# plt.tight_layout()
# plt.show()
