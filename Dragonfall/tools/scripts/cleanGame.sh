#! /bin/bash
echo "> 清理项目"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
Platform=`./functions.sh getPlatform $1`
ExportDir=`./functions.sh getExportDir $Platform`
ProjDir=`./functions.sh getProjDir`


echo "> 开始清理项目"
echo "------------------------------------"
echo -- 中间文件
sh ./cleanTempFile.sh $Platform
echo -- update目录
cd $ProjDir

echo "---- $ExportDir/*"
rm -rf $ExportDir/*
echo "> 完成清理项目"
echo "------------------------------------"