#!/bin/bash
#*****************************************************************************
#tst_case_dwnl_Wade_etal_2025.sh
#*****************************************************************************
#Purpose:
#This scripts downloads Python backends for width computation scripts.

#DOI: xx.xxxx/xxxxxxxxxxxx
#The files used are available from:

#Zenodo
#DOI:
#The script returns the following exit codes
# - 0  if all downloads are successful
# - 22 if there was a conversion problem
# - 44 if one download is not successful
#Author:
#Jeffrey Wade, Renato Frasson, Cedric H. David, 2025.

#*****************************************************************************
#Publication message
#*****************************************************************************
echo "********************"
echo "Reproducing files for: https://doi.org/xx.xxxx/xxxxxxxxx"
echo "********************"


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
#Download WBT
#*****************************************************************************
echo "- Downloading WBT"

URL="https://www.whiteboxgeo.com/WBT_Darwin/WhiteboxTools_darwin_amd64.zip"
folder="../"
zip_file="$folder/$(basename $URL)"

wget -nv -nc $URL -P $folder
if [ $? -gt 0 ] ; then echo "Problem downloading $file" >&2 ; exit 44 ; fi

unzip -nq "$zip_file" -d "$folder"
rm -f "$zip_file"
if [ $? -gt 0 ] ; then echo "Problem unizpping" >&2 ; exit 22 ; fi

mv "$folder/WhiteboxTools_darwin_amd64/WBT" ../
if [ $? -gt 0 ]; then echo "Problem moving WBT folder" >&2; exit 22; fi

echo "Success"
echo "********************"


#*****************************************************************************
#Download DSWx-Width Zenodo Repository to /input_testing/ and /output_testing/
#*****************************************************************************
echo "- Downloading DSWx-Width repository"
#-----------------------------------------------------------------------------
#Download parameters
#-----------------------------------------------------------------------------
URL="https://zenodo.org/records/XXXXXXX/files"
folder=("../input_testing"                                                     \
        "../output_testing")
list=("input_testing.zip"                                                      \
      "output_testing.zip")

#-----------------------------------------------------------------------------
#Download process
#-----------------------------------------------------------------------------
mkdir -p $folder
for ((i = 0; i < ${#list[@]}; i++)); do

    wget -nv -nc $URL/${list[i]} -P $folder
    if [ $? -gt 0 ] ; then echo "Problem downloading $file" >&2 ; exit 44 ; fi
    
#-----------------------------------------------------------------------------
#Extract files
#-----------------------------------------------------------------------------
    unzip -nq "${folder[i]}/${list[i]}" -d "${folder[i]}/"
    if [ $? -gt 0 ] ; then echo "Problem converting" >&2 ; exit 22 ; fi
    
#-----------------------------------------------------------------------------
#Delete zip files
#-----------------------------------------------------------------------------
    rm "${folder[i]}/${list[i]}"
    if [ $? -gt 0 ] ; then echo "Problem converting" >&2 ; exit 22 ; fi
done

echo "Success"
echo "********************"

#*****************************************************************************
#Done
#*****************************************************************************
