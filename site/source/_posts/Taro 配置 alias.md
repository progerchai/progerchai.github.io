---
title: Taro 配置 alias
date: 2021-06-12 23:33:10
tags: [前端, Taro, 小程序]
keywords: [前端, Taro, 小程序]
---

# Taro 配置 alias

> 为了在 Taro 项目中，配置目录别名，方便引用路径，减少了很多`../../`的输入

- 官方文档地址: [https://nervjs.github.io/taro/docs/config-detail/](https://nervjs.github.io/taro/docs/config-detail/) 不过讲解的不是很清楚

```jsx
// 正常相对路径引入
import A from '../../componnets/A';
import Utils from '../../utils';
import packageJson from '../../package.json';
import projectConfig from '../../project.config.json';
```

## **第一步**： 我们找到`config/index.js` 文件，修改 alias 配置，如果没有这项，直接加入进去就行，代码如下：

```jsx
import * as path from 'path'; //引入node的path模块

module.exports = {
  // ...
  alias: {
    '@/components': path.resolve(__dirname, '..', 'src/components'),
    '@/utils': path.resolve(__dirname, '..', 'src/utils'),
    '@/package': path.resolve(__dirname, '..', 'package.json'),
    '@/project': path.resolve(__dirname, '..', 'project.config.json'),
  },
};
```

> 注意 ⚠️：这里的 Taro 文档中没有解释 node 的 path 模块的导入，直接使用了

`path.resolve(__dirname, '..', 'src/components')`

解释一下的作用类似与`cd`，`resolve` 的作用是将后缀的地址进行处理并拼接，返回最后的路径

`__dirname` 的意思是当前目录，`..` 就是返回父级目录

## **举个例子:**

```jsx
var path = require('path'); //引入node的path模块

path.resolve('/foo/bar', './baz'); // returns '/foo/bar/baz'
path.resolve('/foo/bar', 'baz'); // returns '/foo/bar/baz'
path.resolve('/foo/bar', '/baz'); // returns '/baz'
path.resolve('/foo/bar', '../baz'); // returns '/foo/baz'
path.resolve('home', '/foo/bar', '../baz'); // returns '/foo/baz'
path.resolve('home', './foo/bar', '../baz'); // returns '/home/foo/baz'
path.resolve('home', 'foo/bar', '../baz'); // returns '/home/foo/baz'
path.resolve(__dirname, '..', './baz'); // returns `${'/当前目录'}../baz`
```

## **第二步:** 为了让编辑器（VS Code）不报错，并继续使用自动路径补全功能，需要在项目根目录下的`jsconfig.json` 或者 `tsconfig.json` 中配置`paths` ，形式如下：

```jsx
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/components/*": ["./src/components/*"],
      "@/utils/*": ["./src/utils/*"],
      "@/package": ["./package.json"],
      "@/project": ["./project.config.json"],
    }
  }
}
```

最终引入效果：

```jsx
// 添加了目录别名之后引入
import A from '@/components/A';
import Utils from '@/utils';
import packageJson from '@/package';
import projectConfig from '@/project';
```

---

> 感谢阅读,勘误、纠错或其他请联系progerchai@gmail.com,或者[点击这里](https://github.com/progerchai/progerchai.github.io/issues/new)提 issue 给我
> 欢迎交流 👏,你的每一次指导都可以让我进步
