# set base image (host OS)
# Base image chosen based on info in https://pythonspeed.com/articles/base-image-python-docker-images/
FROM python:3.9-slim-bullseye

# install dependencies
RUN apt-get update \
  && apt-get install -y git
RUN pip install --upgrade pip

# set the working directory in the container
WORKDIR /opt/sodasql

# Copy entrypoint.sh which will become the main entrypoint
COPY ./entrypoint.sh /

# command to run on container start
ENTRYPOINT [ "/entrypoint.sh" ]