# coding=utf-8
# DannyHe
from batcat import *
from basic import *
import sys,shutil,os

Logging.DEBUG_MODE = True

#global 占位变量
Platform = "Android"
CURRENT_DIR = os.getcwd()
PROJECT_EXECUTE_DIR_PATH = getPlatformProjectRoot(Platform)

def checkObjs():
	Logging.info("检测项目二进制文件")
	if not os.path.exists(formatPath("%s/libs/armeabi/libcocos2dlua.so" % PROJECT_EXECUTE_DIR_PATH)):
		Logging.warning("项目二进制文件不存在,重新构建...")
		os.chdir(PROJECT_EXECUTE_DIR_PATH)
		executeCommand("sh clean.sh",not Logging.DEBUG_MODE)
		executeCommand("sh build_native_release.sh",not Logging.DEBUG_MODE)
		os.chdir(CURRENT_DIR)
		Logging.info("二进制文件构建结束")
	else:
		Logging.info("检测项目二进制文件结束")

def checkRes():
	Logging.info("检测项目资源文件")
	if not os.path.exists(formatPath("%s/assets/dragonfall.zip" % PROJECT_EXECUTE_DIR_PATH)):
		Logging.warning("项目资源文件不存在,重新打包...")
		command = "python create_android_zip.py"
		executeCommand(command,not Logging.DEBUG_MODE)
		Logging.info("资源文件打包结束")
	else:
		Logging.info("检测项目资源文件结束")

def buildApk():
	os.chdir(PROJECT_EXECUTE_DIR_PATH)
	Logging.info("清理项目")
	executeCommand("ant clean",not Logging.DEBUG_MODE)
	Logging.info("构建项目")
	executeCommand("ant release",not Logging.DEBUG_MODE)
	os.chdir(CURRENT_DIR)

# main
if __name__ == "__main__":
	if isWindows():
		die("这个脚本暂时只支持mac osx")
	Logging.warning("开始构建Android项目")
	Logging.debug(PROJECT_EXECUTE_DIR_PATH)
	Logging.debug(CURRENT_DIR)
	checkRes()
	checkObjs()
	buildApk()
	Logging.warning("Android项目构建成功")