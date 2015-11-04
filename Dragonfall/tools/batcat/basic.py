# coding=utf-8
# DannyHe

import os
import sys
import platform
import subprocess
import shutil
import time
import zipfile
from colorama import *
init(autoreset=True)

# Logging


class Logging:

    DEBUG_MODE = False

    @staticmethod
    def _print(s, color=None):
        if sys.platform != 'win32':
            print color + s
        else:
            print color + s.decode('utf-8').encode("GBK")

    @staticmethod
    def debug(s):
        if Logging.DEBUG_MODE:
            localtime = time.strftime(
                "%a %H:%M:%S", time.localtime(time.time()))
            Logging._print("[DEBUG]%s %s " % (localtime, s), Fore.RESET)

    @staticmethod
    def info(s):
        localtime = time.strftime("%a %H:%M:%S", time.localtime(time.time()))
        Logging._print("[INFO]%s %s " % (localtime, s), Fore.CYAN)

    @staticmethod
    def warning(s):
        localtime = time.strftime("%a %H:%M:%S", time.localtime(time.time()))
        Logging._print("[WARNING]%s %s " % (localtime, s), Fore.YELLOW)

    @staticmethod
    def error(s):
        localtime = time.strftime("%a %H:%M:%S", time.localtime(time.time()))
        Logging._print("[ERROR]%s %s " % (localtime, s), Fore.RED)

# base  common python function


def removeTempFiles(targetDir, fileExtensionName):
    for file in os.listdir(targetDir):
        targetFile = os.path.join(targetDir,  file)
        if os.path.isfile(targetFile):
            if targetFile.split('.')[-1] == fileExtensionName:
                os.remove(targetFile)
        elif os.path.isdir(targetFile):
            removeTempFiles(targetFile, fileExtensionName)


def emptyDir(rootdir):
    for f in os.listdir(rootdir):
        filepath = os.path.join(rootdir, f)
        if os.path.isfile(filepath):
            os.remove(filepath)
        elif os.path.isdir(filepath):
            shutil.rmtree(filepath, True)


def removeTempDir(rootdir):
    emptyDir(rootdir)
    os.rmdir(rootdir)


def formatPath(path):
    return os.path.normpath(path)


def formatPathCreateIf(path):
    return createDirIf(formatPath(path))


def die(msg):
    Logging.error(msg)
    sys.exit(1)


def touch(path):
    open(path, 'w').close()


def executeCommand(command="", quiet=True):
    args = command.split(" ")
    if not quiet:
        Logging.warning(command)
    process = subprocess.Popen(args)
    process.wait()
    if process.returncode != 0:
        die(args)
    else:
        return process.returncode, process.communicate()


def executeCommandGetRet(command="", quiet=True):
    args = command.split(" ")
    if not quiet:
        Logging.warning(command)
    process = subprocess.Popen(
        args, stdout=subprocess.PIPE, stdin=subprocess.PIPE)
    ret = process.communicate()[0]
    process.wait()
    return process.returncode, ret


def executeListCommand(arglist=[], quiet=True):
    if not quiet:
        Logging.warning(arglist)
    process = subprocess.Popen(arglist)
    process.wait()
    if process.returncode != 0:
        die(arglist)
    else:
        return process.returncode, process.communicate()


def platformInfo():
    return sys.platform == 'win32', platform.architecture()[0] == '64bit'


def isWindows():
    return platformInfo()[0]


def is64bit():
    return platformInfo()[1]


def createDirIf(path):
    result = formatPath(path)
    if not os.path.isdir(result):
        os.mkdir(result)
        return result
    else:
        return result

# 比较文件新


def fileNewer(file1, file2):
    if os.path.isfile(file1) and os.path.isfile(file2):
        return os.stat(file1).st_mtime > os.stat(file2).st_mtime or os.stat(file1).st_ctime > os.stat(file2).st_ctime
    if not os.path.isfile(file2) and os.path.isfile(file1):
        return True
    return False

# 压缩zip文件


def createZipFileWithDirPath(dirpath="", outFilePath="archive.zip", excludeExt=()):
    fileList = []
    getZipFileList(fileList, dirpath, dirpath, excludeExt)
    count = len(fileList)
    if count > 0:
        Logging.info("- 创建zip文件:%s 包含%d个文件" % (outFilePath, count))
        zipOut = zipfile.ZipFile(formatPath(
            outFilePath), 'w', zipfile.ZIP_DEFLATED)
        for fileEntity in fileList:
            zipOut.write(fileEntity[0], fileEntity[1])
        zipOut.close()
        return True
    else:
        return False


def getZipFileList(fileList, path, basePath, excludeExt=()):
    currentPath = formatPath(path)
    basePath = formatPath(basePath)
    for file in os.listdir(currentPath):
        sourceFile = os.path.join(currentPath,  file)
        if os.path.isfile(sourceFile):
            if sourceFile.split('.')[-1] in excludeExt:
                Logging.debug(sourceFile.split('.')[-1])
                continue
            if sourceFile.startswith(basePath):
                fileList.append((sourceFile, sourceFile[len(basePath):]))
            else:
                fileList.append((sourceFile, sourceFile))
        elif os.path.isdir(sourceFile):
            getZipFileList(fileList, sourceFile, basePath, excludeExt)

def find_environment_variable(var, quiet=True):
    ret = None
    if not quiet:
        Logging.info("查找脚本环境变量:%s" % var)
    try:
        ret = os.environ[var]
    except Exception:
        if isWindows():
            import _winreg
            try:
                env = None
                env = _winreg.OpenKeyEx(_winreg.HKEY_CURRENT_USER,
                                        'Environment',
                                        0,
                                        _winreg.KEY_READ)

                ret = _winreg.QueryValueEx(env, var)[0]
                _winreg.CloseKey(env)
            except Exception:
                if env:
                    _winreg.CloseKey(env)
                ret = None

    if ret is None:
        die("->%s 未设置\n" % var)
    else:
        if not quiet:
            Logging.info("查找 %s 变量成功 : %s\n" % (var, ret))

    return ret