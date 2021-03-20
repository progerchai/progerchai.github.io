FROM ubuntu

LABEL maintainer "progerchai@gmial.com"

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update \
    && apt-get install nodejs npm -y --no-install-recommends tzdata

RUN TZ=Asia/Shanghai \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && dpkg-reconfigure -f noninteractive tzdata 

# 设置 /app 为工作区
WORKDIR /app

# 将当前项目拷贝到镜像中的 /app 文件中
COPY . /app

# 执行命令
RUN npm install \
    && npm run build \
    && npm run server

# 执行运行命令
# CMD ["yarn","start"]

# 暴露出 3000 端口
EXPOSE 3000
