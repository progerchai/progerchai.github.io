---
title: http 缓存机制
date: 2021-04-11 23:33:50
tags: [前端, 缓存, 性能]
keywords: [前端, 缓存, 性能, http缓存机制]
---

# http 缓存机制

> 如果每次资源都要从服务器端获取,则会消费很多的时间,如果资源能在本地备份下来,下一次直接从本地获取会快很多

本篇我们分析一波 http 的缓存机制,并不包括数据变量之类的缓存,因为通常他们都会交给本地缓存(LocalStorage,SessionStorage,Cookie,IndexedDB 等)

http 缓存主要分两类:

- 强缓存
- 协商缓存(弱缓存)

以下一图概括了 http 缓存机制,具体是以下流程

1. 浏览器发送请求前，根据请求头的 expires 和 cache-control 判断是否命中（包括是否过期）强缓存策略，如果命中，直接从缓存获取资源，并不会发送请求。如果没有命中，则进入下一步。 2. 没有命中强缓存规则，浏览器会发送请求，根据请求头的 last-modified 和 etag 判断是否命中协商缓存，如果命中，直接从缓存获取资源。如果没有命中，则进入下一步。 3. 如果前两步都没有命中，则直接从服务端获取资源。

![一图理解http缓存机制](/static/notion/http缓存机制/Untitled.png)

### 强缓存

强缓存就是从本地直接获取资源,不走服务端

强缓存的数据存储路径有两种,分别是磁盘(disk)和内存(memery)

数据从 memery 中读取会稍快于从磁盘读取,但是数据缓存到 disk 上比较存放时间比较长久,而 memery 中到话关闭页面 tab 会被自动清除

好消息是,如何存储是由系统自己分配的,所以我们并不需要考虑他具体存到哪里,有一些小 tips 可以知道一下:

- 通常小文件会被缓存到 memery 中,大文件被存到 disk 中
- base64 图片通常不管你大小,都会被缓存到 memery 中
- 无痕状态,由于用户隐私问题,数据都会被存放到 memery 中

### 协商缓存

在强缓存失效之后,浏览器会携带缓存标识向服务器发起请求,由服务器根据缓存标识决定是否使用缓存,协商缓存有两种方式,分别是**ETag** 和 **Last-Modified**,他们都会有下面两类情况判断如何获取资源:

1. 如果服务端命中缓存,就会返回缓存资源,并返回 304 响应
2. 如果服务端也没有命中缓存,则从服务端重新加载获取资源

**ETag & If-None-Match**

Etag 优先级是高于下面的 Last-Modified 的,在两者都存在的情况下,以 Etag 为准

ETag 是一个响应首部字段，它是根据实体内容生成的一段 hash 字符串，标识资源的状态，由服务端产生。If-None-Match 是一个条件式的请求首部。如果请求资源时在请求首部加上这个字段，值为之前服务器端返回的资源上的 ETag，则当且仅当服务器上没有任何资源的 ETag 属性值与这个首部中列出的时候，服务器才会返回带有所请求资源实体的 200 响应，否则服务器会返回不带实体的 304 响应。

**Last-Modified & If-Modified-Since**

f-Modified-Since 是一个请求首部字段，并且只能用在 GET 或者 HEAD 请求中。Last-Modified 是一个响应首部字段，包含服务器认定的资源作出修改的日期及时间。当带着 If-Modified-Since 头访问服务器请求资源时，服务器会检查 Last-Modified，如果 Last-Modified 的时间早于或等于 If-Modified-Since 则会返回一个不带主体的 304 响应，否则将重新返回资源。

看完这些,再回过头去看上面的 http 缓存策略的图片,就能很清晰得看懂图片的含义了

---

学习文章:[https://mp.weixin.qq.com/s/uYd72aUb9wvUcjICFLREgg](https://mp.weixin.qq.com/s/uYd72aUb9wvUcjICFLREgg)

> 感谢阅读,勘误、纠错或其他请联系progerchai@gmail.com,或者[点击这里](https://github.com/progerchai/progerchai.github.io/issues/new)提 issue 给我
> 欢迎交流 👏,你的每一次指导都可以让我进步
