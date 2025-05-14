# DSWx-width
[![DOI](https://zenodo.org/badge/DOI/xxxxx)](https://doi.org/10.5281/zenodo.15391838)

[![License (3-Clause BSD)](https://img.shields.io/badge/license-BSD%203--Clause-yellow.svg)](https://github.com/jswade/DSWx-width/blob/main/LICENSE)

[![Docker Images](https://img.shields.io/badge/docker-images-blue?logo=docker)](https://hub.docker.com/r/jswade1/dswx-width)

[![GitHub CI Status](https://github.com/jswade/DSWx-width/actions/workflows/github_actions_CI.yml/badge.svg)](https://github.com/jswade/DSWx-width/actions/workflows/github_actions_CI.yml)

[![GitHub CD Status](https://github.com/jswade/DSWx-width/actions/workflows/github_actions_CD.yml/badge.svg)](https://github.com/jswade/DSWx-width/actions/workflows/github_actions_CD.yml)

DSWx-width is a collection of Python and bash shell scripts that ...

DSWx-width aims to:

1. Aggregate and prepare OPERA DSWx imagery for width computation.
2. Compute widths from the DSWx product using an automated workflow.
3. Provide comparisons between SWOT- and DSWx-derived widths in the Missouri River Basin.

The DSWx-width dataset is publicly available at https://zenodo.org/records/15391839.

## Shell Script Documentation
The shell scripts in the `/tst/` folder sequentially call Python scripts by providing
the required input files and pointing to the desired output locations.

**`tst_case_dwnl_Wade_etal_2025.sh`**  
This script is used to download testing data
from Zenodo for a limited region for automated testing on key functions in DSWx-width.

**`tst_case_repr_Wade_etal_2025.sh`**  
This script is used to perform individual computations and compare the results to expected outputs for automated testing of key functions in DSWx-width.

**`tst_pub_dwnl_all_Wade_etal_2025.sh`**  
This script is used to download all input data
to recreate the DSWx-width analysis in its entirety. If executed, this script will take 
and extremely long time to run, as it is downloading a large volume of SWOT and OPERA DSWx 
data.

**`tst_pub_repr_all_Wade_etal_2025.sh`**  
This script is used to recreate the outputs of 
the DSWx-width analysis in its entirety.

## Python Script Documentation  
The Python scripts in the `/src/` folder represent individual computational steps used to 
obtain river width measurements from OPERA DSWx imagery. Many of the Python scripts are 
run in loops by the `/tst/` scripts for each unique UTM zone to align with the 
projections of SWOT observations. Here, the scripts are listed in order of 
their use in the analysis.

**`OPERA_Dwnl.py`**  
Downloads OPERA DSWx CONF layers within target region between specified dates 
using NASA EarthAccess. 

  * Inputs:  
    * Shapefile of target region (`.shp`)  
    * Folder of SWORD node shapefiles for each UTM zone (`.shp`)  
    * Starting date of study period (`str`)  
    * Ending date of study period (`str`)  

  * Outputs:  
    * Output folder for downloaded OPERA DSWx CONF layers (`.tif`)  
    * File containing OPERA DSWx tile boundaries (`.kml`)  

&nbsp;  
  
**`Download_SWOT_Node_Data_Pass.py`**  
Downloads SWOT L2 HR River Single Pass observations for target nodes between
specified dates using NASA PODAAC's Hydrocron tool. 

  * Inputs:  
    * Folder of SWORD node shapefiles for each UTM zone (`.shp`)  
    * Starting date of study period (`str`)  
    * Ending date of study period (`str`)  
    * File containing SWOT orbital information (`.nc`)  

  * Outputs:  
    * Output folder for downloaded SWOT observations (`.csv`)  

&nbsp;  

**`SelectSWORDFeatures.py`**  
Selects SWORD nodes within target area, subdivided into separate shapefiles by their 
UTM zone.

  * Inputs:  
    * SWORD node file for given region (`.nc`)
    * Shapefiles delineating UTM zone boundaries (`.shp`)
    * Starting digits SWORD node ids for given region (7429 for Missouri River) (`str`)
    * Selected UTM zone (`str`)

  * Outputs:  
    * Target SWORD node file for given UTM zone (`.shp`)

&nbsp;  

**`CreateSWORDBuffers.py`**   
Generates extreme distance buffers surrounding SWORD nodes, delineating the maximum 
distance for pixel-to-node assignment.

  * Inputs:
    * Target SWORD node file for given UTM zone (`.shp`)

  * Outputs:**
    * Buffers for SWORD nodes for a given UTM zone (`.shp`)

&nbsp;  

**`CreateThiessenPolygons.py`**   
Generates Thiessen polygons surrounding SWORD nodes, delineating the zone of influence 
of each node for pixel-to-node assignment.

  * Inputs:  
    * Target SWORD node file for given UTM zone (`.shp`)
    * Buffers for SWORD nodes for a given UTM zone (`.shp`)

  * Outputs:  
    * Thiessen polygons for SWORD nodes for a given UTM zone (`.shp`)

&nbsp;  

**`ConfReclass_OPERA.py`**    
Reclassifies OPERA DSWx CONF pixel values to simpler WTR format (open water/partial 
water) for main river identification and width computation.

  * Inputs:  
    * Folder containing downloaded OPERA DSWx CONF layers (`.tif`)
    * Reclassification strategy ("cons" or "agg") (`str`)

  * Outputs:  
    * Output folder for reclassified DSWx layers (`.tif`)

&nbsp;  

**`TempAgg_OPERA.py`**   
Temporally aggregates reclassified DSWx layers over specified time window to remove 
influence of clouds.

  * Inputs
    * Folder containing reclassified DSWx layers (`.tif`)
    * Starting date of study period (`str`)
    * Ending date of study period (`str`)
    * Length of temporal aggregation window (`int`)

  * Outputs
    * Output folder for temporally aggregated DSWx layers (`.tif`)

&nbsp;  

**`UTM_Overlap_OPERA.py`**    
Identifies overlap of OPERA DSWx tiles with UTM zones for future tile merging.

  * Inputs
    * Folder containing temporally aggregated DSWx layers (`.tif`)
    * Folder containing shapefiles of UTM zones (`.shp`)

  * Outputs:
    * File listing the OPERA DSWx tile ids for each target UTM zone (`.csv`)

&nbsp;  

**`SpatialAgg_OPERA.py`**    
Spatially merges temporally aggregated OPERA DSWx layers for each aggregation
window and UTM zone.

  * Inputs:  
    * Folder containing temporally aggregated DSWx layers (`.tif`)
    * File listing the OPERA DSWx tile ids for each target UTM zone (`.csv`)
    * Selected UTM zone (`str`)

  * Outputs:  
    * Output folder for merged DSWx layers for each aggregation window and UTM Zone
(`.tif`)

&nbsp;  

**`Clump.py`**    
Clumps regions of DSWx pixels with the same value in preparation for main river identification.

  * Inputs:  
    * Folder containing merged DSWx layers (`.tif`)
    * Shapefile of node Thiessen polygons for a given UTM zone (`.shp`)
    * Selected UTM zone (`str`)

  * Outputs:  
    * Output folder for clumped DSWx rasters and shapefiles for each aggregation window and UTM Zone
(`.shp` and `.tif`)

&nbsp;  

**`CreatingMainRiver.py`**   
Identifies primary connected river channel from DSWx imagery, differentiated from disconnected 
open water in the proximal floodplain.

  * Inputs:  
    * Folder containing clumped DSWx layers (`.tif`)
    * Shapefile of node Thiessen polygons for a given UTM zone (`.shp`)
    * Shapefile of SWORD nodes for a given UTM zone (`.shp`)
    * Folder containing merged DSWx layers (`.tif`)
    * Selected UTM zone (`str`)

  * Outputs:  
    * Output folder for rasters identifying open water pixels belonging to main channel, 
reclassified rasters of pixel values for main channel, and rasters differentiating connected
and unconnected open and partial water pixels for each UTM zone (`.shp` and `.tif`)

&nbsp;  

**`PixelClassSummary.py`**   
Counts the number of DSWx pixels of each type corresponding to each target SWORD node 
for each temporal aggregation window.

  * Inputs:  
    * Folder containing DSWx main river rasters (`.tif`)
    * Shapefile of node Thiessen polygons for a given UTM zone (`.shp`)
    * Selected UTM zone (`str`)

  * Outputs:  
    * Output folder for files containing pixel counts corresponding to SWORD nodes
(`.csv`)

&nbsp;  

**`ThiessenWidthExtraction.py`**   
Converts pixels counts to river width measurements for each SWORD node and for each 
temporal aggregation window.

  * Inputs:  
    * Folder of files containing pixel counts corresponding to SWORD nodes (`.csv`)
    * Selected UTM zone (`str`)

  * Outputs:  
    * Output folder for files containing river widths corresponding to SWORD nodes (`.csv`)

&nbsp;  

**`WidthAggregation.py`**   
Combines river width files for each UTM zone and temporal aggregation to a single 
file for each time window.

  * Inputs:  
    * Folder of files containing pixel counts corresponding to SWORD nodes (`.csv`)
    * Selected UTM zone (`str`)

  * Outputs:  
    * Output folder for files containing river widths corresponding to SWORD nodes (`.csv`)

&nbsp;  

**`SWOT_Pixcvec_Decode.py`**   
Transforms SWOT PIXCVec point cloud observations from `.nc` to `.shp`.

  * Inputs:  
    * SWOT PIXCVec point cloud layer (`.nc`)
    * CRS EPSG of UTM zone (`str`)

  * Outputs:  
    * Output folder for files containing river widths corresponding to SWORD nodes (`.csv`)

&nbsp;  

**`SWOT_Pixcvec_Raster.py`**   
Converts SWOT PIXCVec point cloud shapefile to raster that matches the spatial resolution
of OPERA DSWx layers.

  * Inputs:  
    * SWOT PIXCVec point cloud shapefile (`.shp`)
    * Raster of DSWx main river corresponding to date of SWOT PIXCVec observation (`.tif`)

  * Outputs:  
    * Rasterized SWOT PIXCVec point cloud (`.tif`)

&nbsp;  

**`Raster_Diff.py`**   
Compares OPERA DSWx main river raster to SWOT PIXCVec raster to identify differences 
in water detection.

  * Inputs:  
    * SWOT PIXCVec point cloud raster (`.shp`)
    * Raster of DSWx main river corresponding to date of SWOT PIXCVec observation (`.tif`)

  * Outputs:  
    * Raster of difference between OPERA DSWx and SWOT PIXCVec (`.tif`)

&nbsp;  

**`Raster_Diff.py`**   
Compares OPERA DSWx main river raster to SWOT PIXCVec raster to identify differences 
in water detection.

  * Inputs:  
    * SWOT PIXCVec point cloud raster (`.shp`)
    * Raster of DSWx main river corresponding to date of SWOT PIXCVec observation (`.tif`)

  * Outputs:  
    * Raster of difference between OPERA DSWx and SWOT PIXCVec (`.tif`)

&nbsp;  

**`SWOT_Bitwise_Qual.py`**   
Decodes SWOT bitwise quality flags into more easily interpretable format for each 
observation.

  * Inputs:  
    * Downloaded SWOT L2 HR River Single Pass observations with bitwise quality flags (`.csv`)

  * Outputs:  
    * File containing SWOT decoded bitwise quality flags (`.csv`)

&nbsp;  

**`Node_Comp_Bitwise.py`**   
Filters SWOT observations using bitwise quality flags and compares SWOT width observations to 
coincident OPERA DSWx width observations.

  * Inputs:  
    * Downloaded SWOT L2 HR River Single Pass observations (`.csv`)
    * File of SWOT decoded bitwise quality flags (`.csv`)
    * File of OPERA DSWx observed widths (`.csv`)

  * Outputs:  
    * File containing paired SWOT-OPERA DSWx width observations (`.csv`)

&nbsp;  

**`Node_Comp_Metrics.py`**   
Aggregates SWOT-OPERA DSWx width comparisons to SWORD nodes to evaluate spatial 
agreement of width observations.

  * Inputs:  
    * File containing paired SWOT-OPERA DSWx width observations (`.csv`)
    * Folder of target SWORD nodes for each UTM zone (`.shp`)

  * Outputs:  
    * File containing SWOT-OPERA DSWx agreement stats at SWORD nodes (`.csv`)
    * File containing SWOT-OPERA DSWx agreement stats at SWORD nodes (`.shp`)

&nbsp;  

**`Node_Comp_Plots.py`**   
Produces visualizations of the agreement between SWOT and OPERA DSWx width measurements.

  * Inputs:  
    * File containing paired SWOT-OPERA DSWx width observations (`.csv`)

  * Outputs:  
    * Matplotlib Visualizations
    
&nbsp;  

## Installation with Docker
Installing DSWx-width is **by far the easiest with Docker**. This document was
written and tested using
[Docker Community Edition](https://www.docker.com/community-edition#/download)
which is available for free and can be installed on a wide variety of operating
systems. To install it, follow the instructions in the link provided above.

Note that the experienced users may find more up-to-date installation
instructions in
[Dockerfile](https://github.com/jswade/DSWx-width/blob/main/Dockerfile).

### Download DSWx-width
Downloading DSWx-width with Docker can be done using:

```
$ docker pull jswade1/DSWx-width
```

### Install packages
With Docker, there is **no need to install anymore packages**.
DSWx-width is ready to go! To run it, just use:

```
$ docker run --rm -it jswade1/DSWx-width
```

## Installation on Debian
This document was written and tested on a machine with a **clean** image of 
[Debian 11.7.0 ARM64](https://cdimage.debian.org/cdimage/archive/11.7.0/arm64/iso-cd/debian-11.7.0-arm64-netinst.iso)
installed, *i.e.* **no upgrade** was performed. 
Similar steps **may** be applicable for Ubuntu.

Note that the experienced users may find more up-to-date installation 
instructions in
[github\_actions\_CI.yml](https://github.com/jswade/DSWx-width/blob/main/.github/workflows/github_actions_CI.yml).

### Download DSWx-width
First, update package index files: 

```
$ sudo apt-get update
```

Then make sure that `ca-certificates` are installed: 

```
$ sudo apt-get install -y ca-certificates
```

Then make sure that `git` is installed: 

```
$ sudo apt-get install -y --no-install-recommends git
```

Then download DSWx-width:

```
$ git clone https://github.com/jswade/DSWx-width
```

Finally, enter the DSWx-width directory:

```
$ cd DSWx-width/
```

### Install APT packages
Software packages for the Advanced Packaging Tool (APT) are summarized in 
[requirements.apt](https://github.com/jswade/DSWx-width/blob/main/requirements.apt)
and can be installed with `apt-get`. All packages can be installed at once using:

```
$ sudo apt-get install -y --no-install-recommends $(grep -v -E '(^#|^$)' requirements.apt)
```

> Alternatively, one may install the APT packages listed in 
> [requirements.apt](https://github.com/jswade/DSWx-width/blob/main/requirements.apt)
> one by one, for example:
>
> ```
> $ sudo apt-get install -y --no-install-recommends python3.10
>```

Also make sure that `python3` points to `python3.10`:

```
$ sudo rm -f /usr/bin/python3
$ sudo ln -s /usr/bin/python3.10 /usr/bin/python3
```

### Install Python packages
Python packages from the Python Package Index (PyPI) are summarized in
[requirements.pip](https://github.com/jswade/DSWx-width/blob/main/requirements.pip)
and can be installed with `pip`. But first, let's make sure that the latest
version of `pip` is installed

```
$ wget https://bootstrap.pypa.io/pip/get-pip.py
$ sudo python3 get-pip.py --no-cache-dir `grep 'pip==' requirements.pip` `grep 'setuptools==' requirements.pip` `grep 'wheel==' requirements.pip`
$ rm get-pip.py
```

All packages can be installed at once using:

```
$ sudo pip3 install --no-cache-dir -r requirements.pip
```

> Alternatively, one may install the PyPI packages listed in 
> [requirements.pip](https://github.com/jswade/DSWx-width/blob/main/requirements.pip)
> one by one, for example:
>
> ```
> $ sudo pip3 install pandas==2.2.2
> ```
