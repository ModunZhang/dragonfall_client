# coding=utf-8
# DannyHe
from batcat import *
from basic import *
import shutil
import os
from os.path import join, getsize


Logging.DEBUG_MODE = True

CURRENT_DIR = os.getcwd()

Platform = "Android"

ANDROID_RES_DIR = getExportDir(Platform)

APP_ROOT = getProjDir()

ANDROID_PROJECT_ROOT = getPlatformProjectRoot(Platform)

TARGET_FOLDER = formatPath("%s/assets" % ANDROID_PROJECT_ROOT)

CONFIG_FILE = formatPath("%s/config.json" % APP_ROOT)

TARGET_CONFIG_FILE = formatPath("%s/config.json" % TARGET_FOLDER)

TARGET_ZIP_FILE = formatPath("%s/dragonfall.zip" % TARGET_FOLDER)

TEMP_RES_DIR = getTempDir()

ZIP_FOLDER_PATH = formatPath(
    "%s/batcatstudio/dragonfall/bundle" % TEMP_RES_DIR)

NOMEDIA_FILE_PATH = formatPath("%s/batcatstudio/.nomedia" % TEMP_RES_DIR)

JAVA_INFOMATION_FILE = formatPath(
    "%s/src/com/batcatstudio/dragonfall/data/DataHelper.java" % ANDROID_PROJECT_ROOT)
 
SedCommand = "sed"  # mac下默认


def sedJavaFile(fileSize):
	args = "s/public static final long ZIP_RESOURCE_SIZE = \(.*\)/public static final long ZIP_RESOURCE_SIZE = %d;/g" % fileSize
	command = ""
	if isWindows():
		command = [SedCommand, "-i", args, JAVA_INFOMATION_FILE]
	else:
		command = [SedCommand,"-i","", args, JAVA_INFOMATION_FILE]
	executeListCommand(command, not Logging.DEBUG_MODE)

def getdirsize(dir,exclude = ()):
    size=0l
    for (root,dirs,files) in os.walk(dir):
        for name in files:
            try:
            	fileExt = name.split(".")[-1]
            	if fileExt not in exclude:
            		size += getsize(join(root,name))
            	else:
            		Logging.debug("忽略计算%s" % fileExt)
            except:
                continue
    return size

# main
if __name__ == "__main__":

    Logging.debug(ANDROID_PROJECT_ROOT)
    Logging.debug(TARGET_FOLDER)
    Logging.debug(CONFIG_FILE)
    Logging.debug(TARGET_CONFIG_FILE)
    Logging.debug(TEMP_RES_DIR)
    Logging.debug(NOMEDIA_FILE_PATH)
    Logging.debug(ZIP_FOLDER_PATH)
    Logging.debug(ANDROID_RES_DIR)
    Logging.debug(JAVA_INFOMATION_FILE)

    if isWindows():die("已知问题:Windows下python打包的资源不能被java解压！")

    Logging.warning("- 开始资源打包")
    Logging.info("- 拷贝项目配置文件")
    if fileNewer(CONFIG_FILE, TARGET_CONFIG_FILE):
    	shutil.copy(CONFIG_FILE, TARGET_CONFIG_FILE)
    Logging.info("- 拷贝项目代码和资源")
    shutil.copytree(ANDROID_RES_DIR,ZIP_FOLDER_PATH)
    touch(NOMEDIA_FILE_PATH)
    Logging.info("- 计算资源大小")
    filesize = getdirsize(TEMP_RES_DIR,getTempFileExtensions())
    Logging.info("- 打包资源文件夹:batcatstudio")
    # if not createZipFileWithDirPath(TEMP_RES_DIR,TARGET_ZIP_FILE,getTempFileExtensions()):
    # 	die("资源打包发生了错误!")
    os.chdir(TEMP_RES_DIR)
    command = 'zip -r dragonfall.zip batcatstudio -x *.DS_Store *.bytes *.tmp -7 -TX -q'
    executeCommand(command,Logging.DEBUG_MODE)
    shutil.move("dragonfall.zip",TARGET_ZIP_FILE)
    os.chdir(CURRENT_DIR)
    Logging.info("- 解压后大小: %d bytes" % filesize)
    Logging.info("- 生成解压数据信息到Java")
    sedJavaFile(filesize)
    Logging.info("- 清除临时文件")
    removeTempDir(TEMP_RES_DIR)
    Logging.warning("- 打包脚本结束")