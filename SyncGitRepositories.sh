#!/bin/bash
#这个脚本用于同步git仓库:1.同步本地的所有tag为远程的tag. 2.删除本地已经不存在的远程分支

#Delete local tags.
git tag -l | xargs git tag -d
#Fetch remote tags.
git fetch -p

#Delete remote tags.
#git tag -l | xargs -n 1 git push --delete origin tag

#Delete local tags.
#git tag -l | xargs git tag -d