# coding=utf-8
# DannyHe
# #如果执行这个文件出现异常或者错误日志,脚本环境就未配置成功
from batcat import *
from basic import *
import sys

def checkPythonEnv():
	try:
		import requests,colorama,biplist,poxls
	except Exception, e:
		Logging.error("脚本所依赖的第三方库检测失败!")
		sys.exit(1)

def checkEnvValue():
	try:
		if isWindows():
			find_environment_variable("CONVERT_PATH", False)
			find_environment_variable("GIT_REPOSITOTY_AUTO_UPDATE_CYGWIN", False)
		else:
			executeCommand("convert -version",False)
		find_environment_variable("GIT_REPOSITOTY_AUTO_UPDATE", False)
	except Exception, e:
		Logging.error("脚本环境就未配置成功!")
		sys.exit(1)

def checkTools():
	executeCommand("git --version",False)
	executeCommand("TexturePacker --version",False)
	executeCommand("rsync --version",False)

def checkPathInWindows():
	if not isWindows():
		return None
	convet_path = find_environment_variable("CONVERT_PATH", False)
	sys_path = find_environment_variable("Path", False)
	if not convet_path in sys_path:
		die("you need set %CONVERT_PATH% in your 'Path' environment")
	pass

# main
if __name__ == "__main__":
	Logging.info("开始验证脚本的执行环境")
	checkPythonEnv()
	checkEnvValue()
	checkPathInWindows()
	checkTools()
	Logging.info("验证脚本的执行环境结束")