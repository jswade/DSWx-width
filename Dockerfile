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
# Base OS
#*******************************************************************************
FROM debian:12.7-slim


#*******************************************************************************
# Set working directory & copy source
#*******************************************************************************
WORKDIR /home/dswx-width/
COPY . .


#*******************************************************************************
# Install OS dependencies
#*******************************************************************************
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        $(grep -v -E '(^#|^$)' requirements_cd.apt) \
        python3-venv python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


#*******************************************************************************
# Set up Python virtual environment and install dependencies
#*******************************************************************************
ENV VENV_PATH="/venv"
ENV PATH="${VENV_PATH}/bin:$PATH"

RUN python3 -m venv $VENV_PATH && \
    $VENV_PATH/bin/pip install --upgrade pip && \
    $VENV_PATH/bin/pip install --no-cache-dir -r requirements.pip


#*******************************************************************************
# Default shell
#*******************************************************************************
CMD ["/bin/bash"]


#*******************************************************************************
#End
#*******************************************************************************
