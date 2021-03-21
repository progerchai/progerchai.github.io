FROM ubuntu

LABEL maintainer "progerchai@gmial.com"

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update \
    && apt-get install nodejs npm tzdata -y --no-install-recommends

RUN TZ=Asia/Shanghai \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone 

# 设置 /app 为工作区
WORKDIR /app

COPY package.json .
RUN npm install
# 将当前项目拷贝到镜像中的 /app 文件中
COPY . .

# 执行命令
RUN npm run build
# 执行运行命令
# CMD ["npm","run","server"]

# VOLUME [ "/www/wwwroot/www.progerchai.cn/progerchai.github.io/site/public" ]
# 也可用一下方法把项目/app/public 挂载到外卖到只从路径site/public中
# docker run -d -v /www/wwwroot/www.progerchai.cn/progerchai.github.io/site/public:/app/public2 progerchai/blog:0.2 bash -c 'cp -r /app/public /app/public2'