---
title: crontab定时任务
date: 2023-08-01 22:33:50
tags: [crontab, 定时任务, linux, ubuntu]
keywords: [crontab, 定时任务, linux, ubuntu]
---

# crontab 定时任务

> 需求： 设置了一个钉钉机器人， 希望他能在每天特定的时间发送倒计时消息，警醒群内的人

钉钉开放文档： [https://open.dingtalk.com/document/robots/custom-robot-access](https://open.dingtalk.com/document/robots/custom-robot-access)

1. 在钉群内，添加一个机器人 ，开启消息推送能力，设置安全设置

![Untitled](/static/notion/crontab/Untitled.png)

添加好之后即可通过 webhook 的方式，来向钉群发消息

```bash
curl 'https://oapi.dingtalk.com/robot/send?access_token=xxxxxxxx' \
 -H 'Content-Type: application/json' \
 -d '{"msgtype": "text","text": {"content":"我就是我, 是不一样的烟火"}}'
```

例如上方代码，通过 curl 即可发送消息

1. 发送消息的操作走通了，那么我需要一段脚本来执行这件事

我把业务代码贴在下方：

```bash
timestamp=$(date +%s) # 当前时间戳
diff=`expr 1699091692 - $timestamp` #距离1699091692 这个时间戳的差值
day=`expr $diff / 60 / 60 / 24` # 一天有60*60*24s，计算出天数day

# 执行curl ，发送消息
curl 'https://oapi.dingtalk.com/robot/send?access_token=xxxx' \
 -H 'Content-Type: application/json' \
 -d '{"msgtype": "text","text": {"content":"学习啦！考试还有=='"${day}"'天==，你这个年龄段，你睡得着觉？"},"isAtAll":true}'
```

1. 实现了脚本，接下来我们需要定时去执行这个操作

我想到了 crontab

说干就干， 在我自己的服务器里装上 crontab，我是 ubuntu ，如果你是 CentOS,可以使用 yum 安装

```bash
apt-get install cron # ubuntu
```

以下是 crontab 的一些操作

```bash
crontab –e      # 修改 crontab 文件，如果文件不存在会自动创建。
crontab –l      # 显示 crontab 文件。
crontab -r      # 删除 crontab 文件。
crontab -ir     # 删除 crontab 文件前提醒用户。

service cron status    # 查看crontab服务状态
service cron start     # 启动服务
service cron stop      # 关闭服务
service cron restart   # 重启服务
service cron reload    # 重新载入配置
```

安装好之后，通过执行`crontab -e` 你会进入一个 vim 编辑器 ，输入如下代码

```bash
# 每天晚上8点 通过bash 执行countdown.sh 这个脚本
0 20 * * * /bin/bash /root/admin/timer/countdown.sh

# 基本格式如下：
# *　　*　　*　　*　　*　　command
# 分  时　 日　 月　 周　  命令
```

输入好之后，保存文件，执行`service cron start` 开始执行

效果如下：

![Untitled](/static/notion/crontab/Untitled%201.png)

更多内容可以参考最上方的钉钉开放文档～

---

> 感谢阅读,勘误、纠错或其他请联系progerchai@gmail.com,或者[点击这里](https://github.com/progerchai/progerchai.github.io/issues/new)提 issue 给我
> 欢迎交流 👏,你的每一次指导都可以让我进步
