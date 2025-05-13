# DSWx-width
[![DOI](https://zenodo.org/badge/DOI/xxxxx)](https://doi.org/xxxxx)

[![License (3-Clause BSD)](https://img.shields.io/badge/license-BSD%203--Clause-yellow.svg)](https://github.com/jswade/DSWx-width/blob/main/LICENSE)

[![Docker Images](https://img.shields.io/badge/docker-images-blue?logo=docker)](https://hub.docker.com/r/jswade1/xxxxx)

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
**Purpose:**  
The `tst_case_dwnl_Wade_etal_2025.sh` script is used to download testing data
from Zenodo for a limited region for automated testing on key functions in DSWx-width.

**`tst_case_repr_Wade_etal_2025.sh`**  
**Purpose:**  
The `tst_case_repr_Wade_etal_2025.sh` script is used to perform individual computations and compare the results to expected outputs for automated testing of key functions in DSWx-width.

**`tst_pub_dwnl_all_Wade_etal_2025.sh`**  
**Purpose:**  
The `tst_pub_dwnl_all_Wade_etal_2025.sh` script is used to download all input data
to recreate the DSWx-width analysis in its entirety. If executed, this script will take 
and extremely long time to run, as it is downloading a large volume of SWOT and OPERA DSWx 
data.

**`tst_pub_repr_all_Wade_etal_2025.sh`**  
**Purpose:**  
The `tst_pub_repr_all_Wade_etal_2025.sh` script is used to recreate the outputs of 
the DSWx-width analysis in its entirety.

## Python Scripts Documentation
The Python scripts in the `/src/` folder represent individual computational steps used to 
obtain river width measurements from OPERA DSWx imagery. Many of the Python scripts are 
run in loops by the `/tst/` scripts for each unique UTM zone to align with the 
projections of SWORD observations. Here, the scripts are listed in order of 
their use in the analysis.

**`SelectSWORDFeatures.py`**  
**Purpose:**  
Select SWORD nodes within target area, subdivided into separate shapefiles by their 
UTM zone.

**Inputs:**
- SWORD node file for given region (.nc)
- Shapefiles delineating UTM zone boundaries (.shp)
- Starting digits SWORD node ids for given region (7429 for Missouri River) (str)
- Selected UTM zone (str)

**Outputs:**
- Target SWORD node file for given UTM zone (.shp)

**`CreateSWORDBuffers.py`**  
**Purpose:**  
Generate extreme distance buffers surrounding SWORD nodes, delineating the maximum 
distance for pixel-to-node assignment.

**Inputs:**
- Target SWORD node file for given UTM zone (.shp)

**Outputs:**
- Buffers for SWORD nodes for a given UTM zone (.shp)

**`CreateThiessenPolygons.py`**  
**Purpose:**  
Generate Thiessen polygons surrounding SWORD nodes, delineating the zone of influence 
of each node for pixel-to-node assignment.

**Inputs:**
- Target SWORD node file for given UTM zone (.shp)
- Buffers for SWORD nodes for a given UTM zone (.shp)

**Outputs:**
- Thiessen polygons for SWORD nodes for a given UTM zone (.shp)

**`ConfReclass_OPERA.py`**  
**Purpose:**  
Reclassify OPERA DSWx CONF pixel values to simpler WTR format (open water/partial 
water) for main river identification and width computation.

**Inputs:**
- Folder containing downloaded OPERA DSWx CONF layers (folder of .tif)
- Reclassification strategy ("cons" or "agg") (str)

**Outputs:**
- Output folder for reclassified DSWx layers (folder of .tif)

**`TempAgg_OPERA.py`**  
**Purpose:**  
Temporally aggregate reclassified DSWx layers over specified time window to remove 
influence of clouds.

**Inputs:**
- Folder containing reclassified DSWx layers (folder of .tif)
- Starting date of study period (str)
- Ending date of study period (str)
- Length of temporal aggregation window (int)

**Outputs:**
- Output folder for temporally aggregated DSWx layers (folder of .tif)

**`UTM_Overlap_OPERA.py`**  
**Purpose:**  
Identify overlap of OPERA DSWx tiles with UTM zones for future tile merging.

**Inputs:**
- Folder containing temporally aggregated DSWx layers (folder of .tif)
- Folder containing shapefiles of UTM zones (folder of .shp)

**Outputs:**
- File listing the OPERA DSWx tile ids for each target UTM zone (.csv)

**`SpatialAgg_OPERA.py`**  
**Purpose:**  
Identify overlap of OPERA DSWx tiles with UTM zones for future tile merging.

**Inputs:**
- Folder containing temporally aggregated DSWx layers (folder of .tif)
- Folder containing shapefiles of UTM zones (folder of .shp)

**Outputs:**
- File listing the OPERA DSWx tile ids for each target UTM zone (.csv)




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
