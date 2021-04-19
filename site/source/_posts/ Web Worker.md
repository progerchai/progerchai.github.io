---
title: Web Worker
date: 2021-04-19 00:01:50
tags: [前端, 性能, 线程, javascript, React]
keywords: [前端, 性能, 线程, javascript, React]
---

# Web Worker

> 最近开发中,测试提出了一个 BUG,在获取验证码的时候,有倒计时效果,如下图所示,但是在切换到其他页面的时候,长时间不回来的话,倒计时效果可能会暂停,回到页面才会继续进行.所以笔者针对这个问题进行了一些探索,最终使用`Web Worker`来解决问题,并稍加延展

![](/static/notion/Web%20Worker/Untitled.png)

## 问题所在

先弄清楚问题的原因在哪里,我找了一波代码,发现代码中这个简单的倒计时是通过`setInterval`的方式来实现的,每计时`1s`会进行`-1`操作

因为浏览器的优化原因，`setTimeout`和`setInterval`，在浏览器窗口非激活的状态下会停止工作或者以极慢的速度工作。

对浏览器来说,如果计时`1s`相对来说时间比较长,所以相同对问题比较难复现.我们可以采用`100ms`的时间间隔,设置了计时器不停地打印之后,激活其他的浏览器 tab,过一段时间可以发现计时器中间有一段暂停

```jsx
let interval = setInterval(() => {
  console.log('timer');
}, 100);
```

![](/static/notion/Web%20Worker/Untitled%201.png)

中间其实切到其他的 tab 长达 10s,但是打印的数量明显不对,所以存在上述问题

## 解决办法

那么,如果我们不希望切换 tab 的时候,旧页面的计时器停止 🤚,该怎么做呢?

这里有两种方式:

1. 点击时`setCookie`,记录当前点击的时间,每次执行的时候,优先获取`cookie`中的时间进行自我校准(可以配合`document.visibilityState`判断页面状态)
2. 通过`Web Worker`的方式,将当前任务新开线程去执行,从而避开 tab 切换时的限制

## 什么是 Web Worker

本文主要想讲的是`Web Worker` ,所以方法 1 不再赘述

`Web Worker`为 Web 内容在后台线程中运行脚本提供了一种简单的方法。线程可以执行任务而不干扰用户界面。此外，他们可以使用`XMLHttpRequest`执行`I/O` (尽管`responseXML`和 channel 属性总是为空)。一旦创建， 一个`worker` 可以将消息发送到创建它的 JavaScript 代码, 通过将消息发布到该代码指定的事件处理程序（反之亦然）

参考地址:[https://developer.mozilla.org/zh-CN/docs/Web/API/Web_Workers_API/Using_web_workers](https://developer.mozilla.org/zh-CN/docs/Web/API/Web_Workers_API/Using_web_workers)

## 使用实践

具体 api 内容可以查看上述链接,以下以当前倒计时作为案例,来进行分享

以`React`为例,直接上代码先:

`webworker.js`

```jsx
export default class WebWorker {
  constructor(worker) {
    const code = worker.toString();
    const blob = new Blob(['(' + code + ')()']);
    return new Worker(URL.createObjectURL(blob));
  }
}
```

`index.js`

```jsx
import WebWorker from '@utils/webworker'

// 中间代码省略..

// didmount 初始化worker
componentDidMount() {
// 新建worker
	this.worker = new WebWorker(() => {
      self.onmessage = function (e) {
        // 计时器用时间戳起名，防止与其他worker相互覆盖
        let count = e.data
        let intervalId = Date.parse(new Date())
        self[intervalId] = setInterval(() => {
          count -= 1
          if (count <= 0) {
						// 养成即时清理计时器的习惯
            clearInterval(self[intervalId])
            // 计时器完整完成任务之后,通过close方法将自己关闭,腾出内存空间
            self.close()
          }
          postMessage(count)
        }, 1000)
      }
    })
// 建立通信
  this.worker.onmessage = (res) => {
// 记得使用`()=>`箭头函数的方式,比较好方便调用this进行操作
    this.setState({ count: res.data })
  }
}

componentWillUnmount() {
// 当前组件销毁的时候,外部通过terminate方法清除worker,腾出内存空间
    this.worker.terminate()
}
```

以上可以完成我们的需求,确保即使切换 tab,任务也会持续进行

实验效果如下:

这里我通过两种方式,同时间隔`100ms`来进行从`1000开始-1倒计时`,中途切换到其他 tab,之后再次返回时,发现两者打印值已经不同,很明显 interval 的方式被浏览器阻塞了,`Web worker`效果很成果

![](/static/notion/Web%20Worker/Untitled%202.png)

![](/static/notion/Web%20Worker/Untitled%203.png)

那么我们进行延展一下,这个功能同样可以适用在一些我们不希望因为切换 tab 导致的任务停止,且可能需要短时间内进行大量操作的功能

或者是短时间内需要大量操作的时候,可以通过 Web Worker 这种比较 hack 的方式,将任务放到 worker 线程去执行,这样就不会阻塞程序的主线程,导致页面卡顿

---

> 感谢阅读,勘误、纠错或其他请联系progerchai@gmail.com,或者[点击这里](https://github.com/progerchai/progerchai.github.io/issues/new)提 issue 给我
> 欢迎交流 👏,你的每一次指导都可以让我进步
