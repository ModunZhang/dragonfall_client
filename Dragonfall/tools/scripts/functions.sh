#! /bin/bash

set -e
#todo android
PLATFORMS="iOS Android"
EncryptTypes="true false"
XCODE_CONFIGURATIONS="Debug Release Hotfix"

getPlatform()
{
Platform=$1
if [[ -z $Platform ]]
then
    echo "Platform :" >&2
    select Platform in $PLATFORMS
    do
        if [[ -n $Platform ]]
        then
            break
        fi
    done
fi
echo $Platform
}
getAndroidXMLConfig()
{
	args=$1
	xmlPath=`getPlatformProjectRoot Android`/AndroidManifest.xml
	ret=`python AndroidXml.py $xmlPath $args`
	echo $ret
}
# 项目根目录
getProjDir()
{
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	echo $DIR/../..
}
# 开发资源目录
getResourceDir()
{
	root_dir=`getProjDir`
	echo ${root_dir}/dev/res
}
# 开发脚本目录
getScriptsDir()
{
	root_dir=`getProjDir`
	echo ${root_dir}/dev/scripts
}
# 导出项目的根目录
getExportDir()
{
	Platform=$1
	python -c "exit(0) if \"$Platform\" in \"$PLATFORMS\".split() else exit(1)"
	root_dir=`getProjDir`
	if [[ $Platform = "iOS" ]]
	then
		result=${root_dir}/update
		test -d $result || mkdir -p $result && echo $result
	elif [[ $Platform = "Android" ]]; then
		result=${root_dir}/update_android
		test -d $result || mkdir -p $result && echo $result
	fi
}
# 导出项目的脚本目录
getExportScriptsDir()
{
	root_dir=`getExportDir $1`
	result="${root_dir}/scripts"
	test -d $result || mkdir -p $result && echo $result
}
# 导出项目的资源目录
getExportResourcesDir()
{
	root_dir=`getExportDir $1`
	result="${root_dir}/res"
	test -d $result || mkdir -p $result && echo $result
}
# quick的脚本工具
getScriptsTool()
{
	root_dir=`getExtraToolPath`
	echo "$root_dir/quick/bin/compile_scripts.sh"
}
# quick的资源工具
getResourceTool()
{
	root_dir=`getExtraToolPath`
	echo "$root_dir/quick/bin/pack_files.sh"
}
# 获取工具脚本的目录
getExtraToolPath()
{
	root_dir=`getProjDir`
	echo "$root_dir/../external"
}
getNeedEncryptScripts()
{
	EncryptType=$1
	if [[ -z $EncryptType ]]
	then
	    echo "Scripts Encrypt:" >&2
	    select EncryptType in $EncryptTypes
	    do
	        if [[ -n $EncryptType ]]
	        then
	            break
	        fi
	    done
	fi
	echo $EncryptType
}
getNeedEncryptResources()
{
	EncryptType=$1
	if [[ -z $EncryptType ]]
	then
	    echo "Resources Encrypt:" >&2
	    select EncryptType in $EncryptTypes
	    do
	        if [[ -n $EncryptType ]]
	        then
	            break
	        fi
	    done
	fi
	echo $EncryptType
}
# 文件加密key
getXXTEAKey()
{
	echo "Cbcm78HuH60MCfA7"
}
getXXTEASign()
{
	echo "XXTEA"
}
#暂时弃用PVRTexToolCLI(Android 可能会使用) *
getPVRTexTool()
{
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	echo $DIR/../TextureTools/PVRTexToolCLI
}
getConvertTool()
{
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	echo $DIR/../TextureTools/convert
}

# 获取项目的版本号*
getAppVersion()
{
	Platform=$1
	python -c "exit(0) if \"$Platform\" in \"$PLATFORMS\".split() else exit(1)"
	root_dir=`getProjDir`
	if [[ $Platform = "iOS" ]]
	then
		plist=${root_dir}/frameworks/runtime-src/proj.ios_mac/ios/Info.plist
		echo `/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" $plist`
	elif [[ $Platform = "Android" ]]; then
		echo `getAndroidXMLConfig -v`
	fi
}
# 最低版本号*
getAppMinVersion()
{
	Platform=$1
	python -c "exit(0) if \"$Platform\" in \"$PLATFORMS\".split() else exit(1)"
	root_dir=`getProjDir`
	if [[ $Platform = "iOS" ]]
	then
		plist=${root_dir}/frameworks/runtime-src/proj.ios_mac/ios/Info.plist
		echo `/usr/libexec/PlistBuddy -c "print AppMinVersion" $plist`
	elif [[ $Platform = "Android" ]]; then
		echo `getAndroidXMLConfig -m`
	fi
}
# 获取项目的tag
getAppBuildTag()
{
	Platform=$1
	python -c "exit(0) if \"$Platform\" in \"$PLATFORMS\".split() else exit(1)"
	root_dir=`getProjDir`
	TAG_BUILD=`git rev-list HEAD | wc -l | tr -d "  " | awk '{print $0}'`
	echo $TAG_BUILD
}
# 临时路径
getTempDir()
{
	Platform=$1
	python -c "exit(0) if \"$Platform\" in \"$PLATFORMS\".split() else exit(1)"
	normal_name=".DragonFall_3_5_iOS"
	if [[ $Platform = "Android" ]]; then
		normal_name=".DragonFall_3_5_Android"
	fi
	result="/Users/`whoami`/${normal_name}"
	test -d $result || mkdir -p $result && chmod 777 $result && echo $result
}
# 获取项目debug或者release
getConfiguration()
{
	Configuration=$1
	if [[ -z $Configuration ]]
	then
	    echo "Configuration :" >&2
	    select Configuration in $XCODE_CONFIGURATIONS
	    do
	        if [[ -n $Configuration ]]
	        then
	            break
	        fi
	    done
	fi
	echo $Configuration
}
#需要定义全局变量$RELEASE_GIT_AUTO_UPDATE为自动更新仓库
getGitPushOfAutoUpdate()
{
	Configuration=$1
	python -c "exit(0) if \"$Configuration\" in \"$XCODE_CONFIGURATIONS\".split() else exit(1)"
	echo "$RELEASE_GIT_AUTO_UPDATE"
}
gitBranchNameOfUpdateGit()
{
	Configuration=$1
	python -c "exit(0) if \"$Configuration\" in \"$XCODE_CONFIGURATIONS\".split() else exit(1)"
	if [[ $Configuration = "Debug" ]]
	then
		echo "develop"
	elif [[ $Configuration = "Release" ]]; then
		echo "master"
	else
		echo "hotfix"
	fi
}

getPlatformProjectRoot()
{
	Platform=$1
	python -c "exit(0) if \"$Platform\" in \"$PLATFORMS\".split() else exit(1)"
	root_dir=`getProjDir`
	if [[ $Platform = "iOS" ]]
	then
		echo ${root_dir}/frameworks/runtime-src/proj.ios_mac
	elif [[ $Platform = "Android" ]]; then
		echo ${root_dir}/frameworks/runtime-src/proj.android
	fi
}
getETCCompressTool()
{
	DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
	echo $DIR/../TextureTools/CompressETCTexture
}
$@