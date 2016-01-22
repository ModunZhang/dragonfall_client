##项目本地化、贴图使用说明文档

### 本地化说明

#### 安装

解压`poxls-1.1.0.tar.gz`并运行其中的python脚本进行安装

~~~
python setup.py install
~~~

*Mac上可能需要sudo*

安装poedit软件,分别对应`poedit_osx.zip`和`poedit_win32.rar`

#### 导出以及更新本地化文件

1. 用poedit软件依次打开所有po文件从lua源码更新本地化信息到po文件(更新操作)

2. 执行项目脚本`exportPO2Xlsx.py`将po文件导出为excel

3. excel修改完成后执行项目脚本`exportXlsx2po.py`将excel中的数据导出到po文件

4. 导出po文件成功后用poedit软件依次打开所有的po文件保存一次,让它自动更新mo文件

** 最后所有操作成功后会发现所有的po文件和mo文件均有变动 **
 
#### 新建本地化文件(项目中没有的语言)

1. 新建一个对应语言的po文件并保存到我们项目中`dev/res/i18n`
2. 设置po文件的属性(代码编码为utf8,搜索路径为app目录,搜索关键词为下划线，poedit的首选项只需设置一次 [参考文章](http://zengrong.net/post/1986.htm "详细说明")

3. 更新本地化文件

** 如果第3步执行失败，是第2步没有设置好! 下面是部分操作的图解**


![poedit->首选项](./res/1.png)

![lua项目的设置](./res/2.png)

![po文件Catalog](./res/3.png)

![代码编码为utf8](./res/4.png)

![搜索路径为app目录](./res/5.png)

![搜索路径为app目录](./res/6.png)

![搜索关键词为下划线](./res/7.png)

![搜索关键词为下划线](./res/8.png)

******

### 贴图的相关说明

##### images下文件夹说明

	_CanCompress: 将被直接压缩为pvrtc4/etc1+alpha/dds的散图
	
	_Compressed: iOS已经被合成最终大图的图
	
	_Compressed_mac: Player已经被合成最终大图的图
	
	_Compressed_wp: Windows Phone下合成的大图
	
	_Compressed_android: Android下合成的大图
	
	rgba444_single: 将被压缩为rgba4444格式的散图
	
##### 贴图操作说明:

1. 所有的大图项目在`PackImages`文件夹下,TextPacker的项目文件也在里面,使用项目脚本`buildTexture.py`导出
2. 所有新加的图需要用`ImageOptim.app`执行一次无损压缩再放入项目中

---
By DannyHe 11/11/2015
