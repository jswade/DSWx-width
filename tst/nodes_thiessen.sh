#!/bin/bash
#*****************************************************************************
#nodes_theissen.sh
#*****************************************************************************

#Purpose:
#This script reproduces analysis steps to produce Thiessen Polygons around
#SWORD nodes in the target region.

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
#Define UTM regions
#*****************************************************************************
utm=("12N"
     "13N"
     "14N"
     "15N"
     )


#*****************************************************************************
#Select SWORD nodes in target area
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt

mkdir -p "../output/sword/nodes"

echo "- Selecting SWORD nodes in target area"
for ((i = 0; i < ${#utm[@]}; i++)); do

    echo $i

    ../src/01_SelectSWORDFeatures_v16.py                                       \
        ../input/sword/SWORD_v16_netcdf/na_sword_v16.nc                        \
        ../input/utm_zones/missouri_utm${utm[i]}.shp                           \
        "7429"                                                                 \
        ${utm[i]}                                                              \
        ../output/sword/nodes/target_nodes_utm${utm[i]}.shp                    \
        > $run_file
    x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

done

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

mkdir -p "../output/sword/buffers"

echo "- Buffering SWORD nodes"
for ((i = 0; i < ${#utm[@]}; i++)); do

    echo $i

    ../src/02_CreateSWORDBuffers_v16.py                                        \
        ../output/sword/nodes/target_nodes_utm${utm[i]}.shp                    \
        ../output/sword/buffers/ext_dist_buffer_utm${utm[i]}.shp               \
        > $run_file
    x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

done

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

mkdir -p "../output/sword/voronoi"

echo "- Generating Thiessen polygons"
for ((i = 0; i < ${#utm[@]}; i++)); do

    echo $i

    ../src/03_CreateThiessenPolygons_v16.py                                    \
        ../output/sword/nodes/target_nodes_utm${utm[i]}.shp                    \
        ../output/sword/buffers/ext_dist_buffer_utm${utm[i]}.shp               \
        ../output/sword/voronoi/clipped_voronoi_utm${utm[i]}.shp               \
        > $run_file
    x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

done

rm -f $run_file
echo "Success"
echo "********************"
fi
