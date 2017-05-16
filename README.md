# PhotoCutter
![](https://img.shields.io/badge/build-passing-green.svg) ![](https://img.shields.io/badge/platform-iOS7.0%2B-green.svg) 
### 简介
一款同时实现了QQ和微信头像裁剪的库，并可以自由调节大小宽度等等参数。具体效果可下载查看或者看下方效果图。
### 效果
![效果图](https://github.com/wangwangok/PhotoCutter/blob/master/photo_cutter.gif)
### 功能
- 圆形裁剪（自定义矩形半径）
- 矩形裁剪（自定义矩形宽高）
- 处理截切图片边界
- 支持放大两倍裁剪
- 支持裁剪完成添加滤镜（滤镜为系统提供相关滤镜）
### 集成

由于目前使用FrameWork集成，可以直接将Framework拖进项目中。

### 使用方法

在使用之前在文件开头添加```import PhotoCutter```

* 1、获取裁剪控制器

主要的裁剪控制器是```PhotoCutterViewController```，所以我们通过如下代码初始化一个裁剪控制器
```
let cutterViewController:PhotoCutterViewController = PhotoCutterViewController()
```

* 2、获取滤镜控制器
滤镜控制类为```PhotoFilterCollectionViewCell```。使用方法为:
```
let filterController:PhotoFilterViewController = PhotoFilterViewController()
filterController.image = cutterImage
self.navigationController?.pushViewController(filterController, animated: true)
```

* 3、传入数据源
数据源目前只支持传入```UIImage```类型的变量。设置方法如下：
```
let cutterImage = UIImage(named: "IMG_1710.jpg")!
cutterViewController.image = cutterImage
```

* 4、获取裁剪完成数据
获取剪切完成数据时，我们需要设置一个代理，如下：
```
cutterViewController.delegate = PhotoCutterViewControllerDelegate()
```
在设置完成代理之后，我们便可以通过代理来获得剪切完成的数据了：
```
cutterViewController.delegate?.didSuccesCutterPhoto = { (cutterView:PhotoCutterViewController , resultImage:UIImage?) in
            
}
```
closure中的```resultImage```便是我们需要的结果。
> 注意：
这里的Delegate并不是使用@objc的protocol，所以我们不需要为```delegate```传入```self```，避免出现retain circle。在设置delegate的就直接上面的写的那样就可以了。

可能你们会问为什么不直接在controller上使用closure，为什么非要添加一个delegate变量？第一、对于很多人来说使用delegate可能已经习惯了。第二、这里使用代理模式更符合场景需求。

* 5、设置剪切形状
同时支持圆形裁剪和矩形裁剪（宽高可以是不等的），我们可以通过设置```cutterType```属性来设置裁剪的类型。
```
public enum CutterType{
    
    case rect(width:Float,height:Float) //Clipping rectangle ,width ,height
    
    case circle(radius:Float) //Crop circle ,radius
}
```
在设置类型时，便将裁剪需要的大小数据传入进去。如下：
```
if is_circle == true {
    cutterViewController.cutterType = CutterType.circle(radius: raduis)
}else{
    cutterViewController.cutterType = CutterType.rect(width: rect_size.width, height: rect_size.height)
}
```
如果不对上面```cutterType```进行设置，那么默认值是```CutterType.circle(radius: 100)```。

* 6、是否需要使用滤镜组件
通过设置```isFilter```变量的值，来决定是否适用滤镜组件。该值默认是```true```。如果将该变量设置为```false```的话，在点击确认之后便会退回到上一次的界面。设置方法如下：
```
cutterViewController.isFilter = false
```

### 目前我在使用中遇到的问题
如果出现```"no such module PhotoCutter"```时，可见[Getting error “No such module” using Xcode, but the framework is there](http://stackoverflow.com/questions/29500227/xcode-no-such-module-error-but-the-framework-is-there)；




