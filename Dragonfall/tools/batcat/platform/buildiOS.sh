#!/bin/bash --login
#---------------------------------------------------
# Date: 2016/08/15
# Version: 1.0.0 beta
# by dannyhe
#---------------------------------------------------
## 使用
# mac下通过`xcodebuild`自动打包并生成ipa文件的脚本,并提供将打包文件导出为ipa的功能.无需关心Xcode中的证书配置,脚本自动修改.但是必须提前安装好证书的配置.
# 1. buildiOS.sh xxx.xcarchive ./output Inhouse # 表示将xxx.xcarchive在Inhouse模式下生成ipa文件到output目录.
# 2. 其他形式的调用(3个参数的情况除外)会运行打包项目操作并生成相应的ipa文件.
## 注意:
# 1.脚本导出app store包的时候强制包含符号文件 .
# 2.TeamID定值为9RNQD8JEQ2.
# 3.bitcode在任何模式下关闭.
#---------------------------------------------------

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # current dir path
#---------------------------------------------------
# build argments
ProvisionType="Inhouse" # Development/Inhouse/Distribution. defalts Distribution
TargetName="DragonfallWar"
SchemeName="DragonWar"
#---------------------------------------------------
# Project 
PrjDir="${DIR}/../../../frameworks/runtime-src/proj.ios_mac" # project path
InfoPlistPath="${PrjDir}/ios/Info.plist"
ExportOptionsPlistPath="${DIR}/iOSExportOptions.plist" # for xcode
#---------------------------------------------------
# Xcode
TeamID="9RNQD8JEQ2" # The Developer Portal team to use for this export.
# CodeIdentity
DistributionCodeIdentity="iPhone Distribution: Pin Wen Huang (9RNQD8JEQ2)" # Inhouse and Distribution build
# Provision
DistributionProvision="65ab5db9-8a57-4a7d-863e-260db8d96c56" # Distribution profile identifier

BuildVer=`/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" $InfoPlistPath`
OutputName=`date "+%Y-%m-%d_%H_%M_%S"`_${TargetName}_${BuildVer}
ArchiveFileFullPath=${PrjDir}/Archive/${OutputName}.xcarchive
IpaFileDirectory=${PrjDir}/Archive/Outputs/${OutputName}

function getProvisionMethod()
{
	case $1 in 
		Distribution)
			echo "app-store"
		;;
		Development)
			echo "development"
		;;
		Inhouse)
			echo "ad-hoc"
		;;
		*)
			echo "app-store"
	esac
}

function setBuildMethod()
{
	/usr/libexec/PlistBuddy -c "set method $1" $ExportOptionsPlistPath
}

function getBuildMethod()
{
	echo `/usr/libexec/PlistBuddy -c 'print method' $ExportOptionsPlistPath`
}

function setBuildTeamID()
{
	/usr/libexec/PlistBuddy -c "set method ${TeamID}" $ExportOptionsPlistPath
}

function archiveProject()
{
	cd $PrjDir
	xcodebuild clean
	xcodebuild -sdk iphoneos -configuration Release -scheme ${SchemeName} -target "${TargetName}" -archivePath ${ArchiveFileFullPath} CODE_SIGN_IDENTITY="${DistributionCodeIdentity}" PROVISIONING_PROFILE="${DistributionProvision}" archive
	cd $DIR
}

function exportArchive()
{
	BakMethod=$(getBuildMethod)
	setBuildMethod $(getProvisionMethod $ProvisionType)
	echo "---------------------------------------------------"
	/usr/libexec/PlistBuddy -c 'print' ${ExportOptionsPlistPath}
	echo "---------------------------------------------------"
	xcodebuild -exportArchive -exportOptionsPlist ${ExportOptionsPlistPath} -archivePath ${ArchiveFileFullPath} -exportPath ${IpaFileDirectory}
	setBuildMethod $BakMethod
	/usr/libexec/PlistBuddy -c 'print' ${ExportOptionsPlistPath}
}

function normalArchiveAndExport()
{
	echo "--Begin--"
	echo "Archive"
	echo "---------------------------------------------------"
	archiveProject
	echo "PackageApplication"
	echo "---------------------------------------------------"
	exportArchive
	echo "---------------------------------------------------"
	echo "--End--"
}

function exportArchiveWithConfig()
{
	echo "--Begin--"
	iArchiveFileFullPath=$1
	iIpaFileDirectory=$2
	iProvisionType=$3
	BakMethod=$(getBuildMethod)
	setBuildMethod $(getProvisionMethod $iProvisionType)
	echo "---------------------------------------------------"
	/usr/libexec/PlistBuddy -c 'print' ${ExportOptionsPlistPath}
	echo "---------------------------------------------------"
	xcodebuild -exportArchive -exportOptionsPlist ${ExportOptionsPlistPath} -archivePath ${iArchiveFileFullPath} -exportPath ${iIpaFileDirectory}
	setBuildMethod $BakMethod
	/usr/libexec/PlistBuddy -c 'print' ${ExportOptionsPlistPath}
	echo "--End--"
}

#---------------------------------------------------
if [ $# -eq 3 ];then
	exportArchiveWithConfig $@
else
	normalArchiveAndExport
fi