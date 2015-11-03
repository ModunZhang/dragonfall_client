#coding=utf-8
#DannyHe
from batcat import *
from basic import * 
import sys

if __name__=="__main__":
	Logging.info("> 清理项目")
	Platform = ""
	if  len(sys.argv) > 1:
		Platform = sys.argv[1]
	Platform = getPlatform(Platform)
	ExportDir = getExportDir(Platform)
	SCRIPTS_SRC_DIR = getScriptsDir()
	Logging.debug("> 开始清理项目")
	Logging.debug("------------------------------------")
	Logging.debug("-- 中间文件")
	removeTempFiles(SCRIPTS_SRC_DIR,"bytes")
	RES_SRC_DIR = getResourceDir()
	removeTempFiles(RES_SRC_DIR,"tmp")
	emptyDir(ExportDir)
	Logging.debug("-- %s" % ExportDir)
	emptyDir(ExportDir)
	Logging.debug("------------------------------------")
	Logging.info("> 完成清理项目")