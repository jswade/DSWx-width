#!/usr/bin/env python3
# ******************************************************************************
# SWOT_Bitwise_Qual.py
# ******************************************************************************

# Purpose:
# This script decodes SWOT bitwise quality flags
# Adapted from PODAAC cookbook:
# https://podaac.github.io/tutorials/notebooks/datasets/\
# SWOT_quality_flag_demo.html

# Quality flags from:
# SWOT Product Description Document: Level 2 KaRIn High Rate River Single Pass
# Vector (L2_HR_RiverSP) Data Product

# Author:
# Jeffrey Wade, 2024

# ******************************************************************************
# Import Python modules
# ******************************************************************************
import sys
import numpy as np
import pandas as pd


# ******************************************************************************
# Declaration of variables (given as command line arguments)
# ******************************************************************************
# 1 - swot_in
# 2 - qual_out


# ******************************************************************************
# Get command line arguments
# ******************************************************************************
IS_arg = len(sys.argv)
if IS_arg != 3:
    print('ERROR - 2 arguments must be used')
    raise SystemExit(22)

swot_in = sys.argv[1]
qual_out = sys.argv[2]


# ******************************************************************************
# Check if inputs exist
# ******************************************************************************
try:
    with open(swot_in) as file:
        pass
except IOError:
    print('ERROR - Unable to open ' + swot_in)
    raise SystemExit(22)


# ******************************************************************************
# Define function to decode SWOT bitwise node flags
# ******************************************************************************
# Define function to decode bitwise quality flags
def bit_decode(n):

    bits = []
    pos = 0

    while n > 0:
        # Check if least significant bit is activated
        if n & 1:
            # Append position of activated bit
            bits.append(pos)
        # Proceed to next bit and position
        n >>= 1
        pos += 1

    return bits


# ******************************************************************************
# Decode SWOT bitwise node flags
# ******************************************************************************
# Load SWOT node data
swot_df = pd.read_csv(swot_in)

# Retrieve node bitwise flags
bit_flags = swot_df.node_q_b.to_numpy()

# Define bitwise flag meanings
flag_meaning = {
    0: 'sig0_qual_suspect',
    1: 'classification_qual_suspect',
    2: 'geolocation_qual_suspect',
    3: 'water_fraction_suspect',
    4: 'blocking_width_suspect',
    7: 'bright_land',
    9: 'few_sig0_observations',
    10: 'few_area_observations',
    11: 'few_wse_observations',
    13: 'far_range_suspect',
    14: 'near_range_suspect',
    18: 'classification_qual_degraded',
    19: 'geolocation_qual_degraded',
    22: 'lake_flagged',
    23: 'wse_outlier',
    24: 'wse_bad',
    25: 'no_sig0_observations',
    26: 'no_area_observations',
    27: 'no_wse_observations',
    28: 'no_pixels'
}

# Convert flag meanings to list for indexing
flag_cols = list(flag_meaning.values())

# Initialize output array
bit_array = np.zeros((len(bit_flags), len(flag_cols)), dtype=np.uint8)

# Decode bitwise flags using NumPy
bit_masks = (bit_flags[:, None] &
             (1 << np.array(list(flag_meaning.keys())))) > 0
bit_array[:, :] = bit_masks.astype(np.uint8)

# Assemble into dataframe
bit_df = pd.DataFrame(bit_array, columns=flag_cols)
bit_df.insert(0, 'time_str', swot_df.time_str.to_numpy())
bit_df.insert(0, 'node_id', swot_df.node_id.to_numpy())

# Drop any columns with all zeros
bit_df = bit_df.loc[:, (bit_df != 0).any(axis=0)]


# ******************************************************************************
# Write decoded flags to file
# ******************************************************************************
# Write to file
bit_df.to_csv(qual_out, index=False)
