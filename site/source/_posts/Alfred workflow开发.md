---
title: Alfred workflow 自定义开发
date: 2024-03-20 20:07:49
tags: [Alfred, workflow]
keywords: [Alfred, workflow]
---


# Alfred 翻译workflow开发

> 目的： alfred 作为工作的一个无敌提效工具 ，有很多现成的workflow供大家使用，但是总有无人涉及的地方，或者有某些自定义比较强的需求。此处通过0-1开发一个中(英)译英(中)的需求，带大家走进alfred 的workflow开发
> 

> 需求重述：开发一个alfred workflow ，通过命令`f 测试` 来执行百度翻译开放接口，输出结果`test` 并复制到系统剪切板（英译中同理）
> 

# 1.申请个人翻译账号

笔者用的是百度翻译，申请了一个个人账号，其他平台均可，能调api服务就可以

官方地址： [https://fanyi-api.baidu.com/product/11](https://fanyi-api.baidu.com/product/11)

![Untitled](/static/notion/alfred/Untitled.png)

![Untitled](/static/notion/alfred/Untitled%201.png)

完成注册和认证之后 ，可以在开发者信息中看到个人的APP ID和密钥，后面会用到

接入文档：[https://fanyi-api.baidu.com/product/113](https://fanyi-api.baidu.com/product/113)

![Untitled](/static/notion/alfred/Untitled%202.png)

# 2.workflow开发

接口准备就绪，可以去创建 Alfred 的workflow 了

创建空workflow，并填写好名称描述等信息

![Untitled](/static/notion/alfred/Untitled%203.png)

![Untitled](/static/notion/alfred/Untitled%204.png)

保存后，在空白处右键-inputs-Script Filter 选择创建一个空白Filter

![Untitled](/static/notion/alfred/Untitled%205.png)

![Untitled](/static/notion/alfred/Untitled%206.png)

配置环境变量 APP_ID、KEY,在代码中可直接获取到注入的环境变量，位置编辑配置→Environment Variables→ add

![Untitled](/static/notion/alfred/Untitled%207.png)

![Untitled](/static/notion/alfred/Untitled%208.png)

```bash
# 脚本中的使用
appid=${APP_ID}
key=${KEY}
```

将结果输出到剪切板，因为Alfred 需要输出特殊的格式数据，才能显示到工具上

具体Alfred 输出格式可参考： [https://www.alfredapp.com/help/workflows/inputs/script-filter/json/](https://www.alfredapp.com/help/workflows/inputs/script-filter/json/)

不同的language有不同的输出方式，此处演示的是bash场景输出

```bash
cat << EOB
{"items": [
  {
    "title": "翻译结果: $result",
    "subtitle": "$subtitletext",
    "arg": "$result"
  }
]}
EOB
```

完整代码可参考如下： 

```bash
#/**
# * @author progerchai@qq.com
# * @description : 业务中echo 会直接将值作为参数返给alfred ，但是alfred 只接受JSON格式，会报错：
# * JSON text did not start with array or object and option to allow fragments not set.
# * 实际使用请去除echo 语句
# */

appid=${APP_ID}
key=${KEY}
# salt 随机数
salt=1
#content = appid+q+salt+密钥
content="${appid}{query}${salt}${key}"
# echo "sign before md5 ===> ${content}"
# md5加密得到sign
sign=$(echo -n "$content" | md5)

url="https://fanyi-api.baidu.com/api/trans/vip/translate?q={query}&from=zh&to=en&appid=${appid}&salt=${salt}&sign=${sign}"
# echo "请求地址 ===> ${url}"
value=$(curl --location $url)

result=$(echo "$value" | jq -r '.trans_result[0].dst')

#echo "请求结果 ===> ${value}"
#echo "解析结果trans_result[0].dst ===> ${result}"

subtitletext='Press enter to paste or ⌘C to copy'

if [ -z $result ]
  then
  result='n/a'
fi

cat << EOB
{"items": [
  {
    "title": "翻译结果: $result",
    "subtitle": "$subtitletext",
    "arg": "$result"
  }
]}
EOB

```

处理curl 接口返回值时，因为返回的是json数据， 所以需要借助三方工具来处理 ，本身bash 并不具备json的处理能力。可以安装jq，安装方法如下： 

```bash
# 本地需要内置jq ，其他系统环境请自行搜索哈～
# 无法安装可加sudo
# mac
brew install jq

# Linux
yum -y install jq
```

到此保存，workflow完成～

上面演示的是中译英，英译中同理，只需修改一下curl 参数即可

一起来体验一下吧

中译英

![Untitled](/static/notion/alfred/Untitled%209.png)

英译中

![Untitled](/static/notion/alfred/Untitled%2010.png)

---

tips: 开发过程中，可以在Alfred 开启调试

![Untitled](/static/notion/alfred/Untitled%2011.png)


---

> 感谢阅读,勘误、纠错或其他请联系progerchai@gmail.com,或者[点击这里](https://github.com/progerchai/progerchai.github.io/issues/new)提 issue 给我
> 欢迎交流 👏,你的每一次指导都可以让我进步
