FROM ubuntu:focal

ENV WS_DIR="/benchmark"
WORKDIR ${WS_DIR}

ARG DEBIAN_FRONTEND=noninteractive

# Dependencies for latency plot
RUN apt-get update \
 && apt-get install -y \
    build-essential \
    curl \
    gnuplot-qt \
    libnuma-dev \
    make \
    python3 \
    python3-distutils \
 && rm -rf /var/lib/apt/lists/*

# Dependencies for Bash unit-tests
RUN apt-get update \
 && apt-get install -y \
    bats \
    dialog \
    tmux \
 && rm -rf /var/lib/apt/lists/*

# Cyclictest and mklatencyplot
RUN apt-get update \
 && apt-get install -y \
    rt-tests \
 && rm -rf /var/lib/apt/lists/* 

COPY ./scripts .
RUN chmod +x mklatencyplot.bash

CMD [ "bash", "/benchmark/mklatencyplot.bash" ]
