# coding=utf-8
# DannyHe
from batcat import *
from basic import *
import os,json

Logging.DEBUG_MODE = True #debug日志的输出

Platform = ""
CONFIGURATION = ""
BRANCH_NAME = ""
CURRENT_DIR = os.getcwd()
UPDATE_SOURCE_DIR = ""

PATH_OF_GIT_AUTOUPDATE = formatPath(find_environment_variable("GIT_REPOSITOTY_AUTO_UPDATE",not Logging.DEBUG_MODE))
TARGET_PATH = formatPath("%s" % PATH_OF_GIT_AUTOUPDATE)
if isWindows():
	TARGET_PATH = "%s" % find_environment_variable("GIT_REPOSITOTY_AUTO_UPDATE_CYGWIN",not Logging.DEBUG_MODE)


def pullAutoUpdateRepositoty():
	os.chdir(PATH_OF_GIT_AUTOUPDATE)
	command = "git reset --hard HEAD"
	executeCommand(command,not Logging.DEBUG_MODE)
	command = "git clean -df"
	executeCommand(command,not Logging.DEBUG_MODE)
	command = "git checkout %s" % BRANCH_NAME
	executeCommand(command,not Logging.DEBUG_MODE)
	command = "git pull"
	executeCommand(command,not Logging.DEBUG_MODE)
	os.chdir(CURRENT_DIR)


def rsyncAllFiles():
	if isWindows():
		command = "rsync -ravc --exclude=.DS_Store* --exclude=.git/ --exclude=.gitignore ./ %s --delete-after --perms --chmod=a=rw,Da+x" % TARGET_PATH
	else:
		command = "rsync -ravc --exclude=.DS_Store* --exclude=.git/ --exclude=.gitignore ./ %s --delete-after" % TARGET_PATH
	os.chdir(UPDATE_SOURCE_DIR)
	executeCommand(command,not Logging.DEBUG_MODE)
	os.chdir(CURRENT_DIR)

def pushAutoUpdateDataToGit():
	os.chdir(PATH_OF_GIT_AUTOUPDATE)
	command = "git add --all"
	executeCommand(command,not Logging.DEBUG_MODE)
	msg = readVersionInfoMessage()
	command = ["git", "commit", "-m", msg]
	executeListCommand(command,not Logging.DEBUG_MODE)
	command = "git push origin %s" % BRANCH_NAME
	executeCommand(command,not Logging.DEBUG_MODE)
	os.chdir(CURRENT_DIR)

def readVersionInfoMessage():
	filePath = formatPath("%s/res/version.json" % UPDATE_SOURCE_DIR)
	jsonData = open(filePath).read()
	jsonObj = json.loads(jsonData)
	msg = "%s %s:appVersion:%s appMinVersion:%s tag:%s " % (CONFIGURATION,jsonObj['platform'],jsonObj['appVersion'],jsonObj['appMinVersion'],jsonObj['tag'])
	return msg

# main
if __name__ == "__main__":
	if len(sys.argv) > 2:
		Platform = sys.argv[1]
		CONFIGURATION = sys.argv[2]
	elif len(sys.argv) > 1:
		Platform = sys.argv[1]
	Platform = getPlatform(Platform)
	CONFIGURATION = getConfiguration(CONFIGURATION)
	BRANCH_NAME = gitBranchNameOfUpdateGit(Platform,CONFIGURATION)
	UPDATE_SOURCE_DIR = getExportDir(Platform)

	Logging.debug(Platform)
	Logging.debug(CONFIGURATION)
	Logging.debug(BRANCH_NAME)
	Logging.debug(UPDATE_SOURCE_DIR)
	Logging.debug(PATH_OF_GIT_AUTOUPDATE)
	Logging.debug(TARGET_PATH)

	Logging.info("更新仓库内容")
	pullAutoUpdateRepositoty()
	Logging.info("同步更新文件")
	rsyncAllFiles()
	Logging.info("推送仓库变动到github")
	pushAutoUpdateDataToGit()
	Logging.warning("同步更新文件结束")