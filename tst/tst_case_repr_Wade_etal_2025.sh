#!/bin/bash
#*****************************************************************************
#tst_case_repr_Wade_etal_2025.sh
#*****************************************************************************
#Purpose:
#This script reproduces testing pre- and post-processing steps used in the
#writing of:

#DOI: xx.xxxx/xxxxxxxxxxxx

#Zenodo
#DOI: 10.5281/zenodo.15391839
#The following are the possible arguments:
# - No argument: all unit tests are run
# - One unique unit test number: this test is run
# - Two unit test numbers: all tests between those (included) are run
#The script returns the following exit codes
# - 0  if all downloads are successful
# - 22 if there was a conversion problem
# - 44 if one download is not successful
#Author:
#Jeffrey Wade, Renato Frasson, Cedric H. David, 2025.

#
#*****************************************************************************
#Publication message
#*****************************************************************************
echo "********************"
echo "Reproducing files for: https://doi.org/xx.xxxx/xxxxxxxxxxxx"
echo "********************"


#*****************************************************************************
#Select which unit tests to perform based on inputs to this shell script
#*****************************************************************************
#Perform all unit tests if no options are given
tot=22
if [ "$#" = "0" ]; then
     fst=1
     lst=$tot
     echo "Performing all unit tests: $1-$2"
     echo "********************"
fi

#Perform one single unit test if one option is given
if [ "$#" = "1" ]; then
     fst=$1
     lst=$1
     echo "Performing one unit test: $1"
     echo "********************"
fi

#Perform all unit tests between first and second option given (both included)
if [ "$#" = "2" ]; then
     fst=$1
     lst=$2
     echo "Performing unit tests: $1-$2"
     echo "********************"
fi

#Exit if more than two options are given
if [ "$#" -gt "2" ]; then
     echo "A maximum of two options can be used" 1>&2
     exit 22
fi


#*****************************************************************************
#Initialize count for unit tests
#*****************************************************************************
unt=0


#*****************************************************************************
#Define UTM regions
#*****************************************************************************
utm="12N"


#*****************************************************************************
#Select SWORD nodes in target area
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

mkdir -p "../output_test/sword/nodes"

echo "- Selecting SWORD nodes in target area"
../src/SelectSWORDFeatures.py                                                  \
    ../input_testing/sword/SWORD_v16_netcdf/na_sword_v16.nc                    \
    ../input_testing/utm_zones/missouri_utm${utm}.shp                          \
    "7429"                                                                     \
    ${utm[i]}                                                                  \
    ../output_test/sword/nodes/target_nodes_utm${utm}.shp                      \
    > $run_file
#x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi
x=$?
if [ $x -gt 0 ]; then
    echo "❌ Failed run: $run_file" >&2
    cat $run_file >&2
    exit $x
fi

echo "- Comparing SWORD shapefile (.shp)"
../src/tst_cmp.py                                                              \
    ../output_testing/sword/nodes/target_nodes_utm${utm}.shp                   \
    ../output_test/sword/nodes/target_nodes_utm${utm}.shp                      \
    > $cmp_file
#x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi
x=$?
if [ $x -gt 0 ]; then
    echo "Failed comparison: $cmp_file" >&2
    echo "--- Comparison output ---"
    cat $cmp_file >&2
    # Save debug info for GitHub Actions artifact upload (optional)
    cp $cmp_file "failed_comparison_${unt}.txt"
    exit $x
fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Create buffer around SWORD nodes
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

mkdir -p "../output_test/sword/buffers"

echo "- Buffering SWORD nodes"
../src/CreateSWORDBuffers.py                                                   \
    ../output_testing/sword/nodes/target_nodes_utm${utm}.shp                   \
    ../output_test/sword/buffers/ext_dist_buffer_utm${utm}.shp                 \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing SWORD node buffers (.shp)"
../src/tst_cmp.py                                                              \
    ../output_testing/sword/buffers/ext_dist_buffer_utm${utm}.shp              \
    ../output_test/sword/buffers/ext_dist_buffer_utm${utm}.shp                 \
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Generate Thiessen Polygons around SWORD nodes
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

