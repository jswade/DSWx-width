#!/bin/bash
#*****************************************************************************
#opera_width.sh
#*****************************************************************************

#Purpose:
#This script reproduces analysis steps to calculate river widths
#from aggregated OPERA HLS DSWx tiles.

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
tot=10
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
#Reclassify OPERA DSWx CONF files to match WTR
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt

mkdir -p "../output/opera/conf_reclass/"

echo "- Reclassify OPERA CONF files"

../src/ConfReclass_OPERA_v16.py                                                \
    ../input/opera/conf/                                                       \
    "agg"                                                                      \
    ../output/opera/conf_reclass/                                              \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

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

mkdir -p "../output/opera/temp_agg"

echo "- Aggregating OPERA tiles"

../src/TempAgg_OPERA_v16.py                                                    \
    ../output/opera/conf_reclass/                                              \
    "2023-07-01"                                                               \
    "2024-10-19"                                                               \
    14                                                                         \
    ../output/opera/temp_agg/                                                  \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

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

mkdir -p "../output/opera/utm_overlap"

echo "- Identify overlap between UTM Zones and OPERA tiles"

../src/UTM_Overlap_OPERA_v16.py                                                \
    ../output/opera/temp_agg/                                                  \
    ../input/utm_zones/                                                        \
    ../output/opera/utm_overlap/opera_utm_overlap.csv                          \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

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

mkdir -p "../output/opera/merge"

echo "- Merging OPERA tiles"
for ((i = 0; i < ${#utm[@]}; i++)); do

    echo $i
    
    ../src/SpatialAgg_OPERA_v16.py                                             \
        ../output/opera/temp_agg/                                              \
        ../output/opera/utm_overlap/opera_utm_overlap.csv                      \
        ${utm[i]}                                                              \
        ../output/opera/merge/                                                 \
        > $run_file
    x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

done

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

mkdir -p "../output/opera/clump/reclass"
mkdir -p "../output/opera/clump/clumpedras_poly"

echo "- Clumping similar pixels"
for ((i = 0; i < ${#utm[@]}; i++)); do

    echo $i

    ../src/04_Clump_v16.py                                                     \
        ../output/opera/merge/                                                 \
        ../output/sword/voronoi/clipped_voronoi_utm${utm[i]}.shp               \
        ${utm[i]}                                                              \
        ../output/opera/clump/                                                 \
        > $run_file
    x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

done

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

mkdir -p "../output/opera/conwater/con_ras"
mkdir -p "../output/opera/conwater/con_reclass"
mkdir -p "../output/opera/conwater/main_river"

echo "- Creating main river"
for ((i = 0; i < ${#utm[@]}; i++)); do

    echo $i

    ../src/05_CreatingMainRiver_v16.py                                         \
        ../output/opera/clump/                                                 \
        ../output/sword/voronoi/clipped_voronoi_utm${utm[i]}.shp               \
        ../output/sword/nodes/target_nodes_utm${utm[i]}.shp                    \
        ../output/opera/merge/                                                 \
        ${utm[i]}                                                              \
        ../output/opera/conwater/                                              \
        > $run_file
    x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi
    
done

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

mkdir -p "../output/opera/pixel_num"

echo "- Extracting pixel classes"
for ((i = 0; i < ${#utm[@]}; i++)); do

    echo $i

    ../src/06_PixelClassSummary_v16.py                                         \
        ../output/opera/conwater/main_river/                                   \
        ../output/sword/voronoi/clipped_voronoi_utm${utm[i]}.shp               \
        ${utm[i]}                                                              \
        ../output/opera/pixel_num/                                             \
        > $run_file
    x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

done

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

mkdir -p "../output/opera/width_utm"

echo "- Calculating river widths"
for ((i = 0; i < ${#utm[@]}; i++)); do

    echo $i

    ../src/07_ThiessenWidthExtraction_v16.py                                   \
        ../output/opera/pixel_num/                                             \
        ${utm[i]}                                                              \
        ../output/opera/width_utm/                                             \
        > $run_file
    x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi
    
done

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

mkdir -p "../output/opera/width"

echo "- Combining river width files"

../src/08_WidthAggregation_v16.py                                              \
    ../output/opera/width_utm/                                                 \
    ../output/opera/width/                                                     \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

rm -f $run_file
echo "Success"
echo "********************"
fi
