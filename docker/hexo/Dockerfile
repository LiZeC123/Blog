FROM node:14.17-alpine

ENV TZ Asia/Shanghai

RUN apk update && \
    apk add --no-cache tzdata && \
    npm install hexo-cli -g

CMD [ "sh", "-c", "cd /app && npm install && hexo g" ]