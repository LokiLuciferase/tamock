FROM ubuntu:focal

LABEL maintainer="Lukas Lueftinger (lukas.lueftinger@ares-genetics.com)"
LABEL description="Targeted mock communities"

SHELL ["/bin/bash", "-c"]
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH="/opt/micromamba/bin:$PATH"
ENV MAMBA_ROOT_PREFIX=/opt/micromamba/
ENV MICROMAMBA_VERSION=0.17.0

ARG DEBIAN_FRONTEND=noninteractive

COPY . /opt/tamock
RUN apt-get update --fix-missing \
    && apt-get install -y ca-certificates make libssl-dev wget libgsl-dev \
    && apt-get clean
RUN wget -qO- https://micromamba.snakepit.net/api/micromamba/linux-64/$MICROMAMBA_VERSION | tar -xvj bin/micromamba \
    && cd / \
    && micromamba shell init -s bash -p /opt/micromamba \
    && . ~/.bashrc \
    && mkdir -p /opt/micromamba/envs \
    && micromamba install -p $MAMBA_ROOT_PREFIX python=3.6 wheel setuptools pip -c conda-forge \
    && micromamba install -p $MAMBA_ROOT_PREFIX centrifuge art -c bioconda -c conda-forge -c defaults \
    && /opt/tamock/tamock
CMD [ "/opt/tamock/tamock" ]
