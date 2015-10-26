#关于项目的external文件夹
> 我将一些自定义的工具以及一些各个平台下不需要做修改的公共项目上传到这个位置

##文件夹简单说明

* Android

> Android下的公共项目,比如google play service

* CocostudioConvert

> 自定义的修改cocostudio生成的动画数据工程(mac)

* CompressETCTexture

> 自定义压缩纹理的工具工程,解析方式已经添加项目中(mac/win32)

* crc32

> 将生成crc32的命令行抽离出项目的单独工程(mac/win32)

* quick

> 从quick3.3中抽离的一些文件,包括可用于加密的lua项目以及用于代码和图片处理的脚本

* WindowsPhone

> 存放WindowsPhone上使用的一些第三方库或sdk


## 关于CMake

> 上面的项目,只要是我们项目自定义的。均已写了cmake的生成文件

举例如何修改及编译项目,这里以'crc32'为例。首先安装cmake,打开终端并定位到`crc32`文件夹

1. mac
	> 执行命令 cmake -GXcode
2. win32
	> 使用cmake的gui工具生成项目即可




-----
dannyhe 10/26/2015