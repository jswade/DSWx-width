#!/usr/bin/env python3
# ******************************************************************************
# tst_cmp.py
# ******************************************************************************

# Purpose:
# Given an original file and a file generating during testing,
# ensure that files are identical.

# Author:
# Jeffrey Wade, 2025


# ******************************************************************************
# Import Python modules
# ******************************************************************************
import sys
import filecmp
import pathlib


# ******************************************************************************
# Declaration of variables (given as command line arguments)
# ******************************************************************************
# 1 - file_org
# 2 - file_tst


# ******************************************************************************
# Define comparison functions
# ******************************************************************************
# Identify type of file for comparison
def compare_files(file_org, file_tst):
    suffix = pathlib.Path(file_org).suffix.lower()

    if suffix == '.shp':
        return compare_shapefiles(file_org, file_tst)
    elif suffix == '.csv':
        return compare_csvs(file_org, file_tst)
    elif suffix == '.tif':
        return compare_tifs(file_org, file_tst)
    else:
        return filecmp.cmp(file_org, file_tst, shallow=False)


# Compare original and testing shapefiles
def compare_shapefiles(file_org, file_tst):
    import geopandas as gpd
    try:
        gdf1 = gpd.read_file(file_org)
        gdf2 = gpd.read_file(file_tst)
        return gdf1.equals(gdf2)
    except Exception as e:
        print("ERROR comparing shapefiles:", e)
        return False


# Compare original and testing csv files
def compare_csvs(file_org, file_tst):
    import pandas as pd
    try:
        df1 = pd.read_csv(file_org).sort_index(axis=1)
        df2 = pd.read_csv(file_tst).sort_index(axis=1)
        return df1.equals(df2)
    except Exception as e:
        print("ERROR comparing CSVs:", e)
        return False


# Compare original and testing tif files
def compare_tifs(file_org, file_tst):
    import rasterio
    import numpy as np
    try:
        with rasterio.open(file_org) as src1, rasterio.open(file_tst) as src2:
            if src1.count != src2.count or src1.shape != src2.shape:
                return False
            for i in range(1, src1.count + 1):
                if not np.allclose(src1.read(i), src2.read(i), equal_nan=True):
                    return False
            return True
    except Exception as e:
        print("ERROR comparing TIFFs:", e)
        return False


# ******************************************************************************
# Get command line arguments
# ******************************************************************************
IS_arg = len(sys.argv)
if IS_arg != 3:
    print('ERROR - 2 arguments must be used')
    raise SystemExit(22)

file_org = sys.argv[1]
file_tst = sys.argv[2]


# ******************************************************************************
# Check if files exist
# ******************************************************************************
try:
    with open(file_org) as file:
        pass
except IOError:
    print('ERROR - Unable to open ' + file_org)
    raise SystemExit(22)

try:
    with open(file_tst) as file:
        pass
except IOError:
    print('ERROR - Unable to open ' + file_tst)
    raise SystemExit(22)


# ******************************************************************************
# Compare original and test files
# ******************************************************************************
# Perform comparison
if not compare_files(file_org, file_tst):
    print('ERROR - Comparison failed.')
    raise SystemExit(99)
else:
    print('Comparison successful!')
