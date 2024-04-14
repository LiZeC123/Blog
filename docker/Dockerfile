FROM node:18.17-alpine as build-stage

ENV TZ Asia/Shanghai

RUN apk update && \
    apk add --no-cache tzdata && \
    npm install hexo-cli -g

COPY package.json package-lock.json /app/

WORKDIR /app

RUN npm install

COPY . /app/

RUN hexo g


# ====================


FROM nginx:1.21.1-alpine as production-stage

WORKDIR /usr/share/nginx/html

COPY  --from=build-stage /app/public /usr/share/nginx/html