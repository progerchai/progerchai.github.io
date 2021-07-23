---
title: 手绘地图实现
date: 2021-07-23 21:30:09
tags: [前端, Echarts]
keywords: [前端, Echarts]
---

# Echarts 手绘地图实现

> 业务中需要实现一个手绘地图，原计划是使用 Eva，但是时间有限，最后使用 Echarts 实现，实现效果如下。

![](/static/notion/echarts_0723/example.gif)

（动图太大了，尽可能压缩稍微有点糊，见谅～）

业务中，如上图所示，内部有很多的元素都需要有相应的事件，需要整个地图尽可能地解耦。并且内部有板块/图片/路线等元素。

那么接下来分析一下，这样一个页面有那些需要实现的内容

## 分析页面

- 底图

  底部有一层图片，没有交互，也没有位置的改变，是固定的。

  可以用 Echarts.graphic.image 来实现

  ![](/static/notion/echarts_0723/Untitled.png)

- 手绘板块

  这里主要示上图中显示的四个不同的板块，其中三块是有颜色的，第四块是星球最外侧的星空板块，并且是多边形的，如果单个板块需要实现一些特殊的交互，如何判别多边形边界区域？我使用了 Echarts 的 geomap 来实现。

  主要的做法就是，从 ui 那里拿到这几块板块的 svg 图，然后将整个图片转换成 geojson 数据（[**https://labs.mapbox.com/svg-to-geojson/**](https://labs.mapbox.com/svg-to-geojson/)），这个网址在调整完底部时间底图的大小比例后，将 svg 拖进去会自动将 svg 贴进去，并且可以在上面进行微调。然后下载可以得到一个 geojson 数据，那么这个 geojson 数据其实是相对于真实的世界地图来进行映射的，每一个点的数据都是真实的地图数据。

  如下图所示：

  ![](/static/notion/echarts_0723/Untitled%201.png)

  导出后可以得到结构一个 data.json,同时，原有的 svg 有颜色填充的部分也会被识别，并体现在 data.json 中。data.json 结构类似如下：

  ```bash
  {
    'type': 'FeatureCollection',
    'features': [
      {
        'id': '400cfbfc61a37cad9e5f7168fa913b4d',
        'type': 'Feature',
        'properties': {
          'id': 'Fill-8',
          'fill': '#efe0c4',
        },
        'geometry': {
          'coordinates': [
            [
  						[
                119.75217242139553,
                30.189759022525294,
              ],
              [
                119.75329376495,
                30.191341051272516,
              ],
            ]
          ]
        }]
  }
  ```

  其中 features 是个数组，其中每一项都是一个多边形。features.properties.id 用来识别每一个不同的多边形。features.properties.fill 是多边形的填充颜色，来自与原来的 svg 图片。

  我们可以使用这个导出的 geojson 数据，通过 registerMap 方法来进行注册，并在

  ```bash
  import { mapData } from './data'
  echarts.registerMap('LearningMap', mapData, {})

  geo: {
          map: 'LearningMap',
          roam: false,
          aspectScale: 0.8,
          zoom: 1.02, // 缩放微调
          center: [120.070048074111, 30.29092154350316], // 多边形位置微调
          data: [],
          nameMap: {},
          label: {
            show: debugGeoTitle,
          },
          itemStyle: {
            areaColor: '#FFFFFF',
          },
          z: 9,
          silent: true,
        },
  ```

- 路线

  通过上面的步骤，我们得到的 geojson 数据中，也有路线的多边形数据，这里我们可以通过 Echarts.series.lines,去绘制路线，并设置 coordinateSystem: 'geo' ，因为数据是从 geojson 中获取的，然后通过 lineStyle.type: [10, 10]的方式去实现虚线路线的效果

- 小图标

  小图标的话，只能使用图片的方式贴到对应的位置了，这里可以用 Echarts.scatters.effectScatter,相比较 scatter ，effectScatter 有更多的可操作性

- 定位点

  这个也就是 gif 中路线上的小白点，同样在 geojson 有定义多边形，所以基本上 geo.regions 来实现，代码如下：

  ```bash
  const regions = [
  {
          name: id,
          itemStyle: {
            areaColor: fill,
            borderWidth: 0,
            opacity: 1,
          },
          z: 10,
        }
  ]
  ```

  每个小白点的数据，都需要从 geojson 中拿出来，并解构成如上的结构放到 regions 数组中

- 人物 Marker

  gif 中，随着不同的学习进度，人物头像作为 Marker 会出现在不同的位置

  这部分，因为不同的用户头像是不一样的，所以我这里的方案是，将人物的头像，加上 Marker 的样式，一起转成一个图片，然后通过绘制图片的方式将头像 Marker 定位到特定的位置，其中有个 html2img 的操作，转成图像之后，后续操作也和 effectScatter 类似，而且可以做一些 hover 的样式区别

主要实现原理是根据最初导出的 geojson 里进行一系列操作

## 参考文档

Echarts 配置项：[https://echarts.apache.org/zh/option.html#title](https://echarts.apache.org/zh/option.html#title)

---

> 感谢阅读,勘误、纠错或其他请联系progerchai@gmail.com,或者[点击这里](https://github.com/progerchai/progerchai.github.io/issues/new)提 issue 给我
> 欢迎交流 👏,你的每一次指导都可以让我进步
