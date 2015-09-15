#! /bin/bash
Platform=$1
NEED_ENCRYPT_RES=$2
RES_COMPILE_TOOL=`./functions.sh getResourceTool`
RES_SRC_DIR=`./functions.sh getResourceDir`
RES_DEST_DIR=`./functions.sh getExportResourcesDir $Platform`
XXTEAKey=`./functions.sh getXXTEAKey`
XXTEASign=`./functions.sh getXXTEASign`
PVRTOOL=`./functions.sh getPVRTexTool`
IMAGEFORMAT="ETC1"
IMAGEQUALITY="etcfast"
CONVERTTOOL=`./functions.sh getConvertTool`
ALPHA_USE_ETC=$fale
TEMP_RES_DIR=`./functions.sh getTempDir $Platform`
exportImagesRes()
{
	echo -- 处理images文件夹
	images_dir=$1
	outdir=$RES_DEST_DIR
	for file in $images_dir/*.png $images_dir/*.jpg 
	do
		outfile=$outdir/${file##*/res/}
		finalDir=${outfile%/*}
		if test "$file" -nt "$outfile";then
			echo "---- ${file##*/res/}"
			if $NEED_ENCRYPT_RES; then
				test -d $finalDir || mkdir -p $finalDir && $RES_COMPILE_TOOL -i "$file" -o $finalDir -ek $XXTEAKey -es $XXTEASign -q
			else
				test -d $finalDir || mkdir -p $finalDir && cp  "$file" $finalDir
			fi
		fi
	done
	echo -- 处理大图文件夹
	if [[ $Platform = "iOS" ]]; then #iOS直接拷贝TextPacker导出的文件 .ccz
		for file in $images_dir/_Compressed/*
		do
			if test -f "$file";then
				finalDir=$outdir/${images_dir##*/res/}
				outfile=$finalDir/${file##*/}
				fileExt=${file##*.}
				if test "$file" -nt "$outfile"; then
					echo "---- ${file##*/}"
					if test $fileExt == "plist" || test $fileExt == "ExportJson";then
						test -d $finalDir || mkdir -p $finalDir && cp "$file" $finalDir
					else
						if $NEED_ENCRYPT_RES;then
							test -d $finalDir || mkdir -p $finalDir && $RES_COMPILE_TOOL -i "$file" -o $finalDir -ek $XXTEAKey -es $XXTEASign -q
						else
							test -d $finalDir || mkdir -p $finalDir && cp "$file" $finalDir
						fi
					fi
				fi
			fi
		done
	else #android 使用png生成etc格式的大图(_Compressed_XXX文件夹,支持alpha通道)
		for file in $images_dir/_Compressed_mac/*
		do
			if test -f "$file";then
				finalDir=$outdir/${images_dir##*/res/}
				outfile=$finalDir/${file##*/}
				fileExt=${file##*.}
				tempfileName="${file%.*}"
				tempfileName="${tempfileName##*/}"
				if test "$file" -nt "$outfile"; then
					echo "---- ${file##*/}"
					if test $fileExt == "plist" || test $fileExt == "ExportJson";then
						test -d $finalDir || mkdir -p $finalDir && cp "$file" $finalDir
					else
						tempRGBfile="${TEMP_RES_DIR}/${tempfileName}.png" #rgb
						tempRGBfile_ETC="${TEMP_RES_DIR}/${tempfileName}.pvr" #rgb pvr

						tempAlphaFile="${TEMP_RES_DIR}/${tempfileName}_alpha_etc1.png" #alpha png
						outAlphaFile="${finalDir}/${tempfileName}_alpha_etc1.png"

						$CONVERTTOOL "$file" -alpha Off "$tempRGBfile" 
						$CONVERTTOOL "$file" -channel A -alpha extract "$tempAlphaFile"
						if [[ $ALPHA_USE_ETC ]]; then
							tempAlphaFile_ETC="${TEMP_RES_DIR}/${tempfileName}_alpha_etc1.pvr"
							$PVRTOOL -f $IMAGEFORMAT -i "$tempAlphaFile" -o "$tempAlphaFile_ETC" -q $IMAGEQUALITY
							mv -f "$tempAlphaFile_ETC" "$tempAlphaFile"
						fi
						$PVRTOOL -f $IMAGEFORMAT -i "$tempRGBfile" -o "$tempRGBfile_ETC" -q $IMAGEQUALITY
						if $NEED_ENCRYPT_RES;then
							mv -f "$tempRGBfile_ETC" "$tempRGBfile"
							test -d $finalDir || mkdir -p $finalDir && $RES_COMPILE_TOOL -i "$tempRGBfile" -o $finalDir -ek $XXTEAKey -es $XXTEASign -q
							test -d $finalDir || mkdir -p $finalDir && $RES_COMPILE_TOOL -i "$tempAlphaFile" -o $finalDir -ek $XXTEAKey -es $XXTEASign -q
						else
							mv -f "$tempRGBfile_ETC" "$outfile"
							mv -f "$tempAlphaFile" "$outAlphaFile"
						fi
					fi
				fi
			fi
		done
	fi
	echo -- 处理rgba444_single文件夹 #iOS Android 平台相同处理
	for file in $images_dir/rgba444_single/*
	do
		if test -f "$file";then
			finalDir=$outdir/${images_dir##*/res/}
			outfile=$finalDir/${file##*/}
			tempfile="$TEMP_RES_DIR/${file##*/}"
			fileExt=${file##*.}
			if test "$file" -nt "$outfile"; then
				echo "---- ${file##*/}"
				if test $fileExt == "plist" || test $fileExt == "ExportJson";then
					test -d $finalDir || mkdir -p $finalDir && cp "$file" $finalDir
				else
					#是否考虑 pvr ccz + premultiply-alpha?
					TexturePacker --format cocos2d --no-trim --disable-rotation --texture-format png --opt RGBA4444 --png-opt-level 7  --allow-free-size --padding 0 "$file" --sheet "$tempfile" --data "$TEMP_RES_DIR/tmp.plist"
					if $NEED_ENCRYPT_RES;then
						test -d $finalDir || mkdir -p $finalDir && $RES_COMPILE_TOOL -i "$tempfile" -o $finalDir -ek $XXTEAKey -es $XXTEASign -q
					else
						test -d $finalDir || mkdir -p $finalDir && cp "$tempfile" $finalDir
					fi
				fi
			fi
		fi
	done
	echo -- 处理_CanCompress文件夹
	for file in $images_dir/_CanCompress/*
	do
		if test -f "$file";then
			finalDir=$outdir/${images_dir##*/res/}
			outfile=$finalDir/${file##*/}
			tempfileName="${file%.*}"
			tempfileName="${tempfileName##*/}"
			if [[ $Platform = "iOS" ]];then #iOS进行pvrtc4压缩(支持alpha通道)
				tempfile="${TEMP_RES_DIR}/${tempfileName}.pvr"
				if test "$file" -nt "$outfile"; then
					echo "---- ${file##*/}"
					TexturePacker --format cocos2d --no-trim --disable-rotation --texture-format pvr2 --premultiply-alpha --opt PVRTC4 --padding 0 "$file" --sheet "$tempfile" --data "$TEMP_RES_DIR/tmp.plist"
					cp -f $tempfile "${TEMP_RES_DIR}/${tempfileName}_PVR_PNG.png"
					if $NEED_ENCRYPT_RES;then
						$RES_COMPILE_TOOL -i "${TEMP_RES_DIR}/${tempfileName}_PVR_PNG.png" -o $finalDir -ek $XXTEAKey -es $XXTEASign -q
						mv -f "$finalDir/${tempfileName}_PVR_PNG.png" $outfile
						rm -f "${TEMP_RES_DIR}/${tempfileName}_PVR_PNG.png"
					else
						mv -f "${TEMP_RES_DIR}/${tempfileName}_PVR_PNG.png" $outfile
					fi
				fi
			elif [[ $Platform = "Android" ]]; then #Android使用etc1(暂时支持alpha通道)
				# tempETCFile="${TEMP_RES_DIR}/${tempfileName}.pvr"
				# tempPNGFile="${TEMP_RES_DIR}/${tempfileName}.png"
				# if test "$file" -nt "$outfile"; then
				# 	echo "---- ${file##*/}"
				# 	$PVRTOOL -f $IMAGEFORMAT -i "$file" -o "$tempETCFile" -q "$IMAGEQUALITY"

				# 	if $NEED_ENCRYPT_RES;then
				# 		mv -f "$tempETCFile" "$tempPNGFile"
				# 		$RES_COMPILE_TOOL -i "$tempPNGFile" -o $finalDir -ek $XXTEAKey -es $XXTEASign -q
				# 	else
				# 		mv -f "$tempETCFile" "$outfile"
				# 	fi
				# fi
				tempRGBfile="${TEMP_RES_DIR}/${tempfileName}.png" #rgb
				tempRGBfile_ETC="${TEMP_RES_DIR}/${tempfileName}.pvr" #rgb pvr
				tempAlphaFile="${TEMP_RES_DIR}/${tempfileName}_alpha_etc1.png" #alpha png
				outAlphaFile="${finalDir}/${tempfileName}_alpha_etc1.png"

				$CONVERTTOOL "$file" -alpha Off "$tempRGBfile" 
				$CONVERTTOOL "$file" -channel A -alpha extract "$tempAlphaFile"
				if [[ $ALPHA_USE_ETC  ]]; then
					tempAlphaFile_ETC="${TEMP_RES_DIR}/${tempfileName}_alpha_etc1.pvr"
					$PVRTOOL -f $IMAGEFORMAT -i "$tempAlphaFile" -o "$tempAlphaFile_ETC" -q $IMAGEQUALITY
					mv -f "$tempAlphaFile_ETC" "$tempAlphaFile"
				fi
				$PVRTOOL -f $IMAGEFORMAT -i "$tempRGBfile" -o "$tempRGBfile_ETC" -q $IMAGEQUALITY
				if $NEED_ENCRYPT_RES;then
					mv -f "$tempRGBfile_ETC" "$tempRGBfile"
					test -d $finalDir || mkdir -p $finalDir && $RES_COMPILE_TOOL -i "$tempRGBfile" -o $finalDir -ek $XXTEAKey -es $XXTEASign -q
					test -d $finalDir || mkdir -p $finalDir && $RES_COMPILE_TOOL -i "$tempAlphaFile" -o $finalDir -ek $XXTEAKey -es $XXTEASign -q
				else
					mv -f "$tempRGBfile_ETC" "$outfile"
					mv -f "$tempAlphaFile" "$outAlphaFile"
				fi
			fi
		fi
	done
}

exportAnimationsRes()
{
	images_dir=$1
	echo -- 处理文件夹 --$images_dir
	outdir=$RES_DEST_DIR/animations
	for file in $images_dir/* 
	do
		if test -f "$file";then
			outfile=$outdir/${file##*/}
			finalDir=${outfile%/*}
			fileExt=${file##*.}
			if test "$file" -nt "$outfile";then
				echo "---- ${file##*/res/}"
				if test $fileExt == "plist" || test $fileExt == "ExportJson";then
					test -d $finalDir || mkdir -p $finalDir && cp "$file" $finalDir
				else
					if $NEED_ENCRYPT_RES; then
						test -d $finalDir || mkdir -p $finalDir && $RES_COMPILE_TOOL -i "$file" -o $finalDir -ek $XXTEAKey -es $XXTEASign -q
					else
						test -d $finalDir || mkdir -p $finalDir && cp  "$file" $finalDir
					fi
				fi
			fi
		fi
	done
}
#命令行生成ETC动画贴图
exportETCAnimationRes()
{
	echo "-- png生成etc1格式的动画资源"
	images_dir=$1
	outdir=$RES_DEST_DIR/animations
	for file in $images_dir/* 
	do
		if test -f "$file";then
			outfile=$outdir/${file##*/}
			finalDir=${outfile%/*}
			fileExt=${file##*.}
			if test "$file" -nt "$outfile";then
				echo "---- ${file##*/res/}"
				if test $fileExt == "plist" || test $fileExt == "ExportJson";then
					test -d $finalDir || mkdir -p $finalDir && cp "$file" $finalDir
				else #png file
					tempfileName="${file%.*}"
					tempfileName="${tempfileName##*/}"

					tempRGBfile="${TEMP_RES_DIR}/${tempfileName}.png" #rgb
					tempRGBfile_ETC="${TEMP_RES_DIR}/${tempfileName}.pvr" #rgb pvr

					tempAlphaFile="${TEMP_RES_DIR}/${tempfileName}_alpha_etc1.png" #alpha png
					outAlphaFile="${finalDir}/${tempfileName}_alpha_etc1.png"



					$CONVERTTOOL "$file" -alpha Off "$tempRGBfile" 
					$CONVERTTOOL "$file" -channel A -alpha extract "$tempAlphaFile"

					if [[ $ALPHA_USE_ETC ]]; then
						tempAlphaFile_ETC="${TEMP_RES_DIR}/${tempfileName}_alpha_etc1.pvr"
						$PVRTOOL -f $IMAGEFORMAT -i "$tempAlphaFile" -o "$tempAlphaFile_ETC" -q $IMAGEQUALITY
						mv -f "$tempAlphaFile_ETC" "$tempAlphaFile"
					fi

					$PVRTOOL -f $IMAGEFORMAT -i "$tempRGBfile" -o "$tempRGBfile_ETC" -q $IMAGEQUALITY
					if $NEED_ENCRYPT_RES;then
						mv -f "$tempRGBfile_ETC" "$tempRGBfile"
						test -d $finalDir || mkdir -p $finalDir && $RES_COMPILE_TOOL -i "$tempRGBfile" -o $finalDir -ek $XXTEAKey -es $XXTEASign -q
						test -d $finalDir || mkdir -p $finalDir && $RES_COMPILE_TOOL -i "$tempAlphaFile" -o $finalDir -ek $XXTEAKey -es $XXTEASign -q
					else
						mv -f "$tempRGBfile_ETC" "$outfile"
						mv -f "$tempAlphaFile" "$outAlphaFile"
					fi
				fi
			fi
		fi
	done
}


#不复制字体文件和po文件
exportRes()
{
	currentDir=$1
	outdir=$RES_DEST_DIR
	for file in $currentDir/*
	do
		outfile=$outdir/${file##*/res/}
		fileExt=${file##*.}
		if test -f "$file" && test $fileExt != "po" && test $fileExt != "ttf";then
			finalDir=${outfile%/*}
			if test "$file" -nt "$outfile";then
		    	test -d "$finalDir" || mkdir -p "$finalDir" && cp "$file" "$finalDir"
		    fi
		elif test $fileExt = "ttf" && test $Platform = "Android"; then
			echo "-- 拷贝ttf字体文件"
			cp -f "$file" "$outdir"
		elif test -d "$file";then
			dir_name=${file##*/dev/res/}
			if [[ $Platform = "iOS" ]];then
				if [[ "images" == $dir_name ]];then
		    		exportImagesRes $file
		    	elif [[ "animations" == $dir_name ]];then
		    		exportAnimationsRes $file
		    	elif [[ "animations_mac" == $dir_name ]];then
		    		echo -- 不处理animations_mac文件夹
		    	else
					exportRes $file
		    	fi
		    elif [[ $Platform = "Android" ]];then
		    	if [[ "images" == $dir_name ]];then
		    		exportImagesRes $file
		    	elif [[ "animations" == $dir_name ]];then
		    		echo -- 不处理animations文件夹
		    	elif [[ "animations_mac" == $dir_name ]];then
		    		echo "-- 处理animations_mac文件夹生成Android动画资源" #如果是android 执行etc alpha处理 否则忽略
		    		exportETCAnimationRes $file
		    	else
					exportRes $file
		    	fi
		    fi
		fi
    done
}
#清除临时文件
find "$RES_SRC_DIR" -name "*.tmp" -exec rm -r {} \;
exportRes "$RES_SRC_DIR"
echo "> 资源处理完成"