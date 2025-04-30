#!/bin/bash
#*****************************************************************************
#opera_swot_comp.sh
#*****************************************************************************

#Purpose:
#This script reproduces analysis steps to compare OPERA and SWOT width
#observations

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
tot=20
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
#Download SWOT observations that overlap target nodes
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt

mkdir -p "../output/sword/nodes"

echo "- Downloading SWORD node data in target area"
../src/Download_SWOT_Node_Data_Pass_v16.py                                     \
    ../output/sword/nodes/                                                     \
    "2023-07-01"                                                               \
    "2024-10-19"                                                               \
    ../input/swot_orbit/SWOT_orbit.nc                                          \
    ../output/swot/                                                            \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

rm -f $run_file
echo "Success"
echo "********************"
fi

#*****************************************************************************
#Fill in missing node xtrk distance values
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt

echo "- Filling missing xtrk distance values"
for ((i = 0; i < ${#utm[@]}; i++)); do

    echo $i
    
    ../src/swot_xtrk_fill.py                                                       \
        ../output/swot/swot_nodes_2023-07-01to2024-10-19.csv                       \
        ../input/swot_orbit/swot_science_hr_Aug2021-v05_shapefile_nadir/swot_science_hr_2.0s_4.0s_Aug2021-v5_nadir.shp\
        ../output/sword/nodes/target_nodes_utm${utm[i]}.shp                        \
        ../input/utm_zones/missouri_utm${utm[i]}.shp                               \
        ${utm[i]}                                                                  \
        > $run_file
    x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi
    
done

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

echo "- Decoding SWOT bitwise flags"
../src/swot_bitwise_qual.py                                                    \
    ../output/swot/swot_nodes_2023-07-01to2024-10-19.csv                       \
    ../output/swot/swot_nodes_2023-07-01to2024-10-19_bit_qual.csv              \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

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

echo "- Pairing SWOT and OPERA node observations"
../src/node_comp_bitwise.py                                                    \
    ../output/swot/swot_nodes_2023-07-01to2024-10-19.csv                       \
    ../output/swot/swot_nodes_2023-07-01to2024-10-19_bit_qual.csv              \
    ../output/opera/width                                                      \
    ../output/opera/swot_comp/opera_swot_comp_2023-07-01to2024-10-19.csv       \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Plot OPERA SWOT node comparisons
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt

echo "- Plotting SWOT and OPERA node comparisons"
../src/node_comp_plots.py                                                      \
    ../output/opera/swot_comp/opera_swot_comp_2023-07-01to2024-10-19.csv       \
    ../output/swot/swot_nodes_2023-07-01to2024-10-19.csv                       \
    ../output/swot/swot_nodes_2023-07-01to2024-10-19_bit_qual.csv              \
    ../output/opera/width/                                                     \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

rm -f $run_file
echo "Success"
echo "********************"
fi


#*****************************************************************************
#Run statistical tests on OPERA SWOT paired observations
#*****************************************************************************
unt=$((unt+1))
if (("$unt" >= "$fst")) && (("$unt" <= "$lst")) ; then
echo "Running unit test $unt/$tot"

run_file=tmp_run_$unt.txt

echo "- Running statistical tests on SWOT and OPERA observations"
../src/node_stat_tests.py                                                      \
    ../output/opera/swot_comp/opera_swot_comp_2023-07-01to2024-10-19.csv       \
    ../output/sword/nodes/                                                     \
    ../output/opera/stat_test/node_stat_test.shp                               \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

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

echo "- Calculating summary metrics at each node"
../src/node_comp_metrics.py                                                    \
    ../output/opera/swot_comp/opera_swot_comp_2023-07-01to2024-10-19.csv       \
    ../output/sword/nodes/                                                     \
    ../output/opera/node_metrics/swot_opera_node_metrics_2023-07-01to2024-10-19.csv\
    ../output/opera/node_metrics/swot_opera_node_metrics_2023-07-01to2024-10-19.shp\
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi

rm -f $run_file
echo "Success"
echo "********************"
fi
