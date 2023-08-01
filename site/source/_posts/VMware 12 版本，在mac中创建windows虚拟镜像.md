---
title: VMware 12 版本，在 mac 中创建 windows 虚拟镜像
date: 2023-03-06 00:01:50
tags: [前端]
keywords: [前端]
---

# VMware 12 版本，在 mac 中创建 windows 虚拟镜像

> VMwere ,支持在 mac 系统中，创建一个 windows 的虚拟机，相当于一台新的 windows 的电脑，可以排查一些开发中的 windows 兼容问题。比如需要下载几个不同版本的搜狗浏览器查看兼容问题。

> VMware 12 版本面向个人用户免费了，vmware12.2.5 地址： [https://customerconnect.vmware.com/evalcenter?p=fusion-player-personal](https://customerconnect.vmware.com/evalcenter?p=fusion-player-personal)

# 1.软件下载

点击 Download VMware Fusion，得到 dmg 文件后，一路安装直到出现需要输入许可证的页面即可。

![Untitled](/static/notion/vmware12/Untitled.png)

许可证页面

![Untitled](/static/notion/vmware12/Untitled%201.png)

# 2.获取许可证

只有从上面地址下载的软件，才有获取免费许可证的入口，如上图【获取免费许可证密钥】，点击跳转，会跳转到一个页面，在页面上选择新建账号

![Untitled](/static/notion/vmware12/Untitled%202.png)

主要是填一个能联系到的邮箱即可，其他的都可随便填/ 能忽略不填的就不填。企业啥的都可以随便选。

如果最后提交的时候提示 invalid city,zip / postal code 就可以选择参考的填写

![Untitled](/static/notion/vmware12/Untitled%203.png)

参考填写（这个肯定可以通过）：

![Untitled](/static/notion/vmware12/Untitled%204.png)

成功后可以看到自己的许可证：

![Untitled](/static/notion/vmware12/Untitled%205.png)

填写许可证，完成上面的安装流程

![Untitled](/static/notion/vmware12/Untitled%206.png)

# 3.安装 windows 镜像

官网上有安装地址，你可以自由选择 win7/win10 都可以，官网下载通常很慢，但是胜在安全

window10: [https://www.microsoft.com/zh-cn/software-download/windows10ISO](https://www.microsoft.com/zh-cn/software-download/windows10ISO)

# 4.使用

将安装好的 windows 镜像拖到 VMware 中，选择单独安装，一路默认选择即可，这些配置后面都可以在高级选项中修改。密码可以不填。

![Untitled](/static/notion/vmware12/Untitled%207.png)

最后安装成功后，点击即可使用

![Untitled](/static/notion/vmware12/Untitled%208.png)
