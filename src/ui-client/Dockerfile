FROM nginx:latest
RUN apt update
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash
RUN apt install -y nodejs
RUN npm install -g typescript@latest
RUN mkdir /code
COPY . /code
RUN cd /code && find . && npm install && npm run build

RUN mkdir /app
RUN cp -R /code/build/* /app/

COPY ./nginx.conf /etc/nginx/nginx.conf
