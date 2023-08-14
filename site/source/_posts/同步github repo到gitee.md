---
title: 同步 github repo 到 gitee
date: 2023-08-14 19:33:07
tags: [github action]
keywords: [github action]
---

# 同步 github repo 到 gitee

> 需求，在某些国内云服务器中，拉取 github 仓库速度较慢，所以希望利用 gitee 的国内镜像，达到加速的目的

# 1.本地创建 ssh key

在本地终端，输入`ssh-keygen` 即可，根据提示输入对应的邮箱等信息，一路回车，最终你会在.ssh 目录下会得到`id_rsa` 和`id_rsa.pub` 两个文件，一个是私钥，一个是公钥

mac 电脑文件地址在 `～/.ssh`

# 2.github 全局设置

github setting → ssh and GPG keys → new SSH key

![Untitled](/static/notion/github2gitee/Untitled.png)

在 github setting 中，填入【**公钥**】即可，title 自己随意命名一个即可

# 3.gitee 全局设置

同 github 设置一样，填入**【公钥】即可**

# 4.创建 github 仓库

以 progerchai/progerchai.github.io 为例，在项目 repo 中，找到 setting→secrets and variables → actions → new repo secret ，如下图所示：

![Untitled](/static/notion/github2gitee/Untitled%201.png)

key 名称也自己定义一个字符串就行，注意会被默认转为大写字母。然后填入刚刚生成的私钥，点击保存。

![Untitled](/static/notion/github2gitee/Untitled%202.png)

# 5.创建 gitee 仓库

在 gitee 创建来承接的仓库， 可以直接选择从 github 导入

![Untitled](/static/notion/github2gitee/Untitled%203.png)

# 6.创建 github action

在 github 项目根目录下，创建`.github/workflows` 文件夹，创建一个`.yml` 文件，在文件内填入如下代码

```bash
# 通过 Github actions， 在 Github 仓库的每一次 commit 后自动同步到 Gitee 上
name: sync2gitee
on:
  push:      # 声明监听的是push 事件
    branches:
      - main  # 声明了只对main分支生效
jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - uses: wearerequired/git-mirror-action@master #开源actions包
        env:
          SSH_PRIVATE_KEY: ${{secrets.SYNCGITEEPRIVATEKEY}} # SYNCGITEEPRIVATEKEY 是在该仓库setting设置的私钥名称
        with:
          source-repo: 'git@github.com:progerchai/progerchai.github.io.git' # github仓库地址
          destination-repo: 'git@gitee.com:proger/progerchai.github.io.git' # gitee仓库地址
```

创建好之后，直接 commit 这个改动，然后 push 到 origin 即可

在 actions 中查看是否执行 workflow，发现已经执行，此时去 gitee 查看是否已将代码同步过来

![Untitled](/static/notion/github2gitee/Untitled%204.png)

![Untitled](/static/notion/github2gitee/Untitled%205.png)

发现 gitee 中已同步项目代码。任务完成

> 感谢阅读,勘误、纠错或其他请联系progerchai@gmail.com,或者[点击这里](https://github.com/progerchai/progerchai.github.io/issues/new)提 issue 给我
> 欢迎交流 👏,你的每一次指导都可以让我进步
