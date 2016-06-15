#!/bin/bash
#---------------------------------------------------
# build the iOS project with xcode command line tools
# Date: 2016/05/16
# Version: 1.0.0
# by dannyhe
#---------------------------------------------------

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PrjDir="$DIR/../../../frameworks/runtime-src/proj.ios_mac"
PrjName="Dragonfall"
ProvisionType="Distribution" # Inhouse
#Distribution config
DistributionProvision="7f884fc4-abc7-4efd-bba6-c9297bf4fd3a"
DistributionCodeIdentity="iPhone Distribution: Alan Cooper (B484Q6X8P4)"
#Inhouse config
InhouseProvision="0bed58fb-1068-4d04-b1b4-959212c36644"
InhouseCodeIdentity="iPhone Developer: Alan Cooper (37X43D5H4Z)"
TargetName="Dragonfall"
BuildConfig="Release"
ProductDir=build/Release-iphoneos
TargetInfoPlistPath=ios/Info.plist

cd "${PrjDir}"

BuildVer=`/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" $TargetInfoPlistPath`
BuildMinVer=`/usr/libexec/PlistBuddy -c "print AppMinVersion" $TargetInfoPlistPath`
IpaName="${TargetName}_${BuildConfig}_${BuildVer}_m${BuildMinVer}.ipa"
FinalZipName="${TargetName}_${BuildConfig}_${BuildVer}_m${BuildMinVer}.zip"
#clean 
if [ -d ${ProductDir} ]; then
    rm -rf ${ProductDir}/*
fi

if [ "${ProvisionType}" == "Inhouse" ]; then
	sed -i.bak "s/\"CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]\" = .*;/\"CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]\" = \"${InhouseCodeIdentity}\";/g;s/CODE_SIGN_IDENTITY = .*;/CODE_SIGN_IDENTITY = \"${InhouseCodeIdentity}\";/g;s/\"PROVISIONING_PROFILE\[sdk=iphoneos\*\]\" = .*;/\"PROVISIONING_PROFILE\[sdk=iphoneos\*\]\" = \"${InhouseProvision}\";/g;s/PROVISIONING_PROFILE = .*;/PROVISIONING_PROFILE = \"${InhouseProvision}\";/g" "${PrjName}".xcodeproj/project.pbxproj
elif [ "${ProvisionType}" == "Distribution" ]; then
	sed -i.bak "s/\"CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]\" = .*;/\"CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]\" = \"${DistributionCodeIdentity}\";/g;s/CODE_SIGN_IDENTITY = .*;/CODE_SIGN_IDENTITY = \"${DistributionCodeIdentity}\";/g;s/\"PROVISIONING_PROFILE\[sdk=iphoneos\*\]\" = .*;/\"PROVISIONING_PROFILE\[sdk=iphoneos\*\]\" = \"${DistributionProvision}\";/g;s/PROVISIONING_PROFILE = .*;/PROVISIONING_PROFILE = \"${DistributionProvision}\";/g" "${PrjName}".xcodeproj/project.pbxproj
fi

#security unlock-keychain -p pwd
# xcodebuild clean
xcodebuild -configuration ${BuildConfig} -target "${TargetName}" GCC_PREPROCESSOR_DEFINITIONS="\${GCC_PREPROCESSOR_DEFINITIONS}" WARNING_LDFLAGS="\${WARNING_LDFLAGS} -w"

#check
if [ $? != 0 ]; then
	echo "Build Error: xcode build ${BuildConfig} Error!"
	exit 1
fi

if [ ! -d "${ProductDir}/${TargetName}.app" ]; then
	echo "App Error: File ${ProductDir}/${TargetName}.app not exist!"
	exit 1
fi

if [ ! -d "${ProductDir}/${TargetName}.app.dSYM" ]; then
	echo "dSYM Error: File ${ProductDir}/${TargetName}.app.dSYM not exist!"
	exit 1
fi

# Build ipa

xcrun -sdk iphoneos PackageApplication -v "${ProductDir}/${TargetName}.app" -o "${PrjDir}/${IpaName}"

if [ $? != 0 ]; then
	echo "Build Error: xcode PackageApplication ${BuildConfig} Error!"
	exit 1
fi

mv -f ${PrjDir}/${IpaName} ${ProductDir}/${IpaName}

zip -r build/${FinalZipName} ${ProductDir} -x "*.DS_Store" "*.bytes" "*.tmp" -7 -TX -q

if [ $? != 0 ]; then
	echo "Zip Error: ${FinalZipName} Error!"
	exit 1
fi
echo "-----------------------------------------"
echo "Build Success"
echo "-----------------------------------------"
ls -l build
cd ${DIR}