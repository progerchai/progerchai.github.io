---
title: Fix:Taro与taro-ui版本不匹配问题
date: 2021-06-13 02:33:10
tags: [前端, Taro, 小程序]
keywords: [前端, Taro, 小程序]
---

# Taro 与 taro-ui 版本不匹配导致的问题

相关报错：`Module build failed (from ./node_modules/babel-loader/lib/index.js)` 以及
`Module not found: Error: Can't resolve './style/index.scss' in '/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/taro-ui/dist/weapp'`

```bash
Tips: 预览模式生成的文件较大，设置 NODE_ENV 为 production 可以开启压缩。
Example:
$ NODE_ENV=production taro build --type weapp --watch

生成  工具配置  /Users/aiyouwei/Documents/proger/projects/OneBox/frontend/dist/project.config.json

编译  发现入口  src/app.tsx
编译  发现页面  src/pages/index/index.tsx
🙅   编译失败. 6/13/2021, 2:14:15 AM

./node_modules/taro-ui/dist/weapp/components/input-number/index.tsx
Module build failed (from ./node_modules/babel-loader/lib/index.js):
SyntaxError: /Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/taro-ui/dist/weapp/components/input-number/index.tsx: Unexpected token, expected ")" (94:21)

  92 |       })
  93 |     }
> 94 |     if (resultValue! < min!) {
     |                      ^
  95 |       resultValue = min
  96 |       this.handleError({
  97 |         type: 'LOW',


监听文件修改中...

./node_modules/taro-ui/dist/weapp/components/input-number/index.tsx
Module build failed (from ./node_modules/babel-loader/lib/index.js):
SyntaxError: /Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/taro-ui/dist/weapp/components/input-number/index.tsx: Unexpected token, expected ")" (94:21)

  92 |       })
  93 |     }
> 94 |     if (resultValue! < min!) {
     |                      ^
  95 |       resultValue = min
  96 |       this.handleError({
  97 |         type: 'LOW',
 at Object._raise (/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/@babel/parser/src/parser/error.js:134:45)
    at Object.raiseWithData (/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/@babel/parser/src/parser/error.js:129:17)
    at Object.raise (/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/@babel/parser/src/parser/error.js:78:17)
    at Object.unexpected (/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/@babel/parser/src/parser/util.js:179:16)
    at Object.expect (/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/@babel/parser/src/parser/util.js:144:28)
    at Object.parseHeaderExpression (/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/@babel/parser/src/parser/statement.js:521:10)
    at Object.parseIfStatement (/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/@babel/parser/src/parser/statement.js:648:22)
    at Object.parseStatementContent (/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/@babel/parser/src/parser/statement.js:273:21)
    at Object.parseStatementContent (/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/@babel/parser/src/plugins/typescript/index.js:2311:20)
    at Object.parseStatement (/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/@babel/parser/src/parser/statement.js:229:17)
    at Object.parseBlockOrModuleBlockBody (/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/@babel/parser/src/parser/statement.js:961:25)
    at Object.parseBlockBody (/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/@babel/parser/src/parser/statement.js:937:10)
    at Object.parseBlock (/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/@babel/parser/src/parser/statement.js:907:10)
    at Object.parseFunctionBody (/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/@babel/parser/src/parser/expression.js:2158:24)
    at Object.parseArrowExpression (/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/@babel/parser/src/parser/expression.js:2108:10)
    at Object.parseParenAndDistinguishExpression (/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/@babel/parser/src/parser/expression.js:1509:12)
 @ ./node_modules/taro-ui/dist/weapp/index.ts 23:0-69 23:0-69
 @ ./node_modules/taro-ui/dist/index.js
 @ ./node_modules/babel-loader/lib!./src/pages/index/index.tsx
 @ ./src/pages/index/index.tsx,./node_modules/taro-ui/dist/weapp/index.ts
Module not found: Error: Can't resolve './style/index.scss' in '/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/taro-ui/dist/weapp'
resolve './style/index.scss' in '/Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/taro-ui/dist/weapp'
  using description file: /Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/taro-ui/package.json (relative path: ./dist/weapp)
    using description file: /Users/aiyouwei/Documents/proger/projects/OneBox/frontend/node_modules/taro-ui/package.json (relative path: ./dist/weapp/style/index.scss)


```

错误情况版本为`Taro v3.2.10`和`taro-ui v2.3.4`

解决办法： taro 版本与 taro-ui 没有对应，`taro 3.0+` 需要安装 `taro-ui 3.0+`

issue 地址: [https://github.com/NervJS/taro-ui/issues/960#issuecomment-697442481](https://github.com/NervJS/taro-ui/issues/960#issuecomment-697442481)

---

> 感谢阅读,勘误、纠错或其他请联系progerchai@gmail.com,或者[点击这里](https://github.com/progerchai/progerchai.github.io/issues/new)提 issue 给我
> 欢迎交流 👏,你的每一次指导都可以让我进步
