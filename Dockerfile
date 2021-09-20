FROM public.ecr.aws/ubuntu/ubuntu:latest

## Install environment for git, clang, python
RUN apt-get update; apt-get install git clang clang-tidy clang-format zlib1g-dev libssl-dev libcurl4-openssl-dev wget \
ninja-build python3-pip zip build-essential -y

## Download cmake
RUN wget -O cmake-install https://github.com/Kitware/CMake/releases/download/v3.16.0/cmake-3.16.0-Linux-x86_64.sh; \
sh cmake-install --skip-license --prefix=/usr --exclude-subdirectory;

RUN git --version

## Upgrade pip
RUN pip3 install --upgrade pip

## Turn of interface
ARG DEBIAN_FRONTEND=noninteractive

# Install opencv
RUN apt update
RUN apt install libopencv-dev -y

# Clone yolo v4
WORKDIR /app
RUN git clone https://github.com/AlexeyAB/darknet 
WORKDIR /app/darknet

# Build darknet
RUN sed -ie 's/VERSION 3.18/VERSION 3.16/g' CMakeLists.txt
RUN mkdir build_release
WORKDIR /app/darknet/build_release
RUN cmake -DENABLE_CUDA=OFF .. 
RUN cmake --build . --target install --parallel 8 

# Setup env
COPY . /app
WORKDIR /app

# RUN "./darknet/darknet detector test config/obj.data config/yolov4-tiny-17.cfg config/yolov4-tiny-17.weights -dont_show -ext_output ./demo.png -out result/result.json"
ENTRYPOINT [ "bash", "entrypoint.sh" ]
