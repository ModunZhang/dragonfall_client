#! /bin/bash

Platform=$1
NEED_ENCRYPT_SCRIPTS=$2
SCRIPT_COMPILE_TOOL=`./functions.sh getScriptsTool`
SCRIPTS_SRC_DIR=`./functions.sh getScriptsDir`
SCRIPTS_DEST_DIR=`./functions.sh getExportScriptsDir $Platform`
XXTEAKey=`./functions.sh getXXTEAKey`
XXTEASign=`./functions.sh getXXTEASign`
TEMP_RES_DIR=`./functions.sh getTempDir $Platform`
DOCROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ProjDir=`./functions.sh getProjDir`
VERSION_FILE="$ProjDir/dev/scripts/debug_version.lua"
BUILD_USE_LUA_FILE=true #不编译lua为字节码(不加密的时候)

# use jit on android
if [[ $Platform = "Android" ]]; then
	JIT_ARGS=""
else
	JIT_ARGS=""
fi

test -d "$SCRIPTS_DEST_DIR" && rm -rf "$SCRIPTS_DEST_DIR/*"

python build_format_map.py -r rgba4444.lua
python build_format_map.py -j jpg_rgb888.lua
python build_animation.py -o animation.lua

gitDebugVersion()
{
	cd "$ProjDir"
	#获取内部版本
	TIME_VERSION=`git rev-list HEAD | wc -l | tr -d "  " | awk '{print $0}'`
	echo "------------------------------------"
	echo "> Debug Version:  $TIME_VERSION"
	echo "local __debugVer = ${TIME_VERSION}
		return __debugVer
	" > $VERSION_FILE
	echo "------------------------------------"
	cd "$DOCROOT"
}

exportScriptsEncrypt()
{
	outdir=$SCRIPTS_DEST_DIR
	outfile="$outdir/game.zip"
	tempfile="$TEMP_RES_DIR/game.zip"
	if $NEED_ENCRYPT_SCRIPTS; then
		$SCRIPT_COMPILE_TOOL -i $SCRIPTS_SRC_DIR -o "$tempfile" -e xxtea_zip -ex lua -ek $XXTEAKey -es $XXTEASign -q $JIT_ARGS
	else
		if $BUILD_USE_LUA_FILE; then
			echo "-- 不编译lua为字节码"
			DOCROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
			cd $SCRIPTS_SRC_DIR
			zip -r game.zip ./* -x "*.DS_Store" "*.bytes" "*.tmp" -7 -TX -q
			mv -fv game.zip $tempfile
			cd $DOCROOT
		else
			$SCRIPT_COMPILE_TOOL -i $SCRIPTS_SRC_DIR -o "$tempfile" -ex lua -q $JIT_ARGS
		fi
	fi
	if test "$tempfile" -nt "$outfile"; then
		echo 拷贝game.zip
		cp -f "$tempfile" "$outfile"
	else
		echo 忽略game.zip
		cp -f "$tempfile"
	fi
}
gitDebugVersion
exportScriptsEncrypt 
find $SCRIPTS_SRC_DIR -name "*.bytes" -exec rm -rv {} \;