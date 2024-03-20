---
title: 找回git stash drop 的内容
date: 2022-06-27 20:46:50
tags: [git]
keywords: [git]
---


# 找回git stash drop 的内容

> 背景：平时开发在同一个项目进行多件事的时候，经常会用到stash 的功能。假设你正在开发一个功能，但是突然有一个hotfix，然而你正在开发的东西可能很不完善，你不想直接进行commit。那么这个时候你会用stash 把修改暂存到本地，然后checkou 到hotfix分支，搞完后再切回来，然后把暂存的代码恢复继续开发
> 

今天开发的时候，就是类似情况，我将本地正在开发的代码stash 了之后，切到hotfix分支进行问题修复。修复完了之后我的git 操作命令如下：

```bash
# 第一步
git stash list
#stash@{0}: WIP on mall_suggest_sort_zhaoqing: 59e4a59 🚀 代码优化
#stash@{1}: WIP on workflow: c13a9a1 fix: date range format

# 第二步
git stash drop stash@{1}
```

假设`stash@{1}`是我要恢复的代码，我本意是想通过`git stash apply stash@{1}`的方式恢复的，但是记错了命令，用了`git stash drop stash@{1}` 把我要恢复的代码记录给删掉了。回车下去就十分后悔，我心想完了，下午可能要白干了。

---

我马上搜了一下如何恢复drop 的stash 记录，果然有办法

```bash
# 第一步，找到所有的 dangling commit 记录
git fsck --lost-found
#Checking object directories: 100% (256/256), done.
#Checking objects: 100% (5011/5011), done.
#dangling blob 4c434308ab9b25822e4679d32012ab39556f3811
#dangling commit d10522121aee9bb28f486e98021b2fc41925ea11
#dangling commit 3248ddbdd34d337f45f87de62c98cfc72b3d8411
#dangling commit 8148f7d08ee368fda6c481c178c37e9c506c2311
#dangling commit 28ca57bc6163db716223565ed321a5eafe54ca11

# 第二步， 查看commit 的具体信息，例如时间、作者等
git show d10522121aee9bb28f486e98021b2fc41925ea11
#commit d10522121aee9bb28f486e98021b2fc41925ea11
#Merge: 7c22548 778925e
#Author: xx <xx.xx@xx-inc.com>
#Date:   Tue Jun 27 17:32:36 2022 +0800

# 第三步，恢复
git stash apply d10522121aee9bb28f486e98021b2fc41925ea11
```

这里有两个注意点，第一个是`git fsck --lost-found` 返回的结果列表中，并不是有顺序的，所以你可能需要多show 几条，才能找到你想恢复的那条数据。我这里正巧当天只有一个commit ，所以比较快的就找到了。

第二个注意点是，只能恢复commit 的dangling记录，如果是blob类型的，可以通过show 查看，但是无法直接apply恢复回来。

 这次过后，我要经常commit 了，呜呜。


 ---

> 感谢阅读,勘误、纠错或其他请联系progerchai@gmail.com,或者[点击这里](https://github.com/progerchai/progerchai.github.io/issues/new)提 issue 给我
> 欢迎交流 👏,你的每一次指导都可以让我进步
