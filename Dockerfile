#*******************************************************************************
#Dockerfile
#*******************************************************************************

#Purpose:
#This file describes the operating system prerequisites for DSWx-width, and is
#used by the Docker software.
#Author:
#Cedric H. David, Jeffrey Wade, 2025


#*******************************************************************************
#Usage
#*******************************************************************************
#docker build -t dswx-width:myimage -f Dockerfile .             #Create image
#docker run --rm --name dswx-width_mycontainer     \
#           -it dswx-width:myimage                      #Run image in container
#docker run --rm --name dswx-width_mycontainer     \
#           -v $PWD/input:/home/dswx-width/input   \
#           -v $PWD/output:/home/dswx-width/output \
#           -it dswx-width:myimage                         #Run and map volumes
#docker save -o dswx-width_myimage.tar dswx-width:myimage #Save copy of image
#docker load -i dswx-width_myimage.tar                     #Load saved image


#*******************************************************************************
#Operating System
#*******************************************************************************
FROM python:3.10-slim


#*******************************************************************************
#Copy files into Docker image (this ignores the files listed in .dockerignore)
#*******************************************************************************
WORKDIR /home/dswx-width/
COPY . .


#*******************************************************************************
#Operating System Requirements
#*******************************************************************************
RUN  apt-get update && \
     apt-get install -y --no-install-recommends $(grep -v -E '(^#|^$)' requirements_cd.apt) && \
     rm -rf /var/lib/apt/lists/*


#*******************************************************************************
#Python requirements
#*******************************************************************************
ADD https://bootstrap.pypa.io/pip/get-pip.py .
RUN python3 get-pip.py --no-cache-dir \
    `grep 'pip==' requirements.pip` \
    `grep 'setuptools==' requirements.pip` \
    `grep 'wheel==' requirements.pip` && \
    rm get-pip.py

RUN pip3 install --no-cache-dir -r requirements.pip


#*******************************************************************************
#Intended (default) command at execution of image (not used during build)
#*******************************************************************************
CMD  /bin/bash


#*******************************************************************************
#End
#*******************************************************************************
