---
title: mac frp 穿透
date: 2021-08-03 00:18:50
tags: [Linux, frp]
keywords: [Linux, frp]
---

# mac frp 穿透

> 将自己的 mac 本机穿透到公网上去，通过自己的服务器访问

## 首先

我们需要一台实体机，也就是我们的本机 mac

其次，我们需要一台能够访问到公网的机器，可以是云服务器

我的云服务器是腾讯云，Ubuntu 18.04.1

## 其次

我们需要下载一个工具 frp

下载地址：[https://github.com/fatedier/frp/releases](https://github.com/fatedier/frp/releases) ，可以根据自己的机器版本，在这里我本机下载的是`0.35`版本`frp_0.35.0_darwin_amd64`，那么对应的`Ubuntu`我下载的是`frp_0.35.0_linux_amd64`，保持两者版本一致避免出错

我们把本机叫做客户端，腾讯云服务器叫做服务端，那么对应的端则去修改对应的配置文件。例如服务端，我们可以把带 frpc 的文件都删除掉，没有用处，本机也可以把带 frps 的文件全部删除

## 配置

那么接下来我们分被配置本机和服务端的文件

### 服务端

修改 `frps.ini`文件

```bash
[common]
bind_port = 7000 # 与本机协议的连接端口
token = kaasdfwoqwierjjsflkasdfjalsjfaksjkdflajl # 用来token验证，长一点安全，不用记
```

### 客户端

修改本机`frpc.ini` 文件

```bash
[common]
server_addr = 139.199.**.** # 服务端ip
server_port = 7000 # 服务端协议端口
token = kaasdfwoqwierjjsflkasdfjalsjfaksjkdflajl # token

[ssh]
type = tcp
local_ip = 127.0.0.1  # 本机
local_port = 22
remote_port = 12345  # 通过服务端来访问本机的端口: ssh -p 12345 aiyouwei@139.199.**.**
```

## 运行

服务端，cd 到`frps.ini` 所在目录

```bash
# ./frps  -c ./frps.ini # 启动，最后可以加一个& 开启守护

root@VM-0-3-ubuntu:~/admin/frp_0.35.0_linux_amd64# ./frps  -c ./frps.ini &
[1] 19498
root@VM-0-3-ubuntu:~/admin/frp_0.35.0_linux_amd64# 2021/08/02 23:29:41 [I] [root.go:108] frps uses config file: ./frps.ini
2021/08/02 23:29:41 [I] [service.go:190] frps tcp listen on 0.0.0.0:7000
2021/08/02 23:29:41 [I] [root.go:217] frps started successfully
# 运行成功
```

客户端（本机），cd 到`frpc.ini` 所在目录

```bash
# aiyouwei @ qianchaodeMacBook-Pro in ~/Documents/proger/projects/frp_0.35.0_darwin_amd64 [23:56:25] C:130
$ ./frpc -c ./frpc.ini

```

出现报错：

```bash
$ ./frpc -c frpc.ini
2021/08/02 23:36:25 [W] [service.go:103] login to server failed: EOF
EOF
```

查看了服务器安全组，设置的是对本机 ip 开放所有端口的，所以安全组没有问题，最后找到原因是 ，linux 服务器防火墙没有开启对应的`7000` 端口，和`12345`端口

腾讯云防火墙操作：

```bash
sudo ufw allow smtp　允许所有的外部IP访问本机的25/tcp (smtp)端口

sudo ufw allow 22/tcp 允许所有的外部IP访问本机的22/tcp (ssh)端口

sudo ufw allow 53 允许外部访问53端口(tcp/udp)

sudo ufw allow from 192.168.1.100 允许此IP访问所有的本机端口

sudo ufw allow proto udp 192.168.0.1 port 53 to 192.168.0.2 port 53

sudo ufw deny smtp 禁止外部访问smtp服务

sudo ufw delete allow smtp 删除上面建立的某条规则
```

我这里需要放通的是`12345` 和`7000` 两个端口

```bash
root@VM-0-3-ubuntu:/etc/selinux# ufw allow 12345/tcp
Rule added
Rule added (v6)
root@VM-0-3-ubuntu:/etc/selinux# ufw allow 7000/tcp
Rule added
Rule added (v6)
```

放通后，重新运行本地

```bash
# aiyouwei @ qianchaodeMacBook-Pro in ~/Documents/proger/projects/frp_0.35.0_darwin_amd64 [23:56:25] C:130
$ ./frpc -c ./frpc.ini
2021/08/02 23:56:27 [I] [service.go:290] [fb03ce8ae5475631] login to server success, get run id [fb03ce8ae5475631], server udp port [0]
2021/08/02 23:56:27 [I] [proxy_manager.go:144] [fb03ce8ae5475631] proxy added: [ssh]
2021/08/02 23:56:27 [I] [control.go:180] [fb03ce8ae5475631] [ssh] start proxy success
```

两边都跑通之后，可以通过服务器，访问我的本机

```bash
$ ssh -p 12345 aiyouwei@139.199.**.**   # 我的本机mac用户名就是aiyouwei
# Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '[139.199.**.**]:12345' (ECDSA) to the list of known hosts.
Password: #xxxx
 # 输入密码

Last login: Mon Aug  2 23:57:56 2021 from 192.168.3.18
# 成功进入
```

---

> 感谢阅读,勘误、纠错或其他请联系progerchai@gmail.com,或者[点击这里](https://github.com/progerchai/progerchai.github.io/issues/new)提 issue 给我
> 欢迎交流 👏,你的每一次指导都可以让我进步
