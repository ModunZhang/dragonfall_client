#!/bin/bash
#---------------------------------------------------
# build the iOS project with xcode command line tools
# Date: 2016/05/16
# by dannyhe
#---------------------------------------------------
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PrjDir="$DIR/../../../frameworks/runtime-src/proj.ios_mac/"
PrjName="Dragonfall"
ProvisionType="Distribution" # Inhouse
#Distribution config
DistributionProvision="7f884fc4-abc7-4efd-bba6-c9297bf4fd3a"
DistributionCodeIdentity="iPhone Distribution: Alan Cooper (B484Q6X8P4)"
#Inhouse confi
InhouseProvision="0bed58fb-1068-4d04-b1b4-959212c36644"
InhouseCodeIdentity="iPhone Developer: Alan Cooper (37X43D5H4Z)"
TargetName="Dragonfall"
BuildConfig="Release"
IpaName="${TargetName}_${BuildConfig}.ipa"
ProductDir=build/Release-iphoneos

cd "${PrjDir}"
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
xcodebuild clean
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

## Build ipa

xcrun -sdk iphoneos PackageApplication -v "${ProductDir}/${TargetName}.app" -o "${PrjDir}/${IpaName}"
