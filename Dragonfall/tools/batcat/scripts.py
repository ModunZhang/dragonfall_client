# coding=utf-8
# DannyHe

from batcat import *
from basic import *
import sys
import shutil

#global 占位变量
Platform = ""
NEED_ENCRYPT_SCRIPTS = ""
SCRIPT_COMPILE_TOOL = getScriptsTool()
SCRIPTS_SRC_DIR = getScriptsDir()
SCRIPTS_DEST_DIR = ""
XXTEAKey = getXXTEAKey()
XXTEASign = getXXTEASign()
TEMP_RES_DIR = getTempDir()
ProjDir = getProjDir()
DEBUG_BUILD_USE_LUA_FILE = True  # 不加密的情况下不编译lua为字节码
QUIET_MODE = True  # 安静模式
VERSION_FILE = formatPath("%s/dev/scripts/debug_version.lua" % ProjDir)
CONFIGURATION = ""


def preBuild():
    command = "python build_format_map.py -r rgba4444.lua"
    executeCommand(command, False)
    command = "python build_format_map.py -j jpg_rgb888.lua"
    executeCommand(command, False)
    command = "python build_animation.py -o animation.lua"
    executeCommand(command, False)


def getAllArgs():

    global Platform, NEED_ENCRYPT_SCRIPTS, CONFIGURATION, SCRIPTS_DEST_DIR

    Platform = getPlatform(Platform)

    NEED_ENCRYPT_SCRIPTS = getNeedEncryptScripts(NEED_ENCRYPT_SCRIPTS)

    CONFIGURATION = getConfiguration(CONFIGURATION)

    SCRIPTS_DEST_DIR = getExportScriptsDir(Platform)


def gitDebugVersion():
    version = getAppBuildTag()
    Logging.info("------------------------------------")
    Logging.info("> Debug Version:%s" % str(version))
    Logging.info("------------------------------------")

    versionFile = open(VERSION_FILE, 'w')
    versionData = "local __debugVer = %s\n" % str(version)
    versionFile.write(versionData)
    versionData = "return __debugVer"
    versionFile.write(versionData)
    versionFile.close()


def exportScriptsEncrypt():
    outdir = SCRIPTS_DEST_DIR
    outfile = formatPath("%s/game.zip" % outdir)
    tempfile = formatPath("%s/game.zip" % TEMP_RES_DIR)
    if NEED_ENCRYPT_SCRIPTS:
        Logging.info("开始lua编译")
        comand = "%s -i %s -o %s -e xxtea_zip -ex lua -ek %s -es %s" % (
            SCRIPT_COMPILE_TOOL, SCRIPTS_SRC_DIR, tempfile, XXTEAKey, XXTEASign)
        if QUIET_MODE:
            comand = "%s -q" % comand
        executeCommand(comand, QUIET_MODE)
    else:
        if DEBUG_BUILD_USE_LUA_FILE:
            Logging.info("不编译lua为字节码")
            if not createZipFileWithDirPath(SCRIPTS_SRC_DIR, tempfile, ("DS_Store", "bytes", "tmp")):
                die("压缩lua文件错误")
        else:
            comand = "%s -i %s -o %s -ex lua" % (
                SCRIPT_COMPILE_TOOL, SCRIPTS_SRC_DIR, tempfile)
            if QUIET_MODE:
                comand = "%s -q" % comand
            executeCommand(comand, QUIET_MODE)

    if fileNewer(tempfile, outfile):
        Logging.info("拷贝game.zip " + outdir)
        shutil.copy(tempfile,  outdir)
        Logging.info("拷贝game.zip完成")
    else:
        Logging.info("忽略game.zip")
    Logging.info("清理临时文件")
    removeTempFiles(SCRIPTS_SRC_DIR, "bytes")
    removeTempDir(TEMP_RES_DIR)
    Logging.info("lua编译完成")

# main
if __name__ == "__main__":
    if len(sys.argv) >= 4:
        Platform = sys.argv[1]
        NEED_ENCRYPT_SCRIPTS = sys.argv[2]
        CONFIGURATION = sys.argv[3]
    elif len(sys.argv) >= 3:
        Platform = sys.argv[1]
        NEED_ENCRYPT_SCRIPTS = sys.argv[2]
    elif len(sys.argv) > 1:
        Platform = sys.argv[1]

    getAllArgs()
    if CONFIGURATION == 'Debug':  # debug 模式生成版本lua文件
        gitDebugVersion()
    preBuild()
    exportScriptsEncrypt()
