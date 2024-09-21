FROM ubuntu:24.04

ARG TARGETPLATFORM

LABEL org.opencontainers.image.licenses="BSD-3-Clause"

RUN apt -y update

RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y tzdata

RUN apt-get -y install \
    git wget unzip \
    ffmpeg x264 x265 \
    libavcodec-dev libavformat-dev \
    libjpeg-dev libpng-dev libtiff-dev libv4l-dev

RUN apt-get -y install \
    libswscale-dev \
    tcl-dev tk-dev \
    libatlas-base-dev gfortran \
    libgtk2.0-dev

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

# Install miniconda
RUN wget https://github.com/conda-forge/miniforge/releases/download/23.3.1-1/Mambaforge-23.3.1-1-Linux-$(uname -m).sh \
    -O mamba-install.sh && \
    bash mamba-install.sh -b -p /miniconda

ENV PATH=/miniconda/bin:${PATH}

# Install conda packages
RUN mamba config --set always_yes yes --set changeps1 no \
 && mamba install python=3.7

RUN mamba install -c conda-forge \
        pip \
        future \
        easydict=1.9 \
        numpy=1.21.6 \
        keras=2.2.4

# these 2 packages require anaconda channel
# tensorflow=1.14 is available on conda-forge but the corresponding tensorflow-gpu isn't
RUN mamba install -c anaconda \
        tensorflow=1.15 \
        tensorflow-gpu=1.15

RUN pip install \
        scikit-image==0.18.3 \
        matplotlib==3.0.3 \
        opencv-python \
        hdf5storage==0.1.18

RUN mamba install -c conda-forge \
        hdf5=1.10.5 \
        h5py=2.9.0

# Checkout and build the code
WORKDIR /code/apt
RUN git clone --branch stephen_working --depth 1 https://github.com/kristinbranson/APT.git .

COPY scripts/python/*.py deepnet
