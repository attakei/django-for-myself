FROM python:3.5-slim
MAINTAINER attakei

ARG deps="mysql-client"
ARG buildDeps="gcc libmysqlclient-dev"

# Install sudo
RUN set -x \
    && apt-get update \
    && apt-get install -y sudo --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*
# TODO: Install apt-utils ?

# Working user and directory
RUN groupadd -r -g 1000 service \
    && useradd -r -u 1000 -g service service \
    && echo "service ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && mkdir /app \
    && chown service:service /app \
    && mkdir /data \
    && chown service:service /data

# Install pip packages
ADD ./requirements.txt /tmp/requirements.txt
RUN set -x \
    && apt-get update \
    && apt-get install -y $deps $buildDeps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && pip install -r /tmp/requirements.txt \
    && apt-get purge -y --auto-remove $buildDeps

# Entry
USER service
WORKDIR /app
ONBUILD ADD ./ /app
ONBUILD RUN sudo chown service:service -R /app
