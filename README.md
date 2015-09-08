###Cocos2dx lua 项目3.5(quick 3.3 > Cocos2dx lua 3.5)

---
######总体重要变动

    1.编译脚本和资源的临时文件夹平台分开,iOS和Android可以同时编译。
    2.Lua脚本如果关闭加密，将使用原文打包，方便定位错误位置(正式发布必须打开加密)。
    3.生成fileList.json的python被重构，方便传入参数。
    4.iOS使用lua库 Android使用luajit 加密方式同quick 3.3。
    5.项目不再依赖kod_quick仓库的脚本文件。

######底层变动

* Label不再支持加粗功能
* EditBox不再提供设置系统控件是否可用的接口

######Functions[✗ ✓]
|  Function  | iOS          | Android       | 
|------------| ------------ | ------------- | 
|    lua库   | ✓            | ✗             | 
|    luajit库| ✗            | ✓             | 
|ETC压缩+alpha支持| ✗        | ✓             | 
|exportJson带贴图真实名称| ✓  | ✓             | 
|项目脚本工具  | ✓            | ✓             | 




---
Last Modify @ September 8, 2015