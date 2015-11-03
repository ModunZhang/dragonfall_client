#coding=utf-8
#DannyHe
from batcat import *
from basic import * 
import sys

Platform = ""
NEED_ENCRYPT_SCRIPTS = ""
NEED_ENCRYPT_RES = ""
CONFIGURATION = ""

def getAllArgs():
	global Platform,NEED_ENCRYPT_SCRIPTS,NEED_ENCRYPT_RES,CONFIGURATION 

	Platform = getPlatform(Platform)

	NEED_ENCRYPT_SCRIPTS = getNeedEncryptScripts(NEED_ENCRYPT_SCRIPTS)

	NEED_ENCRYPT_RES = getNeedEncryptResources(NEED_ENCRYPT_RES)

	CONFIGURATION = getConfiguration(CONFIGURATION) 

def getResCommand(platform = 'iOS'):
	scripts_name = "resources_iOS.py"
	if platform == 'Android':
		scripts_name = "resources_Android.py"
	elif platform == 'WP':
		scripts_name = "resources_WP.py"

	return "python %s %s" % (scripts_name,NEED_ENCRYPT_RES)

if __name__=="__main__":
	if  len(sys.argv) >= 5:
		Platform = sys.argv[1]
		NEED_ENCRYPT_SCRIPTS = sys.argv[2]
		NEED_ENCRYPT_RES = sys.argv[3]
		CONFIGURATION = sys.argv[4]
	elif len(sys.argv) >= 4:
		Platform = sys.argv[1]
		NEED_ENCRYPT_SCRIPTS = sys.argv[2]
		NEED_ENCRYPT_RES = sys.argv[3]
	elif len(sys.argv) >= 3:
		Platform = sys.argv[1]
		NEED_ENCRYPT_SCRIPTS = sys.argv[2]
	elif len(sys.argv) >= 2:
		Platform = sys.argv[1]

	getAllArgs()
	Logging.info("> 开始处理脚本")
	Logging.debug("------------------------------------")
	#scripts
	command = "python scripts.py %s %s %s" % (Platform,NEED_ENCRYPT_SCRIPTS,CONFIGURATION)
	executeCommand(command)

	if Platform == 'WP' and not isWindows():
		die("仅支持windows下进行windows phone平台的资源生成!")
	Logging.info("> 开始处理资源")
	Logging.debug("------------------------------------")
	command = getResCommand(Platform)
	executeCommand(command)
	Logging.info("> 处理结束")