mkdir -p "../output_test/sword/voronoi"

echo "- Generating Thiessen polygons"
../src/CreateThiessenPolygons.py                                               \
    ../output_testing/sword/nodes/target_nodes_utm${utm}.shp                   \
    ../output_testing/sword/buffers/ext_dist_buffer_utm${utm}.shp              \
    ../output_test/sword/voronoi/clipped_voronoi_utm${utm}.shp                 \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing Thiessen Polygons (.shp)"
../src/tst_cmp.py                                                              \
    ../output_testing/sword/voronoi/clipped_voronoi_utm${utm}.shp              \
    ../output_test/sword/voronoi/clipped_voronoi_utm${utm}.shp                 \
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Reclassify OPERA DSWx CONF files to match WTR
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

mkdir -p "../output_test/opera/conf_reclass/"

echo "- Reclassify OPERA CONF files"

../src/ConfReclass_OPERA.py                                                    \
    ../input_testing/opera/conf/                                               \
    "agg"                                                                      \
    ../output_test/opera/conf_reclass/                                         \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing Reclassified CONF files (.tif)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/conf_reclass/OPERA_L3_DSWx-HLS_T12TVQ_20240716T181242Z_20240719T154647Z_L8_30_v1.0_B03_CONF_reclass.tif\
    ../output_test/opera/conf_reclass/OPERA_L3_DSWx-HLS_T12TVQ_20240716T181242Z_20240719T154647Z_L8_30_v1.0_B03_CONF_reclass.tif\
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Temporally aggregate OPERA tiles in using moving date window
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

mkdir -p "../output_test/opera/temp_agg"

echo "- Aggregating OPERA tiles"

../src/TempAgg_OPERA.py                                                        \
    ../output_testing/opera/conf_reclass/                                      \
    "2023-07-01"                                                               \
    "2024-10-19"                                                               \
    14                                                                         \
    ../output_test/opera/temp_agg/                                             \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing Aggregated CONF files (.tif)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/temp_agg/opera_T12TVQ_2024-07-13_2024-07-27.tif    \
    ../output_test/opera/temp_agg/opera_T12TVQ_2024-07-13_2024-07-27.tif       \
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Identify overlap between OPERA tiles and UTM Zones
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

mkdir -p "../output_test/opera/utm_overlap"

echo "- Identify overlap between UTM Zones and OPERA tiles"

../src/UTM_Overlap_OPERA.py                                                    \
    ../output_testing/opera/temp_agg/                                          \
    ../input_testing/utm_zones/                                                \
    ../output_test/opera/utm_overlap/opera_utm_overlap.csv                     \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing UTM Overlap files (.csv)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/utm_overlap/opera_utm_overlap.csv                  \
    ../output_test/opera/utm_overlap/opera_utm_overlap.csv                     \
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Spatially merge temporally aggregated OPERA tiles within moving date window
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

mkdir -p "../output_test/opera/merge"

echo "- Merging OPERA tiles"
../src/SpatialAgg_OPERA.py                                                     \
    ../output_testing/opera/temp_agg/                                          \
    ../output_testing/opera/utm_overlap/opera_utm_overlap.csv                  \
    ${utm}                                                                     \
    ../output_test/opera/merge/                                                \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing Merged OPERA tiles (.tif)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/merge/opera_12N_2024-07-13_2024-07-27.tif          \
    ../output_test/opera/merge/opera_12N_2024-07-13_2024-07-27.tif             \
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Reclassify and clump similar pixels
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

mkdir -p "../output_test/opera/clump/reclass"
mkdir -p "../output_test/opera/clump/clumpedras_poly"

