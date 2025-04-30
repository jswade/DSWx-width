#!/bin/bash
#*****************************************************************************
#opera_dwnl.sh
#*****************************************************************************

#Purpose:
#This script downloads all OPERA HLS DSWx tiles for target region between
#inputs dates.
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
echo "Downloading files from:   https://doi.org/xx.xxxx/xxxxxxxxxxxx"
echo "which correspond to   :   https://doi.org/xx.xxxx/xxxxxxxxxxxx"
echo "These files are under a CC BY-NC-SA 4.0 license."
echo "Please cite these two DOIs if using these files for your publications."
echo "********************"


#*****************************************************************************
#Download OPERA tiles to /input/
#*****************************************************************************
echo "- Downloading OPERA tiles"

run_file=tmp_run_$unt.txt

mkdir -p "../input/opera/conf"
../src/opera_dwnl.py                                                           \
    ../input/shpfiles/target_area.shp                                          \
    ../output/sword/nodes/                                                     \
    2023-07-01                                                                 \
    2024-10-19                                                                 \
    ../input/opera/conf/                                                       \
    ../input/opera_tiles/opera_sentinel2_tile_boundaries.kml                   \
    > $run_file
x=$? && if [ $x -gt 0 ] ; then echo "Failed run" >&2 ; exit $x ; fi

rm -f $run_file
echo "Success"
echo "********************"
