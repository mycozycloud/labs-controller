FROM dockerfile/nodejs

RUN git clone https://github.com/mycozycloud/cozy-data-system /usr/cozy/datasystem
RUN cd /usr/cozy/datasystem; npm install --production

#CMD ["npm", "start", "/usr/cozy/datasystem"]
EXPOSE 9101
CMD cd /usr/cozy/datasystem/; HOST=0.0.0.0 COUCH_HOST=$COUCH_PORT_5984_TCP_ADDR COUCH_PORT=$COUCH_PORT_5984_TCP_PORT npm start