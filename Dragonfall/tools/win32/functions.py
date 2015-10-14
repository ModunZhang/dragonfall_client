# encoding: utf-8
# DannyHe
# This scripts only for windows phone on Win32
import os
import sys
import urllib
from tarfile import TarFile
import shutil
import win32Color
import tempfile

_TempDir_ = ""
###########################Logging###########################
class Logging:
    RED     = '\033[31m'
    GREEN   = '\033[32m'
    YELLOW  = '\033[33m'
    MAGENTA = '\033[35m'
    RESET   = '\033[0m'

    if sys.platform == 'win32':
        RED     = win32Color.FOREGROUND_RED | win32Color.FOREGROUND_INTENSITY
        GREEN   = win32Color.FOREGROUND_GREEN | win32Color.FOREGROUND_INTENSITY
        YELLOW  = win32Color.FOREGROUND_INTENSITY | win32Color.FOREGROUND_INTENSITY 
        MAGENTA = win32Color.FOREGROUND_INTENSITY | win32Color.FOREGROUND_INTENSITY
        RESET   = win32Color.FOREGROUND_RED | win32Color.FOREGROUND_GREEN | win32Color.FOREGROUND_BLUE

    @staticmethod
    def _print(s, color=None):
        if color and sys.stdout.isatty() and sys.platform != 'win32':
            print color + s + Logging.RESET
        else:
            clr = win32Color.Color()
            clr.print_color_with_args(s,color)
    @staticmethod
    def debug(s):
        Logging._print(s, Logging.MAGENTA)

    @staticmethod
    def info(s):
        Logging._print(s, Logging.GREEN)

    @staticmethod
    def warning(s):
        Logging._print(s, Logging.YELLOW)

    @staticmethod
    def error(s):
        Logging._print(s, Logging.RED)


def die(msg):
    Logging.error(msg)
    sys.exit(1)

def touch(path):
    open(path, 'w').close()

###########################functions###########################

def formatPath(path):
    return os.path.normpath(path);

def getProjDir():
    current = os.getcwd();
    return os.path.normpath("%s/../.." % current);

def getResourceDir():
    root_dir=getProjDir();
    return os.path.normpath("%s/dev_wp8/res" % root_dir);

def getXXTEAKey():
    return "Cbcm78HuH60MCfA7"

def getXXTEASign():
    return "XXTEA"

def getScriptsDir():
    root_dir=getProjDir(); 
    return os.path.normpath("%s/dev_wp8/scripts" % root_dir);

def getExportDir():
    root_dir=getProjDir(); 
    result=os.path.normpath("%s/update_wp8" % root_dir);
    return result

def getScriptsTool():
    root_dir=getProjDir();
    return os.path.normpath("%s/../external/quick/bin/compile_scripts.bat" % root_dir);

def getResourceTool():
    root_dir=getProjDir();
    return formatPath("%s/../external/quick/bin/pack_files.bat" % root_dir)

def getExportScriptsDir():
    root_dir=getExportDir();
    result=formatPath("%s/scripts" % root_dir);
    if not os.path.isdir(result):
        os.mkdir(result)
        return result;
    else:
        return result;
        
def getTempDir():
    global _TempDir_
    if _TempDir_ == "":
        _TempDir_ = tempfile.mkdtemp()
    return _TempDir_ 

def getResourceDir():
    root_dir=getProjDir(); 
    return formatPath("%s/dev_wp8/res" % root_dir);

def getExportResourcesDir():
    root_dir=getExportDir();
    result=formatPath("%s/res" % root_dir)
    if not os.path.isdir(result):
        os.mkdir(result)
        return result;
    else:
        return result;