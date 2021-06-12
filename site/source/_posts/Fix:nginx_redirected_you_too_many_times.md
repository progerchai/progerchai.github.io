---
title: Fix Nginx redirected you too many times
date: 2021-04-13 23:21:54
tags: [Nginx, Fix, 运维]
keywords: [Nginx, 运维]
---

# Fix Nginx redirected you too many times

## 问题:

配置自己的服务器的时候,因为每次输入`www.proger.cn` 来访问比较麻烦,但是直接输入 `proger.cn` 又无法访问,所以在 `nginx` 上配置了一个重定向

源码里是这样写的

```bash
    server {
            listen 80 default_server;
            # listen [::]:80 default_server;

            return 301 https://proger.cn$request_uri;  # 这段代码301重定向

            # SSL configuration
            #
            listen 443 ssl;
            server_name www.proger.cn;
    }
```

但是访问的时候,网址发现如下问题

![](/static/notion/nginx_redirected_you_too_many_times/20210413233033.jpg)

## 解决方法:

修改代码为

```bash
    server {
            listen 80 default_server;
            # listen [::]:80 default_server;
            if ($http_x_forwarded_proto = "http") {  # 加一层判断
                return 301 https://proger.cn$request_uri;  # 这段代码301重定向
            }
            # SSL configuration
            #
            listen 443 ssl;
            server_name www.proger.cn;
    }
```

over~👏

---

学习文章:[https://mp.weixin.qq.com/s/uYd72aUb9wvUcjICFLREgg](https://mp.weixin.qq.com/s/uYd72aUb9wvUcjICFLREgg)

> 感谢阅读,勘误、纠错或其他请联系progerchai@gmail.com,或者[点击这里](https://github.com/progerchai/progerchai.github.io/issues/new)提 issue 给我
> 欢迎交流 👏,你的每一次指导都可以让我进步
