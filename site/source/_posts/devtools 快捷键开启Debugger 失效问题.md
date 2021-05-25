---
title: Fix devtools 快捷键开启Debugger 失效问题
date: 2021-05-25 23:33:50
tags: [前端, debug]
keywords: [前端, debug]
---

# devtools 快捷键开启 Debugger 失效问题

> 前端有很多情况需要调试一些元素的 hover 效果,或者 active、popover 等一些会马上消失的状态的场景,但是可能那个状态需要你一直 hover 的时候才会存在,所以需要想办法在 hover 的时候,将页面 freeze 住,再去审查元素,调整样式

如下图 ,这样一个场景,需要调试一下 google 的搜索输入框 active 的阴影效果

![](/static/notion/devtools_debuger_hotkey_cant_work/20210525122011.jpg)

按照平时的逻辑 ,我会选择 `cmd + \` 去起一个 debuger,然后去审查元素调试,但是今天快捷键无效

**究其原因是 devtools 面板上的 sources 开着文件,把所有 sourses 下的 tab 全部关掉就可以重新使用快捷键起一个 debuger 了**

---

学习文章:[https://mp.weixin.qq.com/s/uYd72aUb9wvUcjICFLREgg](https://mp.weixin.qq.com/s/uYd72aUb9wvUcjICFLREgg)

> 感谢阅读,勘误、纠错或其他请联系progerchai@gmail.com,或者[点击这里](https://github.com/progerchai/progerchai.github.io/issues/new)提 issue 给我
> 欢迎交流 👏,你的每一次指导都可以让我进步
