# encoding: utf-8
# DannyHe
# This scripts only for windows phone on Win32
import os
import sys
import urllib
from tarfile import TarFile
import shutil
import tempfile
import platform

_TempDir_ = ""
###########################Logging###########################
class Logging:
    RED     = '\033[31m'
    GREEN   = '\033[32m'
    YELLOW  = '\033[33m'
    MAGENTA = '\033[35m'
    RESET   = '\033[0m'

    @staticmethod
    def _print(s, color=None):
        if color and sys.stdout.isatty() and sys.platform != 'win32':
            print color + s + Logging.RESET
        else:
            print s
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

def getXXTEAKey():
    return "Cbcm78HuH60MCfA7"

def getXXTEASign():
    return "XXTEA"

def getResourceDir():
    root_dir=getProjDir();
    return os.path.normpath("%s/dev/res" % root_dir);

def getScriptsDir():
    root_dir=getProjDir(); 
    return os.path.normpath("%s/dev/scripts" % root_dir);

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

def getExportResourcesDir():
    root_dir=getExportDir();
    result=formatPath("%s/res" % root_dir)
    if not os.path.isdir(result):
        os.mkdir(result)
        return result;
    else:
        return result;

def removeTempFiles(targetDir,fileExtensionName):
     for file in os.listdir(targetDir): 
        targetFile = os.path.join(targetDir,  file) 
        if os.path.isfile(targetFile): 
            if targetFile.split('.')[-1] == fileExtensionName:
                os.remove(targetFile)
        elif os.path.isdir(targetFile):
            removeTempFiles(targetFile,fileExtensionName)

def emptyDir(rootdir):
    for f in os.listdir(rootdir):
        filepath = os.path.join( rootdir, f )
        if os.path.isfile(filepath):
            os.remove(filepath)
        elif os.path.isdir(filepath):
            shutil.rmtree(filepath,True)

def removeTempDir(rootdir):
    emptyDir(rootdir)
    os.rmdir(rootdir) 

# DXT texture compression and real-time transcoding library  
# https://code.google.com/p/crunch/
# eg. cocos2dx: crunch -file ui_pvr_1.png -fileformat dds /DXT5A /rescalemode nearest /mipMode None /out .\test\ui_pvr_1.png
def getDXTConvertTool():
    bit = platform.architecture()[0]
    root_dir=getProjDir();
    if bit == '64bit':
        return formatPath("%s/tools/TextureTools/win32/crunch_x64.exe" % root_dir)
    elif bit == '32bit':
        return formatPath("%s/tools/TextureTools/win32/crunch.exe" % root_dir)

def getETCCompressTool():
    root_dir=getProjDir();
    return formatPath("%s/tools/TextureTools/win32/CompressETCTexture.exe" % root_dir)
