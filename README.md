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
### `tst_case_dwnl_Wade_etal_2025.sh`
### Purpose
The `tst_case_dwnl_Wade_etal_2025.sh` script is used to download testing data
from Zenodo for a limited region for automated testing on key functions in DSWx-width.

### `tst_case_repr_Wade_etal_2025.sh`
The `tst_case_repr_Wade_etal_2025.sh` script is used to perform individual computations and compare the results to expected outputs for automated testing of key functions in DSWx-width.

### `tst_pub_dwnl_all_Wade_etal_2025.sh`

### `tst_pub_repr_all_Wade_etal_2025.sh`


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
$ sudo ln -s /usr/bin/python3.9 /usr/bin/python3
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
