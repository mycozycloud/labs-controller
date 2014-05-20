FROM nodejs

RUN git clone https://github.com/mycozycloud/cozy-data-system /usr/cozy/datasystem
RUN npm install /usr/cozy/datasystem --production

CMD ["npm", "start"]