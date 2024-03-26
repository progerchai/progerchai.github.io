---
title: html2canvas 和 html-to-image
date: 2024-03-26 20:51:50
tags: [前端, toPng, html2canvas, html-to-image]
keywords: [前端, toPng, html2canvas, html-to-image]
---

# html2canvas 和 html-to-image，及低版本浏览器中 html-to-image 的兼容问题处理

## 业务场景中两个方案对比效果

html-to-image.gif

![html-to-image.gif](/static/notion/toPng/1677911871741-705751ba-1261-44a0-9777-0f70ceca1a87.gif)

html2canvas.gif

明显可以看到点击的【预览手卡】之后，有一段时间的卡顿

![html2canvas.gif](/static/notion/toPng/1677912083028-997e46d1-8de7-4fd4-bcc8-7c7e8007e68e.gif)

|          | html-to-image                                      | html2canvas                              |
| -------- | -------------------------------------------------- | ---------------------------------------- |
| 包体积   | 5.01 kb                                            | 3.38 MB                                  |
| 工作原理 | svg                                                | canvas                                   |
| 缺陷     | 低版本兼容有问题                                   | <img>需要手动转为 base64，再传入         |
| 使用体验 | 转换速度足够快，但是低版本浏览器不支持 inner style | 低版本兼容性没问题，但是太重，转换速度慢 |

## html-to-image

1. 递归克隆、处理 dom 节点
2. 将 dom 转化为 svg
3. 将 svg 处理成图片画到 canvas
4. canvas => 图片

## 拿 html-to-image 中的 toPng 为例

