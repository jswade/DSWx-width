#!/bin/bash
#*****************************************************************************
#swot_rasterize.sh
#*****************************************************************************

#Purpose:
#This script reproduces analysis steps to rasterize a SWOT PIXCVec point cloud
#and compare it to OPERA DSWx water extent.

#DOI: xx.xxxx/xxxxxxxxxxxx
#The files used are available from:

#Zenodo
#DOI:
#The script returns the following exit codes
# - 0  if all downloads are successful
# - 22 if there was a conversion problem
# - 44 if one download is not successful
#Author:
#Jeffrey Wade, Renato Frasson, Cedric H. David, 2024.

#*****************************************************************************
#Publication message
#*****************************************************************************
echo "********************"
echo "Reproducing files for: https://doi.org/xx.xxxx/xxxxxxxxx"
echo "********************"


#*****************************************************************************
#Select which unit tests to perform based on inputs to this shell script
#*****************************************************************************
#Perform all unit tests if no options are given
tot=3
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
#Convert SWOT PIXCVec Point Cloud NetCDF to Shapefile
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt

mkdir -p "../output/opera/swot_rast_diff"

echo "- Converting PIXCVec from .nc to .shp (Wide River)"

../src/swot_pixcvec_decode.py                                                  \
    ../input/swot_pixcvec/SWOT_L2_HR_PIXCVec_020_037_230R_20240821T232036_20240821T232047_PIC0_01.nc\
    32614                                                                      \
    ../output/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_020_037_230R_20240821T232036_20240821T232047_PIC0_01.shp\
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

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

echo "- Converting PIXCVec from .nc to .shp (Narrow River)"

../src/swot_pixcvec_decode.py                                                  \
    ../input/swot_pixcvec/SWOT_L2_HR_PIXCVec_018_037_230R_20240711T055027_20240711T055039_PIC0_01.nc\
    32614                                                                      \
    ../output/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_018_037_230R_20240711T055027_20240711T055039_PIC0_01.shp\
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

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

echo "- Rasterize PIXCVec point cloud (Wide River)"

../src/swot_pixcvec_raster.py                                                  \
    ../output/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_020_037_230R_20240821T232036_20240821T232047_PIC0_01.shp\
    ../output/opera/conwater/main_river/opera_14N_2024-08-10_2024-08-24_main_river.tif\
    ../output/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_020_037_230R_20240821T232036_20240821T232047_PIC0_01.tif\
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

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

echo "- Rasterize PIXCVec point cloud (Narrow River)"

../src/swot_pixcvec_raster.py                                                  \
    ../output/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_018_037_230R_20240711T055027_20240711T055039_PIC0_01.shp\
    ../output/opera/conwater/main_river/opera_14N_2024-06-29_2024-07-13_main_river.tif\
    ../output/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_018_037_230R_20240711T055027_20240711T055039_PIC0_01.tif\
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

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

echo "- Calculating difference between SWOT and OPERA rasters (Wide River)"

../src/raster_diff.py                                                          \
    ../output/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_020_037_230R_20240821T232036_20240821T232047_PIC0_01.tif\
    ../output/opera/conwater/main_river/opera_14N_2024-08-10_2024-08-24_main_river.tif\
    ../output/opera/swot_rast_diff/OPERA_SWOT_PIXCVEC_diff_020_037_230R_20240821T232036_20240821T232047_PIC0_01.tif\
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

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

echo "- Calculating difference between SWOT and OPERA rasters (Narrow River)"

../src/raster_diff.py                                                          \
    ../output/opera/swot_rast_diff/SWOT_L2_HR_PIXCVec_018_037_230R_20240711T055027_20240711T055039_PIC0_01.tif\
    ../output/opera/conwater/main_river/opera_14N_2024-06-29_2024-07-13_main_river.tif\
    ../output/opera/swot_rast_diff/OPERA_SWOT_PIXCVEC_diff_018_037_230R_20240711T055027_20240711T055039_PIC0_01.tif\
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

rm -f $run_file
echo "Success"
echo "********************"
fi


