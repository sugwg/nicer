# syntax=docker/dockerfile:1

# FROM debian:stretch
FROM debian:bullseye-slim

LABEL maintainer="Anaconda, Inc"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

SHELL ["/bin/bash","-c"]

WORKDIR /root

RUN apt-get update && \
    apt-get install -y \
    unzip \
    wget \
    make \
    cmake \
    build-essential \
    git \
    ssh \
    vim \
    libblas3 \
    libblas-dev \
    liblapack3 \
    liblapack-dev \
    libatlas3-base \
    libatlas-base-dev \
    openmpi-bin \
    libopenmpi-dev \
    gfortran

RUN useradd xpsiUser -m

WORKDIR /home/xpsiUser
COPY . .
RUN chown -R xpsiUser: /home/xpsiUser/v0.7.5
USER xpsiUser

# RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
# RUN bash Miniconda3-latest-Linux-x86_64.sh -b -p /home/xpsiUser/miniconda
# RUN rm Miniconda3-latest-Linux-x86_64.sh
# ENV PATH=$PATH:/home/xpsiUser/miniconda/condabin:/home/xpsiUser/miniconda/bin
# RUN conda init && exec bash

RUN mkdir nicer && \
    git clone https://github.com/ThomasEdwardRiley/xpsi.git nicer/ && \
    cd nicer/xpsi && \
    git checkout v0.7.5 && \
    conda env create -f environment.yml; exit 0

# WORKDIR /home/xpsiUser/nicer

# RUN conda env create -f environment.yml; exit 0

# WORKDIR /home/xpsiUser
SHELL ["/bin/bash","-c"]
RUN conda init && \
    echo 'conda activate xpsi' >> ~/.bashrc

USER root
SHELL [ "conda", "run", "-n", "xpsi", "/bin/bash", "-c" ]
RUN python -m ipykernel install --name xpsi --display-name "XPSI Notebook"
USER xpsiUser
WORKDIR /home/xpsiUser

# RUN echo 'conda activate xpsi' >> ~/.bashrc

WORKDIR /home/xpsiUser/nicer
RUN pip install GetDist==0.3.1 \
    nestcheck==0.2.0 \
    fgivenx
# RUN pip install nestcheck==0.2.0
# RUN pip install fgivenx

RUN git clone https://github.com/farhanferoz/MultiNest.git && \
    cd MultiNest/ && \
    git checkout a2b1b5feb5 && \
    cd /home/xpsiUser/nicer/MultiNest/MultiNest_v3.11_CMake/multinest/ && \
    mkdir build && \
    cd build && \
    CC=gcc FC=mpif90 CXX=g++ cmake -DCMAKE_{C,CXX}_FLAGS="-O3 -march=native -funroll-loops" -DCMAKE_Fortran_FLAGS="-O3 -march=native -funroll-loops" .. && \
    make
# WORKDIR /home/xpsiUser/nicer/MultiNest/MultiNest_v3.11_CMake/multinest/
# RUN mkdir build
# RUN cd build && CC=gcc FC=mpif90 CXX=g++ cmake -DCMAKE_{C,CXX}_FLAGS="-O3 -march=native -funroll-loops" -DCMAKE_Fortran_FLAGS="-O3 -march=native -funroll-loops" .. && make
ENV LD_LIBRARY_PATH=/home/xpsiUser/nicer/MultiNest/MultiNest_v3.11_CMake/multinest/lib:$LD_LIBRARY_PATH

# WORKDIR /home/xpsiUser/nicer
RUN git clone https://github.com/JohannesBuchner/PyMultiNest.git && \
    cd PyMultiNest/ && \
    python setup.py install

RUN conda install scipy -y && \
    conda install matplotlib -y && \
    pip install wrapt

USER root
RUN wget -v http://mirror.koddos.net/gnu/gsl/gsl-latest.tar.gz && \
    tar -xvf gsl-latest.tar.gz && \
    rm gsl-latest.tar.gz && \
    cd /home/xpsiUser/nicer/gsl-2.7 && \
    ./configure CC=/usr/bin/gcc && \
    make && \
    make check && \
    make install && \
    make installcheck && \
    make clean

# WORKDIR /home/xpsiUser/nicer/gsl-2.7
# RUN ./configure CC=/usr/bin/gcc
# RUN make && make check && make install && make installcheck && make clean
ENV PATH=/usr/local/bin:$PATH
USER xpsiUser


# WORKDIR /home/xpsiUser/nicer
RUN CC=/usr/bin/gcc python setup.py install

WORKDIR /home/xpsiUser/