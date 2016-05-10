#!/usr/bin/env python
# -*- coding: utf-8 -*-

from basic import *
from batcat import *
import filecmp 
import os
# filecmp.cmp(r'e:\1.txt',r'e:\2.txt')
origin= "../../dev/res/images/"
source = "../../dev/res/images/hdimages/"
dest = "../../dev/res/images/sdimages/"


def emitSdImage(inFile):
	fileName = os.path.basename(inFile)
	outFile = dest+fileName.split(".")[0]+"-sd."+fileName.split(".")[1]
	if fileNewer(inFile, outFile):
		command = "%s %s -resize 50%% %s" % (getConvertTool(), inFile, dest+fileName.split(".")[0]+"-sd."+fileName.split(".")[1])
		executeCommand(command, False)

if __name__=="__main__":
	D = {}
	if not os.path.isdir(dest):
		os.mkdir(dest)
	for root, dirs, files in os.walk(source):
		for fileName in files:
			fileExt = fileName.split(".")[-1]
			if "-sd" not in fileName and fileExt != 'DS_Store':
				if os.path.exists(origin+fileName):
					if not filecmp.cmp(origin+fileName, source+fileName):
						print("not equal", fileName)
						os.remove(source+fileName)
						shutil.copy(origin+fileName,source+fileName) 
						print("copy", fileName)
					else:
						emitSdImage(source+fileName)
				else:
					print("not found", fileName)
					os.remove(source+fileName)
					print("remove", fileName)





