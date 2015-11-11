###Cocos2dx lua 3.5

---
######总体重要变动

    1.编译脚本和资源的临时文件夹平台分开,iOS/Android/WindowsPhone可以同时编译。
    2.Lua脚本如果关闭加密,将使用原文zip压缩打包,方便快速编译(正式版本必须加密),原文打包时不会编译Lua文件。如果Lua文件有语法错误.脚本不会报错!
    3.生成fileList.json的python被重构用于方便传入参数。
    4.使用lua库,而不是使用luajit.加密方式同quick 3.3。
    5.项目不再依赖kod_quick仓库的脚本文件,已经拷贝到本仓库下面。

######底层变动

* Label不再支持加粗功能
* EditBox不再提供设置系统控件是否可用的接口
* 为了Android和iOS输入框统一,EditBox在cocos2dx 3.8版本上构建，UITextView依赖于EditBox
* Android下默认关闭Alpha预乘[ETC1压缩],iOS默认打开Alpha预乘[PRVTC压缩],Windows Phone默认关闭Alpha预乘。

######Android特别说明

* Android上在安装路径模拟了iOS的Bundle和Documents目录,首次安装的时候会根据储存空间的情况自动选择解压目录。`不包括检测SD卡损坏的情况`.
    * 举例:如果SD卡/手机的空间足够游戏解压,游戏将解压到`/sdcard/batcatstudio/`目录中
* 实现并打开了ETC压缩+alpha支持,如果发现某张贴图是ETC格式将自动查找它的Alpha格式的贴图。详情查看git提交

######iOS特别说明

* 我们项目没有使用默认的quick target,而是在默认target的基础上新建的target。用于自定义模块化编译的宏。具体的宏定义和功能看android的文档.

######Windpws Phone特别说明

* 暂时只有wp项目打开了lua websocket的支持,并添加了用于位操作的库
* EditBox在官方的基础上修改

######状态

|  Function  | iOS          | Android       | Windows Phone |
|------------| ------------ | ------------- | ------------- |
|    lua库   | ✓            |✓              | ✓				|
|ETC压缩+alpha支持| ✗        | ✓             | ✗ 			|
|exportJson带贴图真实名称| ✓  | ✓             | ✓			|
|项目脚本工具  | ✓            | ✓             | ✓			|


---
Last Modify @ 11/11/2015