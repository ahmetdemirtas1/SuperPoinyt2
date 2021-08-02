FROM nvidia/cuda:11.2.2-cudnn8-devel

FROM continuumio/miniconda3

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends \
    python3-dev \
    python3-pip \
    python3-wheel \
    python3-setuptools && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

RUN pip3 install --no-cache-dir -U install setuptools pip
RUN pip3 install --no-cache-dir "cupy-cuda112[all]==10.0.0a2"

RUN apt-get -y update
RUN apt-get -y install git

RUN git clone --recurse-submodules https://github.com/loicland/superpoint_graph

# RUN pip install torchnet

RUN conda install -c anaconda boost
RUN conda install -c omnia eigen3
RUN conda install eigen
RUN conda install -c r libiconv

COPY requirements.txt .
RUN pip install -r requirements.txt

WORKDIR /superpoint_graph/partition/cut-pursuit
RUN conda info
RUN apt-get -y install build-essential
RUN apt-get -y install software-properties-common
RUN apt-get -y install cmake
RUN apt-get install libssl-dev libffi-dev
RUN apt-get -y install libxml2-dev libxslt-dev
RUN python --version
ENV CONDAENV=/opt/conda
WORKDIR /superpoint_graph/partition/ply_c
ENV CPLUS_INCLUDE_PATH="/opt/conda/include/python3.8"
RUN cmake . -DPYTHON_LIBRARY=$CONDAENV/lib/libpython3.8.so -DPYTHON_INCLUDE_DIR=$CONDAENV/include/python3.8 -DBOOST_INCLUDEDIR=$CONDAENV/include -DEIGEN3_INCLUDE_DIR=$CONDAENV/include/eigen3
WORKDIR /superpoint_graph/partition/ply_c
RUN make
WORKDIR /superpoint_graph/partition/cut-pursuit
RUN mkdir build
WORKDIR /superpoint_graph/partition/cut-pursuit/build
RUN cmake .. -DPYTHON_LIBRARY=$CONDAENV/lib/libpython3.8.so -DPYTHON_INCLUDE_DIR=$CONDAENV/include/python3.8 -DBOOST_INCLUDEDIR=$CONDAENV/include -DEIGEN3_INCLUDE_DIR=$CONDAENV/include/eigen3
RUN make
