#!/bin/bash --login
#---------------------------------------------------
# Date: 2016/08/15
# Version: 2.0.0
# by dannyhe
#---------------------------------------------------
## 使用
# mac下通过`xcodebuild`自动打包并生成ipa文件的脚本,并提供将打包文件导出为ipa的功能.无需关心Xcode中的证书配置,脚本自动修改.但是必须提前安装好证书的配置.
# 1. buildiOS.sh xxx.xcarchive ./output Inhouse # 表示将xxx.xcarchive在Inhouse模式下生成ipa文件到output目录.
# 2. buildiOS.sh xxx.ipa ./output # 表示将xxx.ipa强制转换成apphoc为true的Inhose模式下的新ipa包到output目录.
# 3. 其他形式的调用会运行打包项目操作并生成相应的ipa文件.
## 注意:
# 1.脚本导出app store包的时候强制包含符号文件 .
# 2.bitcode在任何模式下关闭.
#---------------------------------------------------

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" # current dir path
#---------------------------------------------------
# build argments
ProvisionType="Distribution" # Development/Inhouse/Distribution. defalts Distribution
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

#---------------------------------------------------
# Main function
#---------------------------------------------------

BuildVer=`/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" $InfoPlistPath`
OutputName=${TargetName}_${BuildVer}
OutputDirPath=${PrjDir}/Output/${OutputName}

# convert ProvisionType to Xcode method
function getProvisionMethod2PlistConfig()
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
# Xcode config
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
	/usr/libexec/PlistBuddy -c "set teamID ${TeamID}" $ExportOptionsPlistPath
}

# project config

function setAppHoc()
{
	/usr/libexec/PlistBuddy -c "set AppHoc $1" $InfoPlistPath
}

function printAppHoc()
{
	echo "---------------------------------------------------------"
	echo "appHoc:"
	echo `/usr/libexec/PlistBuddy -c 'print AppHoc' $InfoPlistPath`
	echo "---------------------------------------------------------"
}


function archiveAndExportProject()
{
	iApphoc=$1
	iArchiveDirName="Release_Server"
	iTimestamp=`date "+%Y-%m-%d_%H_%M_%S"`
	iFinalOutputArchiveName="${OutputName}_${iArchiveDirName}_${iTimestamp}.xcarchive"
	iArchiveFileFullPath="${OutputDirPath}/${iFinalOutputArchiveName}"
	setAppHoc false
	archiveProject ${iArchiveFileFullPath}
	iFinalOutputIpaDirPath="${OutputDirPath}/IPAs/${iArchiveDirName}_${iTimestamp}"
	exportArchive2IpaWithConfig ${iArchiveFileFullPath} "${iFinalOutputIpaDirPath}_Inhouse" "Inhouse"
	exportArchive2IpaWithConfig ${iArchiveFileFullPath} "${iFinalOutputIpaDirPath}_Distribution" "Distribution"
	#resign ipa for debug server
	resignIPA2DebugServerAdHoc  "${iFinalOutputIpaDirPath}_Distribution/${SchemeName}.ipa" "${OutputDirPath}/IPAs/Debug_Server_${iTimestamp}_Inhouse"
}

function archiveProject()
{
	iArchiveFileFullPath=$1
	printAppHoc
	cd $PrjDir
	xcodebuild clean
	xcodebuild -sdk iphoneos -configuration Release -scheme ${SchemeName} -target "${TargetName}" -archivePath ${iArchiveFileFullPath} CODE_SIGN_IDENTITY="${DistributionCodeIdentity}" PROVISIONING_PROFILE="${DistributionProvision}" archive
	cd $DIR
}

function normalExportProject()
{
	echo "-------- export project --------"
	read -p "Press [Enter] key to start..."
	archiveAndExportProject
}

function exportArchive2IpaWithConfig()
{
	echo "-------- export ipa --------"
	iArchiveFileFullPath=$1
	iIpaFileDirectory=$2
	iProvisionType=$3
	BakMethod=$(getBuildMethod)
	setBuildMethod $(getProvisionMethod2PlistConfig $iProvisionType)
	setBuildTeamID 
	echo "---------------------------------------------------"
	/usr/libexec/PlistBuddy -c 'print' ${ExportOptionsPlistPath}
	echo "---------------------------------------------------"
	xcodebuild -exportArchive -exportOptionsPlist ${ExportOptionsPlistPath} -archivePath ${iArchiveFileFullPath} -exportPath "${iIpaFileDirectory}"
	setBuildMethod $BakMethod
	/usr/libexec/PlistBuddy -c 'print' ${ExportOptionsPlistPath}
	echo "--End--"
}

function resignIPA2DebugServerAdHoc()
{
	sourceIPAPath=$1
	targetIPADirPath=$2
	# Check if the supplied file is an ipa or an app file
	if [ "${sourceIPAPath##*.}" = "ipa" ]
		then
			# Unzip the old ipa quietly
			unzip -q "$sourceIPAPath" -d temp
	fi
	APP_NAME=$(ls temp/Payload/)
	echo "APP_NAME=$APP_NAME" >&2
	NEW_PROVISION="${DIR}/../../iOS_profile/dragonrisejlzbworadhoc.mobileprovision"
	echo "Adding the new provision: $NEW_PROVISION"
	cp "$NEW_PROVISION" "temp/Payload/$APP_NAME/embedded.mobileprovision"
	ENTITLEMENTS="temp/Payload/$APP_NAME/archived-expanded-entitlements.xcent"
	PLISTFILE="temp/Payload/$APP_NAME/Info.plist"
	echo "Update plist file: $PLISTFILE" >&2
	/usr/libexec/PlistBuddy -c "set AppHoc true" $PLISTFILE
	echo "Using Entitlements: $ENTITLEMENTS" >&2
	/usr/bin/codesign -f -s "$DistributionCodeIdentity" --entitlements="$ENTITLEMENTS" "temp/Payload/$APP_NAME"
	if test -d $targetIPADirPath;then
		echo "Check target path exist: $targetIPADirPath" >&2
	else
		echo "Check target path new: $targetIPADirPath" >&2
		mkdir -p $targetIPADirPath
	fi
	NEW_FILE="${targetIPADirPath}/${SchemeName}.ipa"
	# Zip up the contents of the temp folder
	# Navigate to the temporary directory (sending the output to null)
	# Zip all the contents, saving the zip file in the above directory
	# Navigate back to the orignating directory (sending the output to null)
	pushd temp > /dev/null
	zip -qry ../temp.ipa *
	popd > /dev/null

	# Move the resulting ipa to the target destination
	mv temp.ipa "$NEW_FILE"

	# Remove the temp directory
	rm -rf "temp"
}

#---------------------------------------------------
if [ $# -eq 3 ];then #export ipa with archive file
	exportArchive2IpaWithConfig $@
elif [ $# -eq 2 ];then #resign ipa to debug model
	resignIPA2DebugServerAdHoc $@
else 
	normalExportProject #normal archive the project and export ipa files
fi