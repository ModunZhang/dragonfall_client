# coding=utf-8
# DannyHe
from batcat import *
from basic import *
import shutil
import os
from os.path import join, getsize

FLAVORS = ('googleplay','paypal')
ASSETS_FOLDER = {'googleplay':'assets-googleplay','paypal':'assets-paypal'}
GAME_IDS = {'googleplay':'dragonfall','paypal':'dragonfall_paypal'}

def getGameId(flavor):
    return GAME_IDS[flavor]

def getAssetFolderName(flavor):
    return ASSETS_FOLDER[flavor]

def getFlavor(args="googleplay"):
    result = args
    message = "Android Market:\n"
    for index in range(len(FLAVORS)):
        message = message + str(index + 1) + "." + FLAVORS[index] + "\n"
    while not result in FLAVORS:
        opt = raw_input(message)
        if opt.isdigit():
            index = int(opt) - 1
            if index in range(len(FLAVORS)):
                result = FLAVORS[index]
    return result


Logging.DEBUG_MODE = True

CURRENT_DIR = os.getcwd()

Platform = "Android"

CURRENT_FLAVOR = ''

ANDROID_RES_DIR = getExportDir(Platform)

APP_ROOT = getProjDir()

ANDROID_PROJECT_ROOT = getPlatformProjectRoot(Platform)

CONFIG_FILE = formatPath("%s/config.json" % APP_ROOT)

JAVA_INFOMATION_FILE = formatPath("%s/src/com/batcatstudio/dragonfall/data/DataHelper.java" % ANDROID_PROJECT_ROOT)

SedCommand = "sed"  # mac下默认
Win32ZipCommand = ""
if isWindows():
    SedCommand = getWin32SedPath()
    Win32ZipCommand = getWin32ZipCommandTool()

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

def zipResources(sourceFolder,target_file_path):
    os.chdir(sourceFolder)
    command = 'zip -r dragonfall.zip batcatstudio -x *.DS_Store *.bytes *.tmp -7 -TX -q'
    if isWindows():
        command = '%s -r dragonfall.zip batcatstudio -x *.DS_Store *.bytes *.tmp -7 -X -q' % Win32ZipCommand
    executeCommand(command,not Logging.DEBUG_MODE)
    shutil.move("dragonfall.zip",target_file_path)
    os.chdir(CURRENT_DIR)

def checkConfigFile(asset_target_folder):
    Logging.info("- 拷贝项目配置文件")
    target_file_path = formatPath("%s/config.json" % asset_target_folder)
    if fileNewer(CONFIG_FILE, target_file_path):
        shutil.copy(CONFIG_FILE, target_file_path)

def copyAndPackResources(asset_target_folder,gameId):
    temp_res_dir = getTempDir()
    Logging.debug(temp_res_dir)
    zip_folder_path = formatPath("%s/batcatstudio/%s/bundle" % (temp_res_dir,gameId))
    zip_target_file_path = asset_target_folder
    Logging.info("- 拷贝项目代码和资源")
    shutil.copytree(ANDROID_RES_DIR,zip_folder_path)
    nomedia_file_path = formatPath("%s/batcatstudio/.nomedia" % temp_res_dir)
    touch(nomedia_file_path)
    size_to_java = getdirsize(temp_res_dir,getTempFileExtensions())
    Logging.info("- 解压后大小: %d bytes" % size_to_java)
    Logging.info("- 打包资源文件夹:batcatstudio")
    zipResources(temp_res_dir,formatPath("%s/dragonfall.zip" % asset_target_folder))
    Logging.info("- 生成解压数据信息到Java")
    sedJavaFile(size_to_java)
    Logging.info("- 清除临时文件")
    removeTempDir(temp_res_dir)

def createResources(flavor = 'googleplay'):
    Logging.info("- 开始资源打包")
    asset_target_folder = formatPathCreateIf("%s/%s" % (ANDROID_PROJECT_ROOT,getAssetFolderName(CURRENT_FLAVOR)))
    checkConfigFile(asset_target_folder)
    copyAndPackResources(asset_target_folder,getGameId(flavor))

# main
if __name__ == "__main__":

    Logging.debug(ANDROID_PROJECT_ROOT)
    Logging.debug(APP_ROOT)
    CURRENT_FLAVOR = getFlavor(CURRENT_FLAVOR)
    Logging.debug(CURRENT_FLAVOR)
    Logging.debug(getGameId(CURRENT_FLAVOR))
    Logging.debug(getAssetFolderName(CURRENT_FLAVOR))
    createResources(CURRENT_FLAVOR)
    Logging.warning("- 打包脚本结束")