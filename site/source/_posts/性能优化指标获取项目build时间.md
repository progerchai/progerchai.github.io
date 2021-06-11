---
title: 性能优化指标获取项目build时间
date: 2021-06-12 02:55:50
tags: [前端, 性能, shell]
keywords: [前端, 性能, shell]
---

# 性能优化获取项目 build 时间

> 前端在性能优化的时候，需要一些数据指标来判断性能优化的效果，例如 项目 build 花费了多少时间

代码如下：

```bash
#时间戳
startTimeStamp=$((`date '+%s'`*1000+`date '+%N'`/1000000))

startTime=`date "+%Y-%m-%d %H:%M:%S"`
echo '开始时间戳:' $startTimeStamp '开始时间:' $startTime

# 执行build
npm run build

finishTimeStamp=$((`date '+%s'`*1000+`date '+%N'`/1000000))
finishTime=`date "+%Y-%m-%d %H:%M:%S"`
echo '结束时间戳:' $finishTimeStamp '结束时间:' $finishTime

#$finishTimeStamp - $startTimeStamp 时间戳差值
echo '花费时间(s)---->'
echo "scale=3; calcu = ($finishTimeStamp - $startTimeStamp) / 1000;print calcu" | bc
echo ''

```

**结果**

```bash
开始时间戳: 1623438886909 开始时间: 2021-06-12 03:14:46

#...

结束时间戳: 1623438931336 结束时间: 2021-06-12 03:15:31
花费时间(s)---->
44.427

```

---

> 感谢阅读,勘误、纠错或其他请联系progerchai@gmail.com,或者[点击这里](https://github.com/progerchai/progerchai.github.io/issues/new)提 issue 给我
> 欢迎交流 👏,你的每一次指导都可以让我进步