> 一切的源头： [https://github.com/bubkoo/html-to-image/blob/b751cbf212ccc7909077bc105b0630f9c845389a/src/index.ts#L71](https://github.com/bubkoo/html-to-image/blob/b751cbf212ccc7909077bc105b0630f9c845389a/src/index.ts#L71)

1. 传递 node 节点和相关配置，返回 canvas

`const canvas = await toCanvas(node, options)`

```jsx
export async function toPng<T extends HTMLElement>(
  node: T,
  options: Options = {},
): Promise<string> {
  // ************ 关键代码 toCanvas  ********** //
  const canvas = await toCanvas(node, options)
  return canvas.toDataURL()
}
```

1. 调用 toSvg 方法，得到 svg，再绘制到 canvas 中，返回这个 canvas

`const svg = await toSvg(node, options)`

```jsx
export async function toCanvas<T extends HTMLElement>(
  node: T,
  options: Options = {},
): Promise<HTMLCanvasElement> {
  const { width, height } = getImageSize(node, options)
  // ************ 关键代码 toSvg  ********** //
  const svg = await toSvg(node, options)
  const img = await createImage(svg)

  const canvas = document.createElement('canvas')
  const context = canvas.getContext('2d')!
  const ratio = options.pixelRatio || getPixelRatio()
  const canvasWidth = options.canvasWidth || width
  const canvasHeight = options.canvasHeight || height

  canvas.width = canvasWidth * ratio
  canvas.height = canvasHeight * ratio

  if (!options.skipAutoScale) {
    checkCanvasDimensions(canvas)
  }
  canvas.style.width = `${canvasWidth}`
  canvas.style.height = `${canvasHeight}`

  if (options.backgroundColor) {
    context.fillStyle = options.backgroundColor
    context.fillRect(0, 0, canvas.width, canvas.height)
  }

  context.drawImage(img, 0, 0, canvas.width, canvas.height)

  return canvas
}
```

1. cloneNode => 一系列处理（如下）=> 得到 svg

```jsx
export async function toSvg<T extends HTMLElement>(
  node: T,
  options: Options = {},
): Promise<string> {
  const { width, height } = getImageSize(node, options)
// 遍历node，进行clone
  const clonedNode = (await cloneNode(node, options, true)) as HTMLElement
// 处理webfont
  await embedWebFonts(clonedNode, options)
// 处理图片，内部有resourceToDataURL 方法，通过fetch image url 的方式
// 得到图片的blob，再转成base64
  await embedImages(clonedNode, options)
// 应用style
  applyStyle(clonedNode, options)
// node 转为 svg
  const datauri = await nodeToDataURL(clonedNode, width, height)
  return datauri
}
```

## 问题： 为什么在低版本的浏览器中，html-to-image 的 inner style 会失效呢？

问题表现：toPng 之后，inline style 样式丢失

浏览器： chrome89 以下、搜狗浏览器

![正常样式](/static/notion/toPng/1678082459207-0bb6b0f5-696a-4c9b-980d-041543913d3f.jpg)

![低版本样式](/static/notion/toPng/1678082618049-510b3cc0-f1cc-40ae-8b6f-2135da9a46bc.jpg)

clone 源码进行调试看看

可以看到在低版本浏览器中，inner style 被转成了错误的格式，举例如下，在高版本中显示的是`style="color: #d35400"` （**P1**）但是低版本中被转换失败，变成了`style="color-scheme: ; scale: ; translate: ;"`

![](/static/notion/toPng/1677928000947-29e71f8e-ce8a-4cab-b615-3a659f3c30e5.png)

![](/static/notion/toPng/1677927919808-b3c38849-81dc-4f4b-b54a-364682730b59.png)

初步找到了原因，toSvg 执行的时候，传入的 node 就已经出问题了，继续往下挖 👇 加入一些打印，看看在哪一步处理 dom 出了问题

```jsx
export async function toSvg<T extends HTMLElement>(
  node: T,
  options: Options = {},
): Promise<string> {
  const { width, height } = getImageSize(node, options)
// eslint-disable-next-line no-console
  console.log(222222, 'origin', node)
  const clonedNode = (await cloneNode(node, options, true)) as HTMLElement
  // eslint-disable-next-line no-console
  console.log(222222, 'after clone', clonedNode)
  await embedWebFonts(clonedNode, options)
  // eslint-disable-next-line no-console
  console.log(222222, 'after embedWebFonts', clonedNode)
  await embedImages(clonedNode, options)
  // eslint-disable-next-line no-console
  console.log(222222, 'after embedImages', clonedNode)
  applyStyle(clonedNode, options)
  // eslint-disable-next-line no-console
  console.log(222222, 'after applyStyle', clonedNode)
  const datauri = await nodeToDataURL(clonedNode, width, height)
  return datauri
}
```

根据打印出来的结果，发现 after clone 之后，开始出现了错误，inline style 丢失，那么继续往 cloneNode 中深挖

![](/static/notion/toPng/1678000904837-0b98f3a4-d636-46e2-8656-cbb846947bf7.png)

```jsx
export async function cloneNode<T extends HTMLElement>(
  node: T,
  options: Options,
  isRoot?: boolean,
): Promise<T | null> {
  if (!isRoot && options.filter && !options.filter(node)) {
  return null
}

return Promise.resolve(node)
  .then((clonedNode) => {
    // *********** add console  *********** //
    // eslint-disable-next-line no-console
    console.log(
      'before cloneSingleNode',
      node,
      clonedNode,
      clonedNode?.style?.cssText,
    )
    return cloneSingleNode(clonedNode, options) as Promise<T>
      })
  .then((clonedNode) => {
    // *********** add console  *********** //
    // eslint-disable-next-line no-console
    console.log(
      'before cloneChildren',
      clonedNode,
      clonedNode?.style?.cssText,
    )
    return cloneChildren(node, clonedNode, options)
  })
  .then((clonedNode) => decorate(node, clonedNode))
  .then((clonedNode) => ensureSVGSymbols(clonedNode, options))
}
```

![](/static/notion/toPng/1678086572219-cf557c68-e20a-4402-b8c4-bbe161c09705.png)

观察到，在 clone 过程中，inline style 变成了`style="color-scheme: ; scale: ; translate: ;"`

但是通过`clonedNode.style.cssText` 是可以获取到正确的 inline Style 的

到此，问题似乎没法通过`html-to-image` 直接解决....

那么，联想到`html-to-image` 可以支持`<style>` 标签，是否手动将 inline style 抽离出来，并手动赋值一个 class 呢？

说干就干，通过以下两个方法对 dom 节点，先遍历处理一遍，class 通过 uuid 生成

```jsx
/**
 * 遍历node树，将所有的inline style 抽离出来，并为有inline style 的node 添加新的uuid class
 * 例如： <div style='color: red'></div>
 *             ==>
 * <div style='color: red' class='_ed87c1f9-0bbe-4afc-b2ee-3f15b4fd166f'></div>
 * ._ed87c1f9-0bbe-4afc-b2ee-3f15b4fd166f {color: red}
 * @param node 需要处理的node 节点
 * @returns string
 */
function handleChildrenInlineStyle<T extends HTMLElement>(node: T): string {
  const children = [...node.childNodes];
  return children.reduce((previousValue: string, currentNode: ChildNode) => {
    const cssText = _.get(currentNode, 'style.cssText', null);
    let uuid = '';
    if (cssText) {
      uuid = `_${uuidv4()}`; // _ 防止uuid 数字开头导致失效
      (currentNode as HTMLElement).classList.add(uuid);
      previousValue += `.${uuid}{${(currentNode as HTMLElement).style.cssText}}`;
    }
    const childStyle = handleChildrenInlineStyle(currentNode as T);

    return previousValue + childStyle;
  }, '');
}
/**
 * 通过handleChildrenInlineStyle，对node 进行处理，抽离出inline style ，变成class style
 * @param node
 * @returns HTMLElement
 */
export function handleChildren<T extends HTMLElement>(node: T): HTMLElement {
  const customStyle = document.createElement('style');
  const packInlineStyle = handleChildrenInlineStyle(node);
  customStyle.innerHTML = packInlineStyle;
  node.appendChild(customStyle);
  return node;
}

```

效果： 低版本功能正常

![正常样式](/static/notion/toPng/1678082459207-0bb6b0f5-696a-4c9b-980d-041543913d3f.jpg)

![低版本样式](/static/notion/toPng/1678082459207-0bb6b0f5-696a-4c9b-980d-041543913d3f.jpg)

其他考虑：

1. uuid 通过 vite 打包后，体积仅 0.59kb，但是查看了 yarn.lock 中，发现`@ali/video-tracker`中有依赖`uuid@^8`, 那么相当于项目本身就装了 uuid ，对最后的打包体积没有影响！

```bash
dist/assets/style-b1674573.css         202.45 kB │ gzip:    30.34 kB
dist/assets/uuid_vendor-cf522c50.js      1.14 kB │ gzip:     0.59 kB # uuid chunk
dist/assets/index-6b7d8afc.js          423.37 kB │ gzip:   135.41 kB
dist/assets/vendor-2ef5f73f.js       3,555.39 kB │ gzip: 1,059.69 kB
```

1. 是否可以通过用户升级浏览器版本来直接兼容？
2. chrome 需要升级到 89 及以上
3. 搜狗浏览器目前官方最新的 11 版本，内核是 chrome80，内测版 12.1beta 升级为 chrome94，可以升级到 12.1beta
4. 360 极速浏览器，最新版 21.0 使用 chrome95 内核
5. 客户浏览器分布

![](/static/notion/toPng/1678089497419-ebf915d5-bc70-4b22-8800-d21ac5973f63.png)

参考内容/工具：

1. html2canvas: [https://github.com/niklasvh/html2canvas](https://github.com/niklasvh/html2canvas)
2. html2canvas 库 options 配置：[https://html2canvas.hertzen.com/configuration](https://html2canvas.hertzen.com/configuration)
3. 网易云游戏-白嫖 pc 虚拟机 ： [https://cg.163.com/#/pc](https://cg.163.com/#/pc)

---

> 感谢阅读,勘误、纠错或其他请联系progerchai@gmail.com,或者[点击这里](https://github.com/progerchai/progerchai.github.io/issues/new)提 issue 给我
> 欢迎交流 👏,你的每一次指导都可以让我进步
