#!/bin/bash
#*****************************************************************************
#tst_case_dwnl_Wade_etal_2025.sh
#*****************************************************************************
#Purpose:
#This scripts downloads Python backends for width computation scripts.

#DOI: xx.xxxx/xxxxxxxxxxxx
#The files used are available from:
#DOI doi.org/10.5281/zenodo.15391839

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
echo "Downloading files from:   https://doi.org/10.5281/zenodo.15391839"
echo "which correspond to   :   https://doi.org/xx.xxxx/xxxxxxxxxxxx"
echo "These files are under a CC BY-NC-SA 4.0 license."
echo "Please cite these two DOIs if using these files for your publications."
echo "********************"


#*****************************************************************************
#Download WBT
#*****************************************************************************
echo "- Downloading WBT"

URL="https://www.whiteboxgeo.com/WBT_Linux/WhiteboxTools_linux_amd64.zip"
folder="../wbt_download"
zip_file="$folder/$(basename $URL)"

mkdir -p $folder
wget -nv -nc $URL -P $folder
if [ $? -gt 0 ] ; then echo "Problem downloading $file" >&2 ; exit 44 ; fi

unzip -nq "$zip_file" -d "$folder"
rm -f "$zip_file"
if [ $? -gt 0 ] ; then echo "Problem unzipping" >&2 ; exit 22 ; fi

mv "$folder/WhiteboxTools_linux_amd64/WBT" ../WBT/
chmod +x ../WBT/whitebox_tools
if [ $? -gt 0 ]; then echo "Problem moving WBT folder" >&2; exit 22; fi

echo "Success"
echo "********************"

#*****************************************************************************
#Done
#*****************************************************************************


#*****************************************************************************
#Download DSWx-Width Zenodo Repository to /input_testing/ and /output_testing/
#*****************************************************************************
echo "- Downloading DSWx-Width repository"
#-----------------------------------------------------------------------------
#Download parameters
#-----------------------------------------------------------------------------
URL="https://zenodo.org/records/15391839/files"
folder="../"
list=("input_testing.zip"                                                      \
      "output_testing.zip")

#-----------------------------------------------------------------------------
#Download process
#-----------------------------------------------------------------------------
for ((i = 0; i < ${#list[@]}; i++)); do
    wget -nv -nc $URL/${list[i]} -P $folder
    if [ $? -gt 0 ] ; then echo "Problem downloading ${list[i]}" >&2 ; exit 44 ; fi
    
#-----------------------------------------------------------------------------
#Extract files
#-----------------------------------------------------------------------------
    unzip -nq "${folder}${list[i]}" -d "$folder"
    if [ $? -gt 0 ] ; then echo "Problem extracting ${list[i]}" >&2 ; exit 22 ; fi
    
#-----------------------------------------------------------------------------
#Delete zip files
#-----------------------------------------------------------------------------
    rm "${folder}${list[i]}"
    if [ $? -gt 0 ] ; then echo "Problem deleting ${list[i]}" >&2 ; exit 22 ; fi
done

echo "Success"
echo "********************"

#*****************************************************************************
#Done
#*****************************************************************************
