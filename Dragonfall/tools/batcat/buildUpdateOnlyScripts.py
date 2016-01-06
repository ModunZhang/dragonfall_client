# coding=utf-8
# DannyHe
from batcat import *
from basic import *
import os

Logging.DEBUG_MODE = True

Platform = ""
APP_VERSION = ""
APP_MIN_VERSION = ""
APP_BUILD_TAG = ""
UPDATE_TOOL = getUpdatePythonMainScriptPath()
RES_DEST_DIR = ""
CURRENT_DIR = os.getcwd()
PROJ_DIR = getProjDir()


def getArgs():
    global Platform, APP_VERSION, APP_MIN_VERSION, RES_DEST_DIR

    Platform = getPlatform(Platform)
    APP_VERSION = getAppVersion(Platform)
    APP_MIN_VERSION = getAppMinVersion(Platform)
    RES_DEST_DIR = getExportDir(Platform)

    Logging.debug(Platform)
    Logging.debug(APP_VERSION)
    Logging.debug(APP_MIN_VERSION)
    Logging.debug(UPDATE_TOOL)
    Logging.debug(RES_DEST_DIR)


def buildGame():
    # Logging.info("---------------- 清理文件")
    # command = "python cleanGame.py %s" % Platform
    # executeCommand(command, not Logging.DEBUG_MODE)
    Logging.info("---------------- 编译代码")
    command = "python scripts.py %s True Release" % Platform
    executeCommand(command, not Logging.DEBUG_MODE)


def commitBuildGame():
    Logging.info("---------------- 提交dev和导出目录")
    os.chdir(PROJ_DIR)
    msg = "commit any uncommitted files %s %s" % (Platform, APP_VERSION)
    command = "git add dev %s" % os.path.basename(RES_DEST_DIR)
    executeCommand(command,not Logging.DEBUG_MODE)
    command = ["git", "commit", "-m", msg]
    executeListCommand(command,not Logging.DEBUG_MODE)
    os.chdir(CURRENT_DIR)


def buildFileList():
	Logging.info("---------------- 检查更新")
	global APP_BUILD_TAG
	APP_BUILD_TAG = getAppBuildTag()
	Logging.debug(APP_BUILD_TAG)
	command = "python %s --appVersion=%s --minVersion=%s --appTag=%s --output=%s --platform=%s" % (UPDATE_TOOL,APP_VERSION,APP_MIN_VERSION,APP_BUILD_TAG,RES_DEST_DIR,Platform)
	executeCommand(command,not Logging.DEBUG_MODE)

def commitUpdateFileList():
	Logging.info("---------------- 提交导出目录")
	os.chdir(RES_DEST_DIR)
	command = "git add --all ."
	executeCommand(command,not Logging.DEBUG_MODE)
	msg = "update new version %s %s min:%s tag:%s" % (Platform, APP_VERSION,APP_MIN_VERSION,APP_BUILD_TAG)
	command = ["git", "commit", "-m", msg]
	executeListCommand(command,not Logging.DEBUG_MODE)
	os.chdir(CURRENT_DIR)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        Platform = sys.argv[1]
    getArgs()
    buildGame()
    commitBuildGame()
    buildFileList()
    commitUpdateFileList()
    Logging.info("提交成功 手动push到远程!")