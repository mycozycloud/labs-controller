FROM ubuntu

RUN echo 'deb http://archive.ubuntu.com/ubuntu precise main universe' >> /etc/apt/sources.list
RUN apt-get -y update
RUN apt-get -y install git-core python python-dev libxslt1-dev python-pip libxml2-dev

RUN git clone https://github.com/mycozycloud/cozy-data-indexer /usr/cozy/indexer

WORKDIR /usr/cozy/indexer

# WTF is virtualenv ?

RUN pip install virtualenv; \
 virtualenv virtualenv; \
 . virtualenv/bin/activate; \
 pip install -r requirements/common.txt;

EXPOSE 9102

ENTRYPOINT ["/usr/cozy/indexer/virtualenv/bin/python", "/usr/cozy/indexer/server.py"]