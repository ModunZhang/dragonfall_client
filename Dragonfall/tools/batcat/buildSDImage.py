#!/usr/bin/env python
# -*- coding: utf-8 -*-

from basic import *
from batcat import *
import os
source = "../../dev/res/images/hdimages/"
dest = "../../dev/res/images/sdimages/"
if __name__=="__main__":
	D = {}
	if not os.path.isdir(dest):
		os.mkdir(dest)
	for root, dirs, files in os.walk(source):
		for fileName in files:
			fileExt = fileName.split(".")[-1]
			if "-sd" not in fileName and fileExt != 'DS_Store':
				file1 = source+fileName
				file2 = dest+fileName.split(".")[0]+"-sd."+fileName.split(".")[1]
				if fileNewer(file1, file2):
					command = "%s %s -resize 50%% %s" % (getConvertTool(), source+fileName, dest+fileName.split(".")[0]+"-sd."+fileName.split(".")[1])
					executeCommand(command, False)





