FROM ubuntu

RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' >> /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get -y install wget git
RUN wget -O - http://nodejs.org/dist/v0.8.26/node-v0.8.26-linux-x64.tar.gz | tar -C /usr/local/ --strip-components=1 -zxv

# TROUBLESHOOT : if unexpected EOF, run build with -q options (https://github.com/dotcloud/docker/issues/1292)
