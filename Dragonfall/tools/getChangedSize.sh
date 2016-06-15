#!/bin/bash
#---------------------------------------------------
# The tool to get the total size of autoupdate 
# useage: getChangedSize.sh [sha1]
# Date: 2016/06/15
# by dannyhe
#---------------------------------------------------

if test -z $1;then
	COMMAND_PREFIX="git log --name-status -1"
	TIPS="HEAD^ - HEAD:"
else
	COMMAND_PREFIX="git diff --name-status $1 HEAD"
	TIPS="$1 - HEAD:"
fi

function NotSupport()
{
	echo "Not support $OSTYPE"
	exit -1
}

function main()
{
	echo "os: $OSTYPE"
	echo "version: $TIPS"
	echo "file changed size:"
	if [[ "$OSTYPE" == "linux-gnu" ]]; then
	     NotSupport
	elif [[ "$OSTYPE" == "darwin"* ]]; then
         # Mac OSX
	     $COMMAND_PREFIX | grep -E '^[A-Z]\b' | sort -k 2,2 -u | grep -E "M\b|A\b" | awk '{print $2}' | xargs stat -f "%z" | awk '{t+=$0}END{print t/(1024*1024)" Mb"}'
	elif [[ "$OSTYPE" == "cygwin" ]]; then
        # POSIX compatibility layer and Linux environment emulation for WindowsNotSupport
        NotSupport
	elif [[ "$OSTYPE" == "msys" ]]; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
        $COMMAND_PREFIX | grep -E '^[A-Z]\b' | sort -k 2,2 -u | grep -E "M\b|A\b" | awk '{print $2}' | xargs du -b | awk '{t+=$0}END{print t/(1024*1024)" Mb"}'
	elif [[ "$OSTYPE" == "freebsd"* ]]; then
		NotSupport
	else
		NotSupport
	fi
}

main