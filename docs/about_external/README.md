#external说明

## 我们项目的external

> 我将一些自定义的工具,以及一些各个平台下不需要做修改的公共项目上传到这个位置`$ProjectDir/external`,我们自定义的工具全部使用`cmake`生成项目文件。

###文件夹说明

* Android

> Android下的公共项目,比如google play service

* CocostudioConvert

> 自定义的修改cocostudio生成的动画数据工程(mac)

* crc32

> 将生成crc32的命令行抽离出项目的单独工程(mac/win32)

* quick

> 从quick3.3中抽离的一些文件,包括可用于加密的lua项目以及用于代码和图片处理的脚本

* WindowsPhone

> 存放WindowsPhone上使用的一些第三方库或sdk


### 关于CMake

> 上面的项目,只要是我们项目自定义的。均已写了cmake的生成文件

举例如何修改及编译项目,这里以'crc32'为例。首先安装cmake,打开终端并定位到`crc32`文件夹

* mac

执行命令 

~~~
cmake -G “Xcode” .
~~~

* win32

> 可以使用cmake的gui工具生成项目

或者执行命令 

~~~
cmake -G "Visual Studio 12 2013" .
~~~

### 子模块的引入

之前我将自定义的压缩工具源码拷贝到了`external`文件下，发现维护起来很麻烦，所以这个项目就用子模块的形式引入。
如果你发现你的`external`下没有这个项目,在项目根目录执行以下命令.

~~~
	git submodule init
	git submodule update
~~~

## cocos2dx的external

> 2dx的自身使用很多第三方库，位置`$ProjectDir/Dragonfall/frameworks/cocos2d-x/external`

### 如何查看版本

**查看文件夹下的`version.json`,里面有对应库的版本信息**

### 如何更新第三方库

* 如果是跟随2dx更新,直接下载最新的二进制文件即可[cocos2d-x-3rd-party-libs-bin](https://github.com/cocos2d/cocos2d-x-3rd-party-libs-bin)


* 如果需要自己更新iOS/Android下2dx某个库，使用2dx的第三方库项目编译即可[cocos2d-x-3rd-party-libs-src](https://github.com/cocos2d/cocos2d-x-3rd-party-libs-src)


-----
dannyhe @ October 27, 2015