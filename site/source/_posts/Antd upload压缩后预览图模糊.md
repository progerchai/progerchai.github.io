---
title: Antd upload压缩后，预览图模糊
date: 2021-06-25 20:17:49
tags: [Fix, 前端]
keywords: [Fix, 前端]
---

# Antd upload 压缩后，预览图模糊

> 需求：用户上传图片后，会用这个图片跑模型，所以图片大小会影响模型运行速度，需要尽量使图片在上传前先简单压缩一遍

## 我的方案：

因为前端使用了 Antd ，所以在 beforeUpload 的时候，1.用 canvas 绘图 2.再 toDataURL 的到 base64 或者 Blob 转成二进制 3.转成 File 进行上传

关键代码如下：

```jsx
beforeUpload: (file) => {
  return new Promise((resolve) => {
    // 图片压缩
    let reader = new FileReader(),
      img = new Image();
    reader.readAsDataURL(file);
    reader.onload = function (e) {
      img.src = e.target.result;
    };
    img.onload = function () {
      let canvas = document.createElement('canvas');
      let context = canvas.getContext('2d');
      let originWidth = this.width;
      let originHeight = this.height;

      canvas.width = originWidth;
      canvas.height = originHeight;
      canvas.style.cssText = `width: ${originWidth}px; height: ${originWidth}px;`;
      context.drawImage(img, 0, 0, originWidth, originHeight);
      let compress = canvas.toDataURL(file.type, 0.65);
      let arr = compress.split(',');
      let bstr = atob(arr[1]),
        n = bstr.length,
        u8arr = new Uint8Array(n);
      while (n--) {
        u8arr[n] = bstr.charCodeAt(n);
      }
      let imgFile = new File([u8arr], file.name, { type: file.type });
      // File之后是不带uid的，没有uid antd会炸，所以把file的uid还给新的imgFile
      imgFile.uid = file.uid;
      resolve(imgFile);
    };
  });
};
```

将图片绘制到 canvas 中，再转成 File 对一般的图片都有压缩的效果，而且我代码中控制了 0.65 的 quality

但是最终效果如下：

![](/static/notion/fix_antd_upload_component_blurred_preview_image/Untitled.png)

打开预览：

![](/static/notion/fix_antd_upload_component_blurred_preview_image/Untitled%201.png)

发现 Upload 中的预览，和弹窗中的预览都是模糊的

```jsx
beforeUpload: (file) => {
  console.log('beforeUpload', file);
  // xxxxx其他代码

  img.onload = function () {
    // xxxxx 其他代码
    let compress = canvas.toDataURL(file.type, 0.65);
    let imgFile = new File([u8arr], file.name, { type: file.type });
    // File之后是不带uid的，没有uid antd会炸，所以把file的uid还给新的imgFile
    imgFile.uid = file.uid;
    console.log('resolve-imgFile', imgFile);
    console.log('compress');
    resolve(imgFile);
  };
};
```

打印结果如下：

![](/static/notion/fix_antd_upload_component_blurred_preview_image/Untitled%202.png)

发现用来上传到服务器的图片 size 为 1621386,转成 base64 后，用站长工具转成图片，发现这个 size1621386 的文件其实是清晰的，所以去服务端把上传的文件 down 下来果然是清晰的，所以很明显，这只是单纯前端显示的问题。

![](/static/notion/fix_antd_upload_component_blurred_preview_image/Untitled%203.png)

那么在`handlePreview`中打印出`preview`的文件看看

```jsx
// Upload 组件的handlePreview 中加入打印
handlePreview = (file) => {
  console.log('proview', file);
  this.setState({
    previewImage: file.url || file.thumbUrl,
    previewVisible: true,
  });
};
```

![](/static/notion/fix_antd_upload_component_blurred_preview_image/Untitled%204.png)

发现在预览的时候，图片 thumbUrl 变成了只有 41.2k ，显然这个拿来预览的图片有问题，拿出 base64 转出来看看，如下图，果然预览的是这个 41.2k 的高糊图片，且是被裁剪了的

![](/static/notion/fix_antd_upload_component_blurred_preview_image/Untitled%205.png)

## 原因：

在`Antd` 的`Upload`组件中，`ant-design/components/upload/utils.tsx` 中，有`previewImage`这样一个函数，目的是把我们传过去的图片简单压缩成 200\*200 的图片优化预览处的加载速度，但是`previewImage`的图片是结果`beforeUpload`压缩处理过的，所以导致图片**被压缩再压缩，经历了两次压缩**就变的很糊，尽管不会影响真实上传到后端的文件清晰度，但是会影响用户体验

## 解决办法：

自己写一个 previewFile，不对图片做任何处理，直接 return，这样预览的时候就不会走组件默认的`previewImage`了，并且把压缩一遍后的 base64 赋值给`resolve`出来的`imgFile.url` 这样在预览弹窗中看到的也是清晰的

并且需要在`beforeUpload`中，将压缩一遍的 base64 赋值给`imgFile`的`url`，这样`resolve`的`imgFile`被`prefiewFile`接收到，可以拿到正确预览的 base64

```jsx
beforeUpload = (file) => {
 // xxxx省略代码
return new Promise(resolve => {
	// xxxxx省略代码
	// 没有uid 会炸
		let compress = canvas.toDataURL(file.type, 0.65)
		imgFile.uid = file.uid
		imgFile.url = compress // 预览弹窗用压缩一遍的base64显示
		resolve(imgFile)
	}
}
// 不对图片做任何处理
previewFile = (file) => new Promise((resolve) => resolve(file.url || file.thumbUrl)), // 预览用清晰的图片

// xxxxxx省略代码

<Upload
beforeUpload={this.beforeUpload}
previewFile={this.previewFile}>
</Upload>
```

---

> 感谢阅读,勘误、纠错或其他请联系progerchai@gmail.com,或者[点击这里](https://github.com/progerchai/progerchai.github.io/issues/new)提 issue 给我
> 欢迎交流 👏,你的每一次指导都可以让我进步
