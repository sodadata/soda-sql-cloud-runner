# set base image (host OS)
# Base image chosen based on info in https://pythonspeed.com/articles/base-image-python-docker-images/
FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
  apt-get install -y --no-install-recommends \
  python3.9 pip git && \
  apt-get clean -qq -y && \
  apt-get autoclean -qq -y && \
  apt-get autoremove && \
  rm -rf /var/lib/apt/lists/*

# set the working directory in the container
WORKDIR /opt/sodasql

# Copy entrypoint.sh which will become the main entrypoint
COPY ./entrypoint.sh /

# command to run on container start
ENTRYPOINT [ "/entrypoint.sh" ]