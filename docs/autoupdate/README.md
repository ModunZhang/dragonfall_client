## 项目运行与自动更新发布说明

### 当前项目开发目录
项目 		|iOS      		 | Android 			  | Windows Phone
------------|------------    |------------        |------------
目录名		|proj.ios_mac 	 | proj.android-studio| proj.win8.1-universal

### 不同平台的项目配置

配置 		|iOS (Info.plist)            | Android (version.properties)  | Windows Phone
------------| ------------               | ------------- 				  | -------------
版本号		| CFBundleShortVersionString | versionName 			  		  | Version前三位(Package.appxmanifest)
构建版本号	| CFBundleVersion            | versionCode           		  | Version最后一位(Package.appxmanifest)
进入测试服	| AppHoc                     | appHoc [false true]		      | AppHoc (App.xaml)[False True]
最低支持版本	| AppMinVersion              | appMinVersion 				  | AppMinVersion (App.xaml)

### 自动更新说明

#### 自动更新相关注意点
	1. config.lua文件不能被自动更新
	2. fileList.json/versions.json大版本号和小版本由项目配置的版本号和最低支持版本生成json文件
	3. 每次发布新包的版本号必须比线上的版本号高
	4. 运行自动更新脚本的时候不要再修改项目的文件!包括其他人此时也不能提交任何东西到git仓库
	
举例:手机上此时装的`1.0(123)`
  
  - 我们发布自动更新`1.0(456)`,最低版本支持为`1.0`,部署到更新服务器,手机直接启动游戏，会走自动更新。
 
  - 我们发布新包`1.0(456)`,最低版本支持为`1.0`,部署到更新服务器。`把1.0(456)`的包覆盖安装到手机上(`1.0(123)`)，启动游戏仍然版本会是`1.0(123)`,手机依然会走自动更新流程。
  
  - 我们发布新包`1.0(456)`,最低版本支持为`1.0`,部署更新服务器。手机上删除`1.0(123)`这个包，把`1.0(456)`的包安装新手机上，启动游戏不会走自动更新流程。
    
  - 我们发布新包`1.1(456)`,最低版本支持为`1.1`,部署到更新服务器,如果覆盖安装到手机上,启动游戏版本会是`1.1(456)`不会走自动更新。如果我们不覆盖安装，直接启动`1.0(123)`,会走强制更新流程。
  
  - 我们发布新包`1.1(456)`,最低版本支持为`1.0`,部署到更新服务器。覆盖安装到手机。不会走自动更新,这个包就是兼容包。

> 发布自动更新的时候一定检查git仓库版本号,不要轻易部署

#### 自动更新发布步骤
> 自动更新生成的脚本和资源加密参数必须True

* 上传所有的修改文件到develop分支,更新本地develop仓库，确保本地develop分支为最新
* 检查lua代码是否调用了新添加的底层函数
* 确保`config.lua`中的自动更新为打开状态
* 检查自动更新逻辑部分是否被修改(GameUILoginBeta.lua、GameUISplashBeta.lua),自动更新可以更新自动更新的逻辑
* 检查项目配置的`版本号`和`最低支持版本`的设置
* 切换到master分支
* 合并develop分支到master分支,提交master并推送到远端仓库
* 在master分支上执行脚本`buildUpdate.py`生成自动更新文件
* 成功后执行脚本`syncUpdateDataToGit.py`上传自动更新文件到github
* 部署自动更新的服务器(release/debug/hotfix)
* 如果是测试自动更新，最好测试完毕后还原master分支到线上版本的tag位置，如果没问题手动push项目master分支,把生成的自动更新文件推送到远端仓库
* 为master打tag

#### 发布新版本说明

> 调整项目配置中支持的`最低版本`高于线上某app的`版本号`,关闭`进入测试服`. 然后执行自动更新的所有步骤,最后打包生成相应平台的安装包。

#### 兼容包发布说明
1. 设置当前`版本号`比线上app高,`最低版本`小于或者等于线上app的`版本号`
2. 关闭`进入测试服`。
3. 执行自动更新的所有步骤。
4. 打包生成相应平台的安装包。

### 一般调试步骤(Debug)

1. 修改项目 关闭Lua中的自动更新逻辑
2. 设置进入测试服
3. 执行相关脚本编译lua和资源
4. 运行项目

### 打包的特殊说明
#### Android下的特殊说明
最后一步打包生成apk前需要执行`create_android_zip.py`~~生成zip压缩文件后执行apk的打包~~将资源拷贝到assets中

### 渠道和市场配置

#### 渠道

类似gNetTop、sugarcanetechnology,和渠道相关的主要是资源的不同,比如游戏中的Logo文件

~~~
local imageName = ext.channelIsEqTo("gNetop") and "splash_logo_war_514x92.png" or "splash_logo_516x92.png"
~~~

#### 市场

类似 Apple GooglePlay 360 ...,和市场相关的是内购

#### 不同平台下的配置字段

我们可以根据不同渠道和不同市场的组合，快速配置出我们需要的包

配置 		|iOS (Info.plist)            | Android (build.gradle)  		  | Windows Phone
------------| ------------               | ------------- 				  | -------------
渠道名		| GameChannel 				 | GAME_CHANNEL 			  	  | 定值 `sugarcanetechnology`
市场名   	| 定值 `Apple`                | GAME_MARKET	                  | 定值 `Microsoft`
Bugly参数ID	| BuglyId            	     | BUGLY_ID           		      | 空

#### 拓展Android: 如何快速给不同包加入统一的配置字段.并在Lua中获取值

比如有个需求: 给`Android`加入一个新的配置 市场sdk的不同参数，字段名为`GAME_SDK_ID`,在`360`和`GooglePlay`的包中指定不同值，并在`Lua`中获取该值

首先指定值

`build.gradle`:

~~~
productFlavors {
        googleplay {
            ....
            ....
            buildConfigField "String", "GAME_SDK_ID", "\"googleplay_id\""
        }
        qihoo {
            ....
            ....
            buildConfigField "String", "GAME_SDK_ID", "\"qihoo_id\""
        }
}
~~~

然后可以在`Lua`中获取:

~~~
local __,ret = luaj.callStaticMethod("com/batcatstudio/dragonfall/utils/CommonUtils", "GetBuildConfigField", {"GAME_SDK_ID"}, "(Ljava/lang/String;)Ljava/lang/String;")
print("GAME_SDK_ID is ",ret)
~~~


----
By DannyHe 11/11/2015