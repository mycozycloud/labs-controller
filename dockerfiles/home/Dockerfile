FROM dockerfile/nodejs

RUN git clone https://github.com/aenario/cozy-home -b docker /usr/cozy/home
RUN cd /usr/cozy/home; npm install --production

#CMD ["npm", "start", "/usr/cozy/home"]
EXPOSE 9103
CMD cd /usr/cozy/home/; HOST=0.0.0.0 DATASYSTEM_HOST=$DATASYSTEM_PORT_9101_TCP_ADDR DATASYSTEM_PORT=$DATASYSTEM_PORT_9101_TCP_PORT npm start