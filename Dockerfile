FROM python:3.5-slim
MAINTAINER attakei

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

# Packaging tools
RUN pip install PyYAML
ADD ./pip-ext /usr/bin/pip-ext
ADD ./repos.yml /tmp/repos.yml

# Install pip packages
RUN pip-ext --repo /tmp/repos.yml --all


# Entry
USER service
WORKDIR /app
ONBUILD ADD ./ /app
ONBUILD RUN sudo chown service:service -R /app

# Default command is 'runserver'
CMD ./manage.py runserver
