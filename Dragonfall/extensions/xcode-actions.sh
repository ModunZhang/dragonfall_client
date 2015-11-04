#!/bin/bash
export LocalBin="/usr/local/bin/"
export PATH=$LocalBin:$PATH
DOCROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DESTROOT=$DOCROOT/../update

if test -d $DESTROOT; then
	find ${DESTROOT} -name "*" -exec touch -cm {} \;
fi

echo "Xcode不再执行任何影响项目文件的操作,打包或运行项目前手动执行buildGame.sh脚本!"