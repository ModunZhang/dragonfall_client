#! /bin/bash
# 将Android资源打包成zip
# 这个脚本也会复制配置文件，所以如果底层没有修改的时候就不再需要执行buildNative.sh 
checkError()
{
if [[ $? != 0 ]]; then
	echo "**************************资源打包发生了错误!**************************"
fi
}

APP_ROOT=`./functions.sh getProjDir`
ANDROID_RES_DIR=`./functions.sh getExportDir Android`
ZIP_FOLDER_PATH=batcatstudio/dragonfall/bundle
ANDROID_PROJECT_ROOT=`./functions.sh getPlatformProjectRoot Android`
TARGET_FOLDER="$ANDROID_PROJECT_ROOT/assets"
NEED_BACK_UP_ZIP=true #是否备份资源包
JAVA_INFOMATION_FILE="$ANDROID_PROJECT_ROOT/src/com/batcatstudio/dragonfall/data/DataHelper.java"

test -d $ZIP_FOLDER_PATH  || mkdir -p $ZIP_FOLDER_PATH && rm -rf $ZIP_FOLDER_PATH/*
checkError
test -d "$TARGET_FOLDER"  || mkdir -p "$TARGET_FOLDER" 
checkError
echo "- 拷贝项目配置文件"
cp -rf "$APP_ROOT"/config.json "$ANDROID_PROJECT_ROOT"/assets/
checkError
echo "- 拷贝项目代码和资源"
touch batcatstudio/.nomedia
cp -R $ANDROID_RES_DIR/* $ZIP_FOLDER_PATH
checkError
echo "- 计算资源大小"
TOTAL_SIZE=`find batcatstudio -type f -exec ls -l {} \; | awk '{sum += $5} END {print sum}'`
checkError
echo "- 打包资源文件夹:batcatstudio"

zip -r dragonfall.zip batcatstudio -x "*.DS_Store" "*.bytes" "*.tmp" -7 -TX -q
checkError
mv -f dragonfall.zip $ANDROID_PROJECT_ROOT/assets
checkError
rm -rf batcatstudio
checkError
if [[ $NEED_BACK_UP_ZIP ]]; then
	echo "- 开始备份资源包"
fi
echo "- 解压后大小: ${TOTAL_SIZE} bytes"
echo "- 生成解压数据信息到Java"
sed "s/public static final long ZIP_RESOURCE_SIZE = \(.*\)/public static final long ZIP_RESOURCE_SIZE = ${TOTAL_SIZE};/g" "${JAVA_INFOMATION_FILE}" > tmp.java
mv -f tmp.java "${JAVA_INFOMATION_FILE}"
checkError
echo "- 打包脚本结束"