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
RES_COMPILE_TOOL = getResourceTool()  # 加密工具
SCRIPTS_SRC_DIR = getScriptsDir()
SCRIPTS_DEST_DIR = ""
XXTEAKey = getXXTEAKey()
XXTEASign = getXXTEASign()
TEMP_RES_DIR = getTempDir()
ProjDir = getProjDir()
DEBUG_BUILD_USE_LUA_FILE = True  # 不加密的情况下不编译lua为字节码
ENCRYPT_LUA_TO_BYTES = False # 加密的情况下,是否将lua文件编译为字节码
QUIET_MODE = True  # 安静模式
VERSION_FILE = formatPath("%s/dev/scripts/debug_version.lua" % ProjDir)
CONFIGURATION = ""

Logging.DEBUG_MODE = False #debug日志的输出

def preBuild():
    command = "python build_format_map.py -r rgba4444.lua"
    executeCommand(command, False)
    command = "python build_format_map.py -j jpg_rgb888.lua"
    executeCommand(command, False)
    # command = "python build_animation.py -o animation.lua"
    # executeCommand(command, False)


def getAllArgs():

    global Platform, NEED_ENCRYPT_SCRIPTS, CONFIGURATION, SCRIPTS_DEST_DIR

    Platform = getPlatform(Platform)

    NEED_ENCRYPT_SCRIPTS = getNeedEncryptScripts(NEED_ENCRYPT_SCRIPTS)

    CONFIGURATION = getConfiguration(CONFIGURATION)

    SCRIPTS_DEST_DIR = getExportScriptsDir(Platform)


def gitDebugVersion():
    version = getAppBuildTag()
    Logging.debug("------------------------------------")
    Logging.debug("> Debug Version:%s" % str(version))
    Logging.debug("------------------------------------")

    versionFile = open(VERSION_FILE, 'w')
    versionData = "local __debugVer = %s\n" % str(version)
    versionFile.write(versionData)
    versionData = "return __debugVer"
    versionFile.write(versionData)
    versionFile.close()

def CompileResources(in_file_path, out_dir_path):
    comand = "%s -i %s -o %s -ek %s -es %s" % (
        RES_COMPILE_TOOL, in_file_path, out_dir_path, XXTEAKey, XXTEASign)
    if QUIET_MODE:
        comand = "%s -q" % comand
    code, ret = executeCommand(comand, QUIET_MODE)
    return code == 0



# 1.1 如果需要加密,ENCRYPT_LUA_TO_BYTES为True.将lua编译成字节码文件,然后打包成zip.最后后加密zip文件
# 1.2 如果需要加密,ENCRYPT_LUA_TO_BYTES为False.
# 2.1 如果不需要加密,如果DEBUG_BUILD_USE_LUA_FILE为True,将lua源码打包为zip
# 2.2 如果不需要加密,如果DEBUG_BUILD_USE_LUA_FILE为False,将lua编译成字节码文件，然后打包成zip
def exportScriptsEncrypt():
    outdir = SCRIPTS_DEST_DIR
    outfile = formatPath("%s/game.zip" % outdir)
    tempfile = formatPath("%s/game.zip" % TEMP_RES_DIR)
    if NEED_ENCRYPT_SCRIPTS:
        if ENCRYPT_LUA_TO_BYTES:
            Logging.warning("开始lua编译")
            comand = "%s -i %s -o %s -e xxtea_zip -ex lua -ek %s -es %s" % (
                SCRIPT_COMPILE_TOOL, SCRIPTS_SRC_DIR, tempfile, XXTEAKey, XXTEASign)
            if QUIET_MODE:
                comand = "%s -q" % comand
            executeCommand(comand, QUIET_MODE)
        else:
            check_file = formatPath("%s/game_check.zip" % TEMP_RES_DIR)
            Logging.warning("开始lua编译检测Lua代码")
            comand = "%s -i %s -o %s -e xxtea_zip -ex lua -ek %s -es %s" % (
                SCRIPT_COMPILE_TOOL, SCRIPTS_SRC_DIR, check_file, XXTEAKey, XXTEASign)
            if QUIET_MODE:
                comand = "%s -q" % comand
            executeCommand(comand, QUIET_MODE)
            Logging.info("清理临时文件")
            removeTempFiles(SCRIPTS_SRC_DIR, "bytes")
            Logging.info("不编译lua为字节码")
            if not createZipFileWithDirPath(SCRIPTS_SRC_DIR, tempfile, getTempFileExtensions()):
                die("压缩lua文件错误")
            Logging.info("加密打包后的lua源码")
            if not CompileResources(tempfile,outdir):
                die("加密打包后的lua源码失败")
            Logging.info("清理临时文件")
            removeTempFiles(SCRIPTS_SRC_DIR, "bytes")
            removeTempDir(TEMP_RES_DIR)
            Logging.warning("lua编译完成")
            return
    else:
        if DEBUG_BUILD_USE_LUA_FILE:
            Logging.info("不编译lua为字节码")
            if not createZipFileWithDirPath(SCRIPTS_SRC_DIR, tempfile, getTempFileExtensions()):
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
    Logging.warning("lua编译完成")

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