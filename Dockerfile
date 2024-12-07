FROM node:18-alpine as builder
RUN mkdir /app
WORKDIR /app
COPY . /app
RUN npm i -g npm && npm ci --ignore-scripts && npm run build

FROM node:18-alpine
LABEL maintainer="https://github.com/zgq354/weibo-rss"
RUN mkdir /app
WORKDIR /app

# container init
RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 && \
    echo "057ecd4ac1d3c3be31f82fc0848bf77b1326a975b4f8423fe31607205a0fe945  /usr/local/bin/dumb-init" | sha256sum -c - && \
    chmod 755 /usr/local/bin/dumb-init

RUN npm install -g pnpm

# app code
COPY . /app
RUN pnpm i && pnpm build
RUN pnpm install pm2 -g

EXPOSE 3000
CMD ["pm2", "start", "process.json"]