echo "- Clumping similar pixels"
../src/Clump.py                                                                \
    ../output_testing/opera/merge/                                             \
    ../output_testing/sword/voronoi/clipped_voronoi_utm${utm}.shp              \
    ${utm}                                                                     \
    ../output_test/opera/clump/                                                \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing Clumped reclassified tiles (.tif)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/clump/reclass/opera_12N_2024-07-13_2024-07-27_reclassified.tif\
    ../output_test/opera/clump/reclass/opera_12N_2024-07-13_2024-07-27_reclassified.tif\
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

echo "- Comparing Clumped shapefiles (.shp)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/clump/clumpedras_poly/opera_12N_2024-07-13_2024-07-27_clumpedRas_poly.shp\
    ../output_test/opera/clump/clumpedras_poly/opera_12N_2024-07-13_2024-07-27_clumpedRas_poly.shp\
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Create the main river from clumped tif
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

mkdir -p "../output_test/opera/conwater/con_ras"
mkdir -p "../output_test/opera/conwater/con_reclass"
mkdir -p "../output_test/opera/conwater/main_river"

echo "- Creating main river"
../src/CreatingMainRiver.py                                                    \
    ../output_testing/opera/clump/                                             \
    ../output_testing/sword/voronoi/clipped_voronoi_utm${utm}.shp              \
    ../output_testing/sword/nodes/target_nodes_utm${utm[i]}.shp                \
    ../output_testing/opera/merge/                                             \
    ${utm}                                                                     \
    ../output_test/opera/conwater/                                             \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing connected water raster (.tif)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/conwater/con_ras/opera_12N_2024-07-13_2024-07-27_connected_water_raster.tif\
    ../output_test/opera/conwater/con_ras/opera_12N_2024-07-13_2024-07-27_connected_water_raster.tif\
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

echo "- Comparing connected reclassified raster (.tif)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/conwater/con_reclass/opera_12N_2024-07-13_2024-07-27_connected_reclass.tif\
    ../output_test/opera/conwater/con_reclass/opera_12N_2024-07-13_2024-07-27_connected_reclass.tif\
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

echo "- Comparing main river raster (.tif)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/conwater/main_river/opera_12N_2024-07-13_2024-07-27_main_river.tif\
    ../output_test/opera/conwater/main_river/opera_12N_2024-07-13_2024-07-27_main_river.tif\
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Extract pixel classes for thiessen polygons
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

mkdir -p "../output_test/opera/pixel_num"

echo "- Extracting pixel classes"
../src/PixelClassSummary.py                                                    \
    ../output_testing/opera/conwater/main_river/                               \
    ../output_testing/sword/voronoi/clipped_voronoi_utm${utm}.shp              \
    ${utm}                                                                     \
    ../output_test/opera/pixel_num/                                            \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing pixel number files (.csv)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/pixel_num/opera_12N_2024-07-13_2024-07-27_pixel_nums_thiessen.csv\
    ../output_test/opera/pixel_num/opera_12N_2024-07-13_2024-07-27_pixel_nums_thiessen.csv\
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Calculate river widths for thiessen polygons by UTM zone
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

mkdir -p "../output_test/opera/width_utm"

echo "- Calculating river widths"
../src/ThiessenWidthExtraction.py                                              \
    ../output_testing/opera/pixel_num/                                         \
    ${utm}                                                                     \
    ../output_test/opera/width_utm/                                            \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing river width files (.csv)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/width_utm/opera_12N_2024-07-13_2024-07-27_river_width.csv\
    ../output_test/opera/width_utm/opera_12N_2024-07-13_2024-07-27_river_width.csv\
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Combine width files by date window
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

mkdir -p "../output_test/opera/width"

echo "- Combining river width files"
../src/WidthAggregation.py                                                     \
    ../output_testing/opera/width_utm/                                         \
    ../output_test/opera/width/                                                \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing combined river width files (.csv)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/width/opera_2024-07-13_2024-07-27_river_width.csv  \
    ../output_test/opera/width/opera_2024-07-13_2024-07-27_river_width.csv     \
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Convert SWOT PIXCVec Point Cloud NetCDF to Shapefile
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

mkdir -p "../output_test/opera/swot_rast_diff"

echo "- Converting PIXCVec from .nc to .shp (Wide River)"
../src/SWOT_Pixcvec_Decode.py                                                  \
    ../input_testing/swot_pixcvec/SWOT_L2_HR_PIXCVec_020_037_230R_20240821T232036_20240821T232047_PIC0_01.nc\
    32614                                                                      \
    ../output_test/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_020_037_230R_20240821T232036_20240821T232047_PIC0_01.shp\
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing PIXCVec shapefiles (.shp)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_020_037_230R_20240821T232036_20240821T232047_PIC0_01.shp\
    ../output_test/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_020_037_230R_20240821T232036_20240821T232047_PIC0_01.shp\
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Convert SWOT PIXCVec Point Cloud NetCDF to Shapefile
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

echo "- Converting PIXCVec from .nc to .shp (Narrow River)"
../src/SWOT_Pixcvec_Decode.py                                                  \
    ../input_testing/swot_pixcvec/SWOT_L2_HR_PIXCVec_018_037_230R_20240711T055027_20240711T055039_PIC0_01.nc\
    32614                                                                      \
    ../output_test/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_018_037_230R_20240711T055027_20240711T055039_PIC0_01.shp\
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing PIXCVec shapefiles (.shp)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_018_037_230R_20240711T055027_20240711T055039_PIC0_01.shp\
    ../output_test/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_018_037_230R_20240711T055027_20240711T055039_PIC0_01.shp\
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Rasterize SWOT PIXCVec Point Cloud to Match Resolution of OPERA DSWx
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

echo "- Rasterize PIXCVec point cloud (Wide River)"
../src/swot_pixcvec_raster.py                                                  \
    ../output_testing/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_020_037_230R_20240821T232036_20240821T232047_PIC0_01.shp\
    ../output_testing/opera/conwater/main_river/opera_14N_2024-08-10_2024-08-24_main_river.tif\
    ../output_test/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_020_037_230R_20240821T232036_20240821T232047_PIC0_01.tif\
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing PIXCVec point cloud raster (.tif)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_020_037_230R_20240821T232036_20240821T232047_PIC0_01.tif\
    ../output_test/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_020_037_230R_20240821T232036_20240821T232047_PIC0_01.tif\
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Rasterize SWOT PIXCVec Point Cloud to Match Resolution of OPERA DSWx
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

echo "- Rasterize PIXCVec point cloud (Narrow River)"
../src/SWOT_Pixcvec_Raster.py                                                  \
    ../output_testing/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_018_037_230R_20240711T055027_20240711T055039_PIC0_01.shp\
    ../output_testing/opera/conwater/main_river/opera_14N_2024-06-29_2024-07-13_main_river.tif\
    ../output_test/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_018_037_230R_20240711T055027_20240711T055039_PIC0_01.tif\
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing PIXCVec point cloud raster (.tif)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_018_037_230R_20240711T055027_20240711T055039_PIC0_01.tif\
    ../output_test/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_018_037_230R_20240711T055027_20240711T055039_PIC0_01.tif\
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Produce raster of difference between OPERA DSWx main river and SWOT PIXCVec
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

echo "- Calculating difference between SWOT and OPERA rasters (Wide River)"
../src/Raster_Diff.py                                                          \
    ../output_testing/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_020_037_230R_20240821T232036_20240821T232047_PIC0_01.tif\
    ../output_testing/opera/conwater/main_river/opera_14N_2024-08-10_2024-08-24_main_river.tif\
    ../output_test/opera/swot_rast_diff/OPERA_SWOT_PIXCVEC_diff_020_037_230R_20240821T232036_20240821T232047_PIC0_01.tif\
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing difference raster (.tif)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/swot_rast_diff/OPERA_SWOT_PIXCVEC_diff_020_037_230R_20240821T232036_20240821T232047_PIC0_01.tif\
    ../output_test/opera/swot_rast_diff/OPERA_SWOT_PIXCVEC_diff_020_037_230R_20240821T232036_20240821T232047_PIC0_01.tif\
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Produce raster of difference between OPERA DSWx main river and SWOT PIXCVec
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

echo "- Calculating difference between SWOT and OPERA rasters (Narrow River)"
../src/Raster_Diff.py                                                          \
    ../output_testing/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_018_037_230R_20240711T055027_20240711T055039_PIC0_01.tif\
    ../output_testing/opera/conwater/main_river/opera_14N_2024-06-29_2024-07-13_main_river.tif\
    ../output_test/opera/swot_rast_diff/OPERA_SWOT_PIXCVEC_diff_018_037_230R_20240711T055027_20240711T055039_PIC0_01.tif\
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing difference raster (.tif)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/swot_rast_diff/OPERA_SWOT_PIXCVEC_diff_018_037_230R_20240711T055027_20240711T055039_PIC0_01.tif\
    ../output_test/opera/swot_rast_diff/OPERA_SWOT_PIXCVEC_diff_018_037_230R_20240711T055027_20240711T055039_PIC0_01.tif\
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Decode SWOT bitwise node flags
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

mkdir -p "../output_test/swot"

echo "- Decoding SWOT bitwise flags"
../src/SWOT_Bitwise_Qual.py                                                    \
    ../output_testing/swot/swot_nodes_2023-07-01to2024-10-19.csv               \
    ../output_test/swot/swot_nodes_2023-07-01to2024-10-19_bit_qual.csv         \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing bitwise flags (.csv)"
../src/tst_cmp.py                                                              \
    ../output_testing/swot/swot_nodes_2023-07-01to2024-10-19_bit_qual.csv      \
    ../output_test/swot/swot_nodes_2023-07-01to2024-10-19_bit_qual.csv         \
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Pair SWOT and OPERA node observations
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

mkdir -p "../output_test/opera/swot_comp"

echo "- Pairing SWOT and OPERA node observations"
../src/Node_Comp_Bitwise.py                                                    \
    ../output_testing/swot/swot_nodes_2023-07-01to2024-10-19.csv               \
    ../output_testing/swot/swot_nodes_2023-07-01to2024-10-19_bit_qual.csv      \
    ../output_testing/opera/width/                                             \
    ../output_test/opera/swot_comp/opera_swot_comp_2023-07-01to2024-10-19.csv  \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing OPERA-SWOT comparisons (.csv)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/swot_comp/opera_swot_comp_2023-07-01to2024-10-19.csv\
    ../output_test/opera/swot_comp/opera_swot_comp_2023-07-01to2024-10-19.csv  \
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Calculate summary metrics at each node
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt
cmp_file=tmp_cmp_$unt.txt

mkdir -p "../output_test/opera/node_metrics"

echo "- Calculating summary metrics at each node"
../src/Node_Comp_Metrics.py                                                    \
    ../output_testing/opera/swot_comp/opera_swot_comp_2023-07-01to2024-10-19.csv\
    ../output_testing/sword/nodes/                                             \
    ../output_test/opera/node_metrics/swot_opera_node_metrics_2023-07-01to2024-10-19.csv\
    ../output_test/opera/node_metrics/swot_opera_node_metrics_2023-07-01to2024-10-19.shp\
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

echo "- Comparing OPERA-SWOT node metrics (.csv)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/node_metrics/swot_opera_node_metrics_2023-07-01to2024-10-19.csv\
    ../output_test/opera/node_metrics/swot_opera_node_metrics_2023-07-01to2024-10-19.csv\
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

echo "- Comparing OPERA-SWOT node metrics (.shp)"
../src/tst_cmp.py                                                              \
    ../output_testing/opera/node_metrics/swot_opera_node_metrics_2023-07-01to2024-10-19.shp\
    ../output_test/opera/node_metrics/swot_opera_node_metrics_2023-07-01to2024-10-19.shp\
    > $cmp_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed comparison: $cmp_file" >&2 ; exit $x ; fi

rm -f $cmp_file
rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Clean up
#*****************************************************************************
rm -rf ../output_test/
