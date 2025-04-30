#!/bin/bash
#*****************************************************************************
#sword__dwnl.sh
#*****************************************************************************

#Purpose:
#This script downloads SWORD v16 node and reach files.
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
#Download SWORD files (netcdf)
#*****************************************************************************
echo "- Downloading SWORD files"
#-----------------------------------------------------------------------------
#Download parameters
#-----------------------------------------------------------------------------
URL="https://zenodo.org/records/10013982/files"
folder="../input/sword/SWORD_v16_netcdf"
list=("SWORD_v16_netcdf.zip")

#-----------------------------------------------------------------------------
#Download process
#-----------------------------------------------------------------------------
mkdir -p $folder
for file in "${list[@]}"
do
    wget -nv -nc $URL/$file -P $folder/
    if [ $? -gt 0 ] ; then echo "Problem downloading $file" >&2 ; exit 44 ; fi
done

#-----------------------------------------------------------------------------
#Extract files
#-----------------------------------------------------------------------------
unzip -nq "${folder}/${list}" -d "${folder}/${list%.zip}"
if [ $? -gt 0 ] ; then echo "Problem converting" >&2 ; exit 22 ; fi

#-----------------------------------------------------------------------------
#Delete zip file
#-----------------------------------------------------------------------------
rm -rf "${folder}/${list}"
if [ $? -gt 0 ] ; then echo "Problem converting" >&2 ; exit 22 ; fi

echo "Success"
echo "********************"

#*****************************************************************************
#Done
#*****************************************************************************


#*****************************************************************************
#Download SWORD files (shp)
#*****************************************************************************
echo "- Downloading SWORD files"
#-----------------------------------------------------------------------------
#Download parameters
#-----------------------------------------------------------------------------
URL="https://zenodo.org/records/10013982/files"
folder="../input/sword/SWORD_v16_shp"
list=("SWORD_v16_shp.zip")

#-----------------------------------------------------------------------------
#Download process
#-----------------------------------------------------------------------------
mkdir -p $folder
for file in "${list[@]}"
do
    wget -nv -nc $URL/$file -P $folder/
    if [ $? -gt 0 ] ; then echo "Problem downloading $file" >&2 ; exit 44 ; fi
done

#-----------------------------------------------------------------------------
#Extract files
#-----------------------------------------------------------------------------
unzip -nq "${folder}/${list}" -d "${folder}/${list%.zip}"
if [ $? -gt 0 ] ; then echo "Problem converting" >&2 ; exit 22 ; fi

#-----------------------------------------------------------------------------
#Delete zip file
#-----------------------------------------------------------------------------
rm -rf "${folder}/${list}"
if [ $? -gt 0 ] ; then echo "Problem converting" >&2 ; exit 22 ; fi

echo "Success"
echo "********************"

#*****************************************************************************
#Done
#*****************************************************************************
