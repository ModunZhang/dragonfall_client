#Python脚本工具说明

##安装
###python部分

首选安装python的运行环境并安装使用的第三方库,使用以下命令安装python脚本所依赖的第三方库。**mac下可能需要管理权限安装(sudo)**

	pip install requests
	pip install colorama
	pip install biplist
	pip install poxls

###平台部分
####所有系统

~环境变量`GIT_REPOSITOTY_AUTO_UPDATE_SERVER`,指向我们自动更新仓库的本地绝对路径,具体地址:[https://github.com/ModunZhang/kod_update_server](https://github.com/ModunZhang/kod_update_server "https://github.com/ModunZhang/kod_update_server")~

例如:

	GIT_REPOSITOTY_AUTO_UPDATE=D:\Project\kod_update_server

> git 的命令行运行环境(terminal/cmd),并确认有可以操作远程仓库的权限(git pull/push etc...)

	Windows上的git最好使用ssh进行权限认证,这样cmd和其他git图形化软件都可以同时操作该仓库。相关软件在tools/win32下

####Windows

* 安装**ImageMagick** [http://www.imagemagick.org/script/binary-releases.php](http://www.imagemagick.org/script/binary-releases.php "http://www.imagemagick.org/script/binary-releases.php")
>**配置系统的环境变量`CONVERT_PATH`指向`ImageMagick命令行工具的目录`,python脚本会自动查找命令行工具`convert`**

* 安装**TexturePacker cmd命令行可执行环境**

####Mac
* 安装**TexturePacker bash命令行可执行环境**

####验证安装

执行脚本`python checkEnv.py`进行验证安装的正确性

##脚本文件说明
	所有的脚本位于tools/batcat目录下
	下面的脚本没有参数说明就表示不需要参数
	有带参数的脚本可以直接执行选择输入相应参数即可.或者执行时在后面添加默认参数.
	执行方式:
		python xxxx.py [参数1] [参数2] [参数3] ...
	

1. buildGame.py **执行lua和资源的导出**
	> 参数:1.平台  2.是否加密lua  3.是否加密资源  4.选择执行的环境(Debug模式会修改lua文件添加版本信息)
2. buildLuaConfig.py **把excel配置表导出为lua文件**
3. resources_xxxx.py **各个平台的资源处理脚本**
	> 参数:1.是否加密资源
4. scripts.py **导出项目的lua文件**
	> 参数:1.平台  2.是否加密lua 3.选择执行的环境(Debug模式会修改lua文件添加版本信息)
5. buildUpdate.py **发布自动更新脚本**
	> 参数:1.平台
6. build_format_map.py **构建图片信息的python实现**
7. cleanGame.py **清除生成项目的中间文件和导出的目录**
8. exportPO2Xlsx.py **将项目的本地化po文件导出为excel文件**
	> 参数:1.将要导出的excel文件的路径(xlsx后缀名)
9. exportXlsx2po.py **将脚本10导出的excel导回项目中**
	> 参数:1.将要导入的excel文件路径(xlsx后缀名)
10. export_plist_texture_data.py **将合成的大图信息导出到项目中**
	> 参数:1.平台
11. buildTexture.py **导出游戏的大图到images目录下**
	> 参数:1.平台
12. create_android_zip.py **将Android下导出的资源打包为zip并修改java文件使其更新文件大小信息**
13. gcm_push.py **Android下 GCM推送测试脚本**
	`python gcm_push.py --message="Bye Bye" --id="APA91bEv6GmHN3q5Swrsu_Lxxw9zds3Q2C2TPwtWIrBDbouo4uyyE5AdaKxFnZ39FYg0dyJcliPBZa_fqrc5figMZ5-M-gMNfWb_VAm6-HQS1QiDbdyBGTnPysaMw4cBsOGaUkPUbkm_"`

##添加新脚本的一些规范
> TODO
##关于脚本生成的临时垃圾文件
如果python脚本执行过程中被打断或者发生关键性错误,可能会留下一些处理资源的临时文件,如果python脚本成功执行完成,会自动清理这些临时垃圾文件

* Windows 上可以用360进行垃圾清理
* mac 上需要手动清理,需要管理员权限

##特别说明
`WindowsPhone`的资源处理只能在Windows环境进行!

----
By Dannyhe 11/11/2015