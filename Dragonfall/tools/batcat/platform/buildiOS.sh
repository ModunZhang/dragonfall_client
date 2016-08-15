#!/bin/bash --login
#---------------------------------------------------
# build the iOS project with xcode command line tools
# Date: 2016/08/15
# Version: 1.0.0 beta
# by dannyhe
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
PrjName="Dragonfall" # xcode project filename: Dragonfall.xcodeproj
InfoPlistPath="${PrjDir}/ios/Info.plist"
ExportOptionsPlistPath="${DIR}/iOSExportOptions.plist" # for script
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