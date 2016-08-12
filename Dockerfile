FROM python:3.5-slim
ARG deps="sudo mysql-client"
ARG buildDeps="gcc libmysqlclient-dev"
ARG user=service
ARG appDir=/app
ARG dataDir=/data

# Install pip packages
ADD ./requirements.txt /tmp/requirements.txt
RUN set -x \
    && apt-get update \
    && apt-get install -y $deps $buildDeps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && pip install -r /tmp/requirements.txt \
    && apt-get purge -y --auto-remove $buildDeps

# Working user and directory
RUN groupadd -r -g 1000 $user \
    && useradd -r -u 1000 -g $user $user \
    && echo "$user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
    && mkdir $appDir \
    && chown $user:$user $appDir \
    && mkdir $dataDir \
    && chown $user:$user $dataDir

# Entry
USER $user
WORKDIR $appDir
ONBUILD ADD ./ $appDir
RUN sudo chown -R $user:$user .
