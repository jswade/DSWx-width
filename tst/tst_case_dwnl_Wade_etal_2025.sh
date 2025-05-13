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
#echo "- Downloading WBT"
#
#URL="https://www.whiteboxgeo.com/WBT_Linux/WhiteboxTools_linux_amd64.zip"
#folder="../wbt_download"
#zip_file="$folder/$(basename $URL)"
#
#mkdir -p $folder
#wget -nv -nc $URL -P $folder
#if [ $? -gt 0 ] ; then echo "Problem downloading $file" >&2 ; exit 44 ; fi
#
#unzip -nq "$zip_file" -d "$folder"
#rm -f "$zip_file"
#if [ $? -gt 0 ] ; then echo "Problem unzipping" >&2 ; exit 22 ; fi
#
#mv "$folder/WhiteboxTools_linux_amd64/WBT" ../WBT/
#chmod +x ../WBT/whitebox_tools
#if [ $? -gt 0 ]; then echo "Problem moving WBT folder" >&2; exit 22; fi
#
#echo "Success"
#echo "********************"

echo "- Downloading WBT"

# Define URL and paths
URL="https://www.whiteboxgeo.com/WBT_Linux/WhiteboxTools_linux_amd64.zip"
folder="$HOME/wbt_download"  # Download folder inside the runner's home directory
zip_file="$folder/$(basename $URL)"

# Create download directory
mkdir -p $folder

# Download the zip file
wget -nv -nc $URL -P $folder
if [ $? -gt 0 ]; then
    echo "Problem downloading $URL" >&2
    exit 44
fi

# Unzip the downloaded file
unzip -nq "$zip_file" -d "$folder"
rm -f "$zip_file"
if [ $? -gt 0 ]; then
    echo "Problem unzipping" >&2
    exit 22
fi

# Move the WBT executable to a directory you control
mkdir -p $HOME/whitebox_tools  # Directory where WBT will be stored
mv "$folder/WhiteboxTools_linux_amd64/WBT" $HOME/whitebox_tools/whitebox_tools
chmod +x $HOME/whitebox_tools/whitebox_tools
if [ $? -gt 0 ]; then
    echo "Problem moving WBT folder" >&2
    exit 22
fi

# Add WhiteboxTools to PATH for subsequent commands
echo "export PATH=$HOME/whitebox_tools:$PATH" >> $GITHUB_ENV

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
