FROM node:12
RUN mkdir /app
WORKDIR /app
COPY package.json /app/
RUN ["npm", "install"]
CMD ["npm","start"]