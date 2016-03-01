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
			if "-sd" not in fileName:
				command = "%s %s -resize 50%% %s" % (getConvertTool(), source+fileName, dest+fileName.split(".")[0]+"-sd."+fileName.split(".")[1])
				executeCommand(command, False)





