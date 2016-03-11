# coding=utf-8
# DannyHe
from batcat import *
from basic import *
import sys,shutil,os,hashlib,time,json

Logging.DEBUG_MODE = True

#global 占位变量
Platform = "Android"
CURRENT_DIR = os.getcwd()
PROJECT_EXECUTE_DIR_PATH = getPlatformProjectRoot(Platform)

logInfo = ""

def checkObjs():
	global logInfo
	Logging.info("检测项目二进制文件")
	if not os.path.exists(formatPath("%s/libs/armeabi/libcocos2dlua.so" % PROJECT_EXECUTE_DIR_PATH)):
		Logging.warning("项目二进制文件不存在,重新构建...")
		os.chdir(PROJECT_EXECUTE_DIR_PATH)
		executeCommand("sh build_native_release.sh",not Logging.DEBUG_MODE)
		os.chdir(CURRENT_DIR)
		Logging.info("二进制文件构建结束")
		logInfo['latest_bin_hash'] = getFileHash(formatPath("%s/libs/armeabi/libcocos2dlua.so" % PROJECT_EXECUTE_DIR_PATH))
		backupBin()
	else:
		logInfo['latest_bin_hash'] = getFileHash(formatPath("%s/libs/armeabi/libcocos2dlua.so" % PROJECT_EXECUTE_DIR_PATH))
	Logging.info("检测项目二进制文件结束")
		

def checkRes():
	global logInfo
	Logging.info("检测项目资源文件")
	if not os.path.exists(formatPath("%s/assets/dragonfall.zip" % PROJECT_EXECUTE_DIR_PATH)):
		Logging.warning("项目资源文件不存在,重新打包...")
		command = "python create_android_zip.py"
		executeCommand(command,not Logging.DEBUG_MODE)
		Logging.info("资源文件打包结束")
	else:
		Logging.info("检测项目资源文件结束")
	logInfo['latest_res_hash'] = getFileHash(formatPath("%s/assets/dragonfall.zip" % PROJECT_EXECUTE_DIR_PATH))

def buildApk():
	os.chdir(PROJECT_EXECUTE_DIR_PATH)
	Logging.info("清理项目")
	executeCommand("ant clean",not Logging.DEBUG_MODE)
	Logging.info("构建项目")
	executeCommand("ant release",not Logging.DEBUG_MODE)
	os.chdir(CURRENT_DIR)

def getFileHash(path):
	if not os.path.exists(path):
		die("file not exists:%s" % path)
	fp = open(path,'rb')
	try:
		fdata = fp.read()
		sha1 = hashlib.sha1()
		sha1.update(fdata)
		return sha1.hexdigest()
	except Exception, e:
		die(e)
	finally:
		fp.close()

def backupBin():
	Logging.info("开始备份项目符号文件...")
	global logInfo
	obj_path = formatPath("%s/obj" % PROJECT_EXECUTE_DIR_PATH)
	if not os.path.exists(obj_path):
		die("符号文件不存在")
	#zip文件名的后部分为对应的so文件的hash值
	zip_name = "objs_%s.zip" % logInfo['latest_bin_hash']
	zip_file_path = formatPath("%s/bin_bak" % PROJECT_EXECUTE_DIR_PATH)
	if not os.path.exists(zip_file_path):
		os.mkdir(zip_file_path)

	finally_zip = os.path.join(zip_file_path,zip_name)
	if not createZipFileWithDirPath(obj_path, finally_zip, getTempFileExtensions()):
		die("备份符号文件错误!")
	Logging.info("备份项目符号文件成功")

def initLogData():
	global logInfo
	zip_file_path = formatPath("%s/bin_bak" % PROJECT_EXECUTE_DIR_PATH)
	if not os.path.exists(zip_file_path):
		os.mkdir(zip_file_path)
	logFile = formatPath("%s/bin_bak/log.json" % PROJECT_EXECUTE_DIR_PATH)
	if os.path.exists(logFile):
		file_object = open(logFile)
		try:
			all_the_text = file_object.read()
			logInfo = json.loads(all_the_text)
		except Exception, e:
			die(e)
		finally:
			file_object.close()
	else:
		logInfo = {
			"data":{},#apk hash对应的so文件的hash值
			"latest_bin_hash":"", #当前使用的so文件的hash值
			"latest_res_hash":"", #当前使用的dragonfall.zip文件的hash值
			"latest_apk_hash":"", #当前apk文件的hash值
			"latest_java_macros":"", #当前编译的java源码中定义的宏定义
			"latest_app_version":"" #当前编译的资源文件的版本号
		}


def logApkHash():
	global logInfo
	apk_path = formatPath("%s/bin/Dragonfall-release.apk" % PROJECT_EXECUTE_DIR_PATH)
	if not os.path.exists(apk_path):
		die("apk文件不存在")
	hash_apk = getFileHash(apk_path)
	logInfo['latest_apk_hash'] = hash_apk
	logInfo['data'][hash_apk] = {"so":logInfo['latest_bin_hash'],"macro":logInfo['latest_java_macros'],"res":logInfo['latest_res_hash'],"version":logInfo['latest_app_version']}

def logAppVersion():
	global logInfo
	appVersion = getAppVersion(Platform)
	logInfo['latest_app_version'] = appVersion

def saveLogFile():
	global logInfo
	logFile = formatPath("%s/bin_bak/log.json" % PROJECT_EXECUTE_DIR_PATH)
	file_object = open(logFile,"w")
	try:
		all_the_text = json.dumps(logInfo)
		file_object.write(all_the_text)
	except Exception, e:
		die(e)
	finally:
		file_object.close()

def checkJavaMacros():
	global logInfo
	macroFile = formatPath("%s/antenna_predefines.txt" % PROJECT_EXECUTE_DIR_PATH)
	if not os.path.exists(macroFile):
		Logging.warning("未发现java的宏定义文件")
		return
	file_object = open(macroFile)
	javaMacros = ""
	try:
		javaMacros = file_object.read()
	except Exception, e:
		die(e)
	finally:
		file_object.close()

	if "COCOS_DEBUG" in javaMacros:
		die("release打包必须关闭Java的宏定义:COCOS_DEBUG")
	logInfo['latest_java_macros'] = javaMacros

# main
if __name__ == "__main__":
	if isWindows():
		die("这个脚本暂时只支持mac osx")
	Logging.warning("开始构建Android项目")
	Logging.debug(PROJECT_EXECUTE_DIR_PATH)
	Logging.debug(CURRENT_DIR)
	initLogData()
	checkJavaMacros()
	checkObjs()
	checkRes()
	buildApk()
	logAppVersion()
	logApkHash()
	saveLogFile()
	Logging.warning("Android项目构建成功")