FROM python:3.5-slim
MAINTAINER Kazuya Takei<attakei@gmail.com>


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
ADD ./repos.yml /usr/lib/repos.yml

# Install django package
ARG django_version="1.9"
RUN pip-ext ver${django_version}

# Install option packages
ARG extra=""
RUN if [ "$extra" != "" ] ; then pip-ext ${extra} ; fi
    

# ONBUILD RUN pip-ext --repo /usr/lib/repos.yml
ONBUILD ADD ./ /app
ONBUILD RUN chown service:service -R /app
ONBUILD RUN if [ -f /app/requirements.txt ] ; then \
        pip -r requirements.txt \
    ; fi

# Default command is 'runserver'
# USER service
# ENTRYPOINT ["python3", "/app/manage.py"]
CMD ["pip", "freeze"]
