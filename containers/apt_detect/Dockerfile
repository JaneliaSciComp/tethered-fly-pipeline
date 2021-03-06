FROM ubuntu:18.04

LABEL org.opencontainers.image.licenses="BSD-3-Clause"

RUN apt-get -y update

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

ENV DOWNLOAD_CONDA_URL=https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh

ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

# Install miniconda
RUN wget ${DOWNLOAD_CONDA_URL} -O miniconda-install.sh && \
    bash miniconda-install.sh -b -p /miniconda && \
    rm miniconda-install.sh

ENV PATH=/miniconda/bin:${PATH}

# Install conda packages
RUN conda config --set always_yes yes --set changeps1 no && \
    conda update -q conda && \
    conda install python=3.7

RUN conda install -c conda-forge opencv=3.4.4

RUN conda install -c conda-forge \
        imageio=2.5.0 \
        scikit-image=0.15.0 \
        matplotlib=3.0.3 \
        future=0.17.1 \
        easydict=1.9

RUN conda install -c conda-forge \
    tensorflow=1.15 \
    tensorflow-gpu=1.15

RUN conda install -c conda-forge \
    keras=2.2.4 \
    keras-gpu=2.2.4

RUN pip install --upgrade pip && \
    pip install \
        opencv-python \
        hdf5storage==0.1.18

# Checkout and build the code
WORKDIR /code/apt
RUN git clone --branch stephen_working --depth 1 https://github.com/kristinbranson/APT.git .

COPY scripts/python/*.py deepnet
