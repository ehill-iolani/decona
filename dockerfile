# Set the base image to Ubuntu 20.04 LTS
FROM ubuntu:20.04

# My authorship
LABEL maintainer="ehill@iolani.org"
LABEL version="1.0.0"
LABEL description="decona_plus for the Iolani School"

# Disable prompts during package installation
ENV DEBIAN_FRONTEND noninteractive

# Convenience packages
RUN apt update
RUN apt upgrade -y
RUN apt install -y curl git g++ zlib1g-dev make bsdmainutils gawk libopenblas-base wget nano libssl-dev pip

# Conda/Mamba installation
RUN cd tmp
RUN curl https://repo.anaconda.com/miniconda/Miniconda3-py310_23.3.1-0-Linux-x86_64.sh --output miniconda.sh
RUN bash miniconda.sh -bu
ENV PATH="/root/miniconda3/bin:$PATH"
RUN conda update -y conda
RUN conda install -y -c conda-forge mamba

# Install base decona
RUN mkdir /home/github

COPY . /home/github/decona

RUN cd /home/github/decona && \
    sed -i -e "s/\r$//" /home/github/decona/install/install.sh

RUN bash /home/github/decona/install/install.sh
SHELL ["mamba", "run", "-n", "decona", "/bin/bash", "-c"]

# Install additional dependencies
RUN mamba init && \
    mamba install -y -c bioconda blast=2.11.0 && \
    mamba install -y pandas=1.4.1 && \
    mamba install -y -c bioconda -c conda-forge bcftools=1.11 samtools=1.19.2 && \
    pip install medaka pyabpoa && \
    echo "mamba activate decona" >> ~/.bashrc && \
    mkdir /home/data

# Clean up installation
RUN rm miniconda.sh

# Set entrypoint
ENTRYPOINT ["/bin/bash"]