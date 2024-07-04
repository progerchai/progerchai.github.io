---
title: macOS wechat聊天记录导出
date: 2024-03-27 21:57:49
tags: [macOS, wechat, 词云图, python, jieba, pandas]
keywords: [macOS, wechat, 词云图, python, jieba, pandas]
---

# macOS 导出微信聊天记录

突然想到希望拿到微信的聊天记录，并制作词云图，看看平时微信消息说的最多的是什么

> 原文参考： [https://zhuanlan.zhihu.com/p/409662291](https://zhuanlan.zhihu.com/p/409662291)

---

以下单纯记录过程步骤：

# 获取微信聊天记录

## **聊天记录位置**

首先我们要知道，mac 微信的聊天记录都以数据库的形式保存在下面目录：

> Containers 直接在文件夹中不可见，找不到不要慌，建议直接 terminal cd 访问

`~/Library/Containers/com.tencent.xinWeChat/Data/Library/Application\ Support/com.tencent.xinWeChat/xxx/yyy/Message/*.db`

所以我们只需要拿到这个目录下的所有形如`msg_0.db`的数据库文件即可，但是都是加密的，所以我们要想办法拿到它们的密码。

## **破解密码并打开数据库**

1. 打开 mac 微信，但是不要登录。
2. 打开终端，输入`sudo lldb -p $(pgrep WeChat)`。这时候可能会报错：error: attach failed: cannot attach to process due to System Integrity。不要慌，重启 mac 电脑，黑屏后一直按住`Command+R`，直到出现恢复模式界面。点击顶部 Utilities 菜单，然后打开终端。最后输入`csrutil disable; reboot`等待重启，重新执行开始的命令就行了。
3. 进入 lldb 的子 shell 后，输入`br set -n sqlite3_key`，回车。
4. 输入`c`，回车。
5. 这时候会弹出微信登录界面，登陆就行了。登陆后可能会卡住，进不去微信，但不用管，继续下面的操作。
6. 继续在 lldb 的子 shell 中输入`memory read --size 1 --format x --count 32 $rsi`，这时会输出类似如下信息：

```bash
0x000000000000: 0xab 0xcd 0xef 0xab 0xcd 0xef 0xab 0xcd
0x000000000008: 0xab 0xcd 0xef 0xab 0xcd 0xef 0xab 0xcd
0x000000000010: 0xab 0xcd 0xef 0xab 0xcd 0xef 0xab 0xcd
0x000000000018: 0xab 0xcd 0xef 0xab 0xcd 0xef 0xab 0xcd
```

1. 用 python 处理上面的输出信息：

```bash
source = """
0x000000000000: 0xab 0xcd 0xef 0xab 0xcd 0xef 0xab 0xcd
0x000000000008: 0xab 0xcd 0xef 0xab 0xcd 0xef 0xab 0xcd
0x000000000010: 0xab 0xcd 0xef 0xab 0xcd 0xef 0xab 0xcd
0x000000000018: 0xab 0xcd 0xef 0xab 0xcd 0xef 0xab 0xcd
"""
key = '0x' + ''.join(i.partition(':')[2].replace('0x', '').replace(' ', '') for i in source.split('\n')[1:5])
print(key)

# 输出为：0xabcdefabcdefabcdabcdefabcdefabcdabcdefabcdefabcdabcdefabcdefabcd
```

1. 此时的输出就是数据库的密码`raw_key`，一定要记住。 8. 下载打开数据库的软件 DB Browser for SQLite，地址：`https://sqlitebrowser.org/dl/`
2. 打开软件，打开数据库，选择上一小节中提到的形如`msg_0.db`的数据库文件。然后会让你输入密码，记住选择`raw key`和`SQLCipher 3 defaults`，这时候就能正常打开了。

## **导出聊天记录并分析**

打开数据库后，可以看到有 200 多张表格，每张表格就是你和一个人的单聊记录或者一个群组的聊天记录。

选择`文件-导出-表到json`，全选所有的表格，就可以将所有的聊天记录导出为 json 文件了。

再打开`msg1.db`、`msg_2.db`等类似数据库，全部导出到一个文件夹下。

然后用任意 ide 打开这个文件夹，我用的是 vscode。然后就可以根据你想导出的人的聊天记录中的某条语句，全局搜索它在哪个文件中。

然后就可以用下面代码将聊天记录转换成 txt 文本文件了：

```bash
import json

fin = open("Chat_6ea1007e9a74fd049e11be33700d8dfd.json", "r")
fout = open("group.txt", "w")

results = json.load(fin)
for dic in results:
    if dic["messageType"] == 1:
        content = dic["msgContent"]
        if dic["mesDes"] == 1:
            msg = content.strip().split(":\n")[1].replace("\n", " ").replace("\r", " ")
        else:
            msg = content.strip().replace("\n", " ").replace("\r", " ")
        fout.write("{}\n".format(msg))
```

输出结果 group.txt 就是所有的聊天记录了

# 制作词云图

> 思路：主要借助 python 的`jieba` 做分词，`pandas` `numpy`实现计数，`wordcloud` 绘制词云图

代码参考： [https://github.com/progerchai/wordcloud-py](https://github.com/progerchai/wordcloud-py)

通过`pandas.DataFrame({*'*word*'*: words}).to_csv(”/path/xxxxx.txt”,sep=*'*\t*'*,index=False)`可以打印数据出来看看

![](/static/notion/wechat-chat-history-export/Untitled.png)

词云图效果图展示：

![](/static/notion/wechat-chat-history-export/Untitled%201.png)

---

> 感谢阅读,勘误、纠错或其他请联系progerchai@gmail.com,或者[点击这里](https://github.com/progerchai/progerchai.github.io/issues/new)提 issue 给我
> 欢迎交流 👏,你的每一次指导都可以让我进步
