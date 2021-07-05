---
title: 用IntersectionObserver实现吸顶效果
date: 2021-06-29 00:31:50
tags: [前端, 性能, React]
keywords: [前端, 性能, React]
---

# 用 IntersectionObserver 实现吸顶效果

> 开发中，需要实现一个二级工具菜单栏吸顶灯的效果

效果如下图 1，框选住的部分会在滚动的时候吸附顶部，在下滑的过程中，回到原来的位置时，又恢复 static 的效果，如图 2

![](/static/notion/IntersectionObserver/Untitled.png)

![](/static/notion/IntersectionObserver/Untitled%201.png)

# 思路

## 方案一 : position:sticky

本来第一个想到的时使用 css 的 position:sticky，达到吸附的效果，但是实践的时候发现，如果恢复到图 2 的状态，这个二级菜单元素层级会非常深，所以中间各层元素很难去控制 overflow 属性，而在 overflow:hidden 的时候，position:sticky 是无法生效的

## 方案二 : js 监听 scroll 事件

这里通过 js 监听 scroll 事件，然后判断元素距离顶部的偏移量，我这个场景下顶部一级菜单高度是 60px,所以如果二级菜单顶部距离页面整体可视区域<60px 的时候，修改二级菜单 position 为 fixed，相反>60px 的时候，则修改为 static ，让二级菜单回到文档流中。其中用到了 Dom 的 getBoundingClientRect 的方法，获得元素各个尺寸数据

代码如下：

```jsx
scroll = () => {
  // anchorWrapper 是
  let anchorWrapper = document.getElementById('anchorWrapper');
  // isFix 判断是否需要吸附
  const isFix = anchorWrapper.getBoundingClientRect().top < 60;
  // anchor 为二级菜单
  let anchor = document.getElementById('anchor');
  if (isFix && anchor) {
    anchor.style.position = 'fixed';
  } else if (!isFix && anchor) {
    anchor.style.position = 'static';
  }
};

// 注册scroll 监听
window.addEventListener('scroll', this.scroll);

// xxxx 其他代码..

{
  /*anchorWrapper 用来包裹二级菜单，设置高度占位防止anchor fixed 的时候脱离文档流导致高度塌缩*/
}
<div style={{ height: 48 }} id={'anchorWrapper'}>
  {/*anchor 是二级菜单*/}
  <div className={styles.anchor} id={'anchor'}>
    <span>课程介绍</span>
    <span>课程章节</span>
  </div>
</div>;
```

但是这个方法也不够优雅 ，有三点理由，1. 滚动的时候会一直通过 getBoundingClientRect 去获取元素距离顶部的距离，导致页面不断重排，过重的渲染会影响整体性能。如果通过节流的方式对滚动函数做包装，则会导致页面无法准确抓取边界值，导致吸附反应迟钝，如下图所示

![](/static/notion/IntersectionObserver/demo1.gif)

## 方案三 : IntersectionObserver

> MDN:[https://developer.mozilla.org/zh-CN/docs/Web/API/Intersection_Observer_API](https://developer.mozilla.org/zh-CN/docs/Web/API/Intersection_Observer_API)

IntersectionObserver 的作用是一个元素的相交检测，例如元素滚出/滚回页面可视区，这个就是我们想要的效果，赞 👍

接下来，修改原有的代码：

```jsx
componentDidMount() {
    if (IntersectionObserver) {
      this.observer = new IntersectionObserver(function () {
        let anchorWrapper = document.getElementById('anchorWrapper')
        const isFix = anchorWrapper.getBoundingClientRect().top < 60
        let anchor = document.getElementById('anchor')
        if (isFix && anchor) {
          anchor.style.position = 'fixed'
        } else if (!isFix && anchor) {
          anchor.style.position = 'static'
        }
      }, {
        threshold: [0, 0.99, 1], // tips: 0.99 的目的是检测超出屏幕一点点立即往回滚的情况
        rootMargin: '-60px 0px', // 60px，目的是声明顶部有个60px的距离需要减掉
      })
      this.observer.observe(document.getElementById('anchorWrapper'))
    }
  }

componentWillUnmount() {
// 组件卸载记得取消监听
    this.observer && this.observer.disconnect()
}
```

这里需要注意的两点是，关于 IntersectionObserver 第二个参数`threshold` 和`rootMargin` 的使用，代码中有注释申明

完成效果：

![](/static/notion/IntersectionObserver/finish.gif)

> 注意，虽然大部分浏览器都兼容了 IntersectionObserver，但是还有有些刺头没有这个 api ，所以需要自己考量一下是否写两套来适应没有 IntersectionObserver 的情况

## 各浏览器适配图

![](/static/notion/IntersectionObserver/can_i_use_IntersectionObserver.jpg)

---

> 感谢阅读,勘误、纠错或其他请联系progerchai@gmail.com,或者[点击这里](https://github.com/progerchai/progerchai.github.io/issues/new)提 issue 给我
> 欢迎交流 👏,你的每一次指导都可以让我进步
