# This Dockerfile installs the latest versions of most popular 
# programming languages in the field of bioinformatics

FROM ubuntu:20.04

MAINTAINER >> Serge Gotsuliak >> https://github.com/gotzmann 

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -yqq && apt-get -y upgrade 

RUN apt-get install -yqq \
    curl wget xz-utils mc htop time pandoc \
    software-properties-common build-essential libevent-dev 

# Ada 10
RUN apt-get install -yqq gnat-10

# Crystal 1.0
RUN curl -fsSL https://crystal-lang.org/install.sh | bash

# Cython 0.29
RUN add-apt-repository universe \
	&& apt-get update -yqq \
	&& apt-get install -yqq python2 python2-dev \
	&& curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py \
	&& python2 get-pip.py \
	&& pip install Cython

# D 1.20
RUN apt-get install -yqq ldc

# Free Pascal 3.0
RUN apt-get install -yqq fpc

# Go 1.16
ENV PATH "$PATH:/go/bin"
ENV GOPATH "/go/bin"
RUN wget https://golang.org/dl/go1.16.2.linux-amd64.tar.gz \
	&& tar -xzf go1.16.2.linux-amd64.tar.gz 

# Java 11
RUN apt-get install -yqq default-jre default-jdk

# GraalVM 21
ENV PATH "$PATH:/graalvm/bin"
RUN wget https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-21.0.0.2/graalvm-ce-java11-linux-amd64-21.0.0.2.tar.gz \
	&& tar -xzf graalvm-ce-java11-linux-amd64-21.0.0.2.tar.gz \
	&& ln -s graalvm-ce-java11-21.0.0.2 /graalvm \
	&& gu install native-image

# Julia 1.6
RUN wget https://julialang-s3.julialang.org/bin/linux/x64/1.6/julia-1.6.0-linux-x86_64.tar.gz \
	&& tar -xvzf julia-1.6.0-linux-x86_64.tar.gz \
	&& mv julia-1.6.0/ /opt/ \
	&& ln -s /opt/julia-1.6.0/bin/julia /usr/local/bin/julia

# Nim 1.4
ENV PATH "$PATH:/nim-1.4.4/bin"
RUN wget https://nim-lang.org/download/nim-1.4.4-linux_x64.tar.xz \
	&& tar -xpJf nim-1.4.4-linux_x64.tar.xz 

# Node.js 15
RUN curl -sL https://deb.nodesource.com/setup_15.x -o nodesource_setup.sh \
	&& bash nodesource_setup.sh \
	&& apt-get install -yqq nodejs

# Perl 5
RUN apt-get install -yqq perl

# PHP 8 
RUN add-apt-repository ppa:ondrej/php \
	&& apt-get update -yqq \
	&& apt-get install -yqq php8.0 php8.0-cli

# Python 2.7
RUN apt-get install -yqq python

# PyPy 2.7
RUN wget https://downloads.python.org/pypy/pypy2.7-v7.3.3-linux64.tar.bz2 \
	&& tar xf pypy2.7-v7.3.3-linux64.tar.bz2 \
	&& ln -s /pypy2.7-v7.3.3-linux64/bin/pypy /usr/local/bin/pypy

# Rust 1.47
RUN apt-get install -yqq rustc \
	&& curl https://sh.rustup.rs -sSf | RUSTUP_INIT_SKIP_PATH_CHECK=yes sh -s -- -y

WORKDIR /benchmarks
COPY . .

CMD ["make"]