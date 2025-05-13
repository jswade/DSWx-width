#!/bin/bash
#*****************************************************************************
#tst_pub_dwnl_Wade_etal_2025.sh
#*****************************************************************************
#Purpose:
#This scripts downloads all files corresponding to:

#DOI: xx.xxxx/xxxxxxxxxxxx
#The files used are available from:

#Zenodo
#DOI: 10.5281/zenodo.15391839
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
#Done
#*****************************************************************************


#*****************************************************************************
#Download DSWx-Width Zenodo Repository to /input/
#*****************************************************************************
echo "- Downloading DSWx-Width repository"
#-----------------------------------------------------------------------------
#Download parameters
#-----------------------------------------------------------------------------
URL="https://zenodo.org/records/15391839/files"
folder="../"
list=("input.zip"                                                              \
      )

#-----------------------------------------------------------------------------
#Download process
#-----------------------------------------------------------------------------
for file in "${list[@]}"
do
    wget -nv -nc $URL/$file -P $folder
    if [ $? -gt 0 ] ; then echo "Problem downloading $file" >&2 ; exit 44 ; fi
done

#-----------------------------------------------------------------------------
#Extract files
#-----------------------------------------------------------------------------
for file in "${list[@]}"
do
    unzip -nq "${folder}/${file}" -d "${folder}/"
    if [ $? -gt 0 ] ; then echo "Problem converting" >&2 ; exit 22 ; fi
done

#-----------------------------------------------------------------------------
#Delete zip file
#-----------------------------------------------------------------------------
for file in "${list[@]}"
do
    rm "${folder}/${file}"
    if [ $? -gt 0 ] ; then echo "Problem converting" >&2 ; exit 22 ; fi
done

echo "Success"
echo "********************"
#*****************************************************************************
#Done
#*****************************************************************************


#*****************************************************************************
#Download DSWx-Width Zenodo Repository to /output/
#*****************************************************************************
echo "- Downloading DSWx-Width repository"
#-----------------------------------------------------------------------------
#Download parameters
#-----------------------------------------------------------------------------
URL="https://zenodo.org/records/15391838/files"
folder="../output"
list=("output_opera.zip"                                                       \
      "output_sword.zip"                                                       \
      "output_swot.zip"                                                        \
      )

#-----------------------------------------------------------------------------
#Download process
#-----------------------------------------------------------------------------
mkdir -p $folder
for file in "${list[@]}"
do
    wget -nv -nc $URL/$file -P $folder
    if [ $? -gt 0 ] ; then echo "Problem downloading $file" >&2 ; exit 44 ; fi
done

#-----------------------------------------------------------------------------
#Extract files
#-----------------------------------------------------------------------------
for file in "${list[@]}"
do
    unzip -nq "${folder}/${file}" -d "${folder}/"
    if [ $? -gt 0 ] ; then echo "Problem converting" >&2 ; exit 22 ; fi
done

#-----------------------------------------------------------------------------
#Rename extracted folders
#-----------------------------------------------------------------------------
mv "${folder}/output_opera" "${folder}/opera"
mv "${folder}/output_sword" "${folder}/sword"
mv "${folder}/output_swot"  "${folder}/swot"

#-----------------------------------------------------------------------------
#Delete zip file
#-----------------------------------------------------------------------------
for file in "${list[@]}"
do
    rm "${folder}/${file}"
    if [ $? -gt 0 ] ; then echo "Problem converting" >&2 ; exit 22 ; fi
done

echo "Success"
echo "********************"

#*****************************************************************************
#Done
#*****************************************************************************


#*****************************************************************************
#Download OPERA tiles to /input/
#*****************************************************************************
echo "- Downloading OPERA tiles"

run_file=tmp_run_$unt.txt

mkdir -p "../input/opera/conf"
mkdir -p "../input/opera_tiles"

../src/OPERA_Dwnl.py                                                           \
    ../input/area_shp/missouri_area.shp                                        \
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
#*****************************************************************************
#Done
#*****************************************************************************


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
#Download SWOT orbital parameter file
#*****************************************************************************
#Credit:
#CNES. (2025). search_swot [GitHub repository].
#GitHub. https://github.com/CNES/search_swot

URL="https://github.com/CNES/search_swot/raw/refs/heads/master/search_swot/SWOT_orbit.nc?download="
folder="../input/swot_orbit"

mkdir -p $folder
wget -nv -nc -O "$folder/swot_orbit.nc" "$URL"
if [ $? -gt 0 ] ; then echo "Problem downloading $URL" >&2 ; exit 44 ; fi

echo "Success"
echo "********************"
#*****************************************************************************
#Done
#*****************************************************************************


#*****************************************************************************
#Download SWOT nadir track shapefile
#*****************************************************************************
#Credit: https://www.aviso.altimetry.fr/en/missions/current-missions/swot/orbit.html

URL="https://www.aviso.altimetry.fr/fileadmin/documents/missions/Swot/swot_science_hr_Aug2021-v05_shapefile_nadir.zip"
folder="../input/swot_orbit"
zipfile="$folder/swot_nadir.zip"

mkdir -p "$folder"
wget -nv -nc -O "$zipfile" "$URL"
if [ $? -gt 0 ] ; then echo "Problem downloading $URL" >&2 ; exit 44 ; fi

unzip -nq "$zipfile" -d "$folder"
rm -f "$zipfile"
if [ $? -gt 0 ] ; then echo "Problem converting" >&2 ; exit 22 ; fi

echo "Success"
echo "********************"
#*****************************************************************************
#Done
#*****************************************************************************


#*****************************************************************************
#Download SWOT observations that overlap target nodes
#*****************************************************************************
echo "- Downloading SWORD node data in target area"
utm=("12N"
     "13N"
     "14N"
     "15N"
     )

run_file=tmp_run_$unt.txt
mkdir -p "../output/swot"

../src/Download_SWOT_Node_Data_Pass.py                                         \
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
#Done
#*****************************************************************************


#*****************************************************************************
#Fill in missing node xtrk distance values
#*****************************************************************************
echo "- Filling missing xtrk distance values"
run_file=tmp_run_$unt.txt

for ((i = 0; i < ${#utm[@]}; i++)); do

    echo $i
    
    ../src/SWOT_Xtrk_Fill.py                                                   \
        ../output/swot/swot_nodes_2023-07-01to2024-10-19.csv                   \
        ../input/swot_orbit/swot_science_hr_2.0s_4.0s_Aug2021-v5_nadir.shp     \
        ../output/sword/nodes/target_nodes_utm${utm[i]}.shp                    \
        ../input/utm_zones/missouri_utm${utm[i]}.shp                           \
        ${utm[i]}                                                              \
        > $run_file
    x=$? && if [ $x -gt 0 ] ; then echo "Failed run: $run_file" >&2 ; exit $x ; fi
    
done

rm -f $run_file
echo "Success"
echo "********************"
fi
#*****************************************************************************
#Done
#*****************************************************************************
