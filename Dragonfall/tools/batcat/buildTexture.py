# coding=utf-8
# DannyHe
from basic import *
from batcat import *

NATIVEPLATFORMS = ("iOS", "Player", "Android", "WP")

RES_SRC_DIR = getResourceDir()  # 资源源目录
CURRENT_DIR = os.getcwd()
PNG_2_JPG_DIR = formatPath("%s/tools/png2jpg" % getProjDir())

def getNativePlatform(args=""):
    result = args
    message = "Platform :\n"
    for index in range(len(NATIVEPLATFORMS)):
        message = message + str(index + 1) + "." + \
            NATIVEPLATFORMS[index] + "\n"
    while not result in NATIVEPLATFORMS:
        opt = raw_input(message)
        if opt.isdigit():
            index = int(opt) - 1
            if index in range(len(NATIVEPLATFORMS)):
                result = NATIVEPLATFORMS[index]
    return result

def cleanImage(Platform):
    if Platform == 'iOS':
        DIR_PATH =  formatPath("%s/images/_Compressed" % RES_SRC_DIR)
    elif Platform == 'Android':
        DIR_PATH =  formatPath("%s/images/_Compressed_android" % RES_SRC_DIR)
    elif Platform == 'WP':
        DIR_PATH =  formatPath("%s/images/_Compressed_wp" % RES_SRC_DIR)
    elif Platform == 'Player':
        DIR_PATH = formatPath("%s/images/_Compressed_mac" % RES_SRC_DIR )
    Logging.warning("清理贴图 %s" % DIR_PATH)
    emptyDir(DIR_PATH)

def exportJPGTextureIf(Platform):
    if Platform != 'Android':
        return None
    command = "java -classpath ./png2jpg.jar -Xmx512m editor.MainFrame"
    os.chdir(PNG_2_JPG_DIR)
    executeCommand(command,not Logging.DEBUG_MODE)
    os.chdir(CURRENT_DIR)    

Platform = ""

if __name__ == "__main__":
    if len(sys.argv) > 1:
        Platform = sys.argv[1]
    Platform = getNativePlatform(Platform)
    ProjDir = getProjDir()
    TPS_FILES_DIR = ""
    if Platform == 'iOS':
        TPS_FILES_DIR = formatPath(
            "%s/PackImages/TexturePackerProj/iOS" % ProjDir)
    elif Platform == 'Android':
        TPS_FILES_DIR = formatPath(
            "%s/PackImages/TexturePackerProj/android" % ProjDir)
    elif Platform == 'WP':
        TPS_FILES_DIR = formatPath(
            "%s/PackImages/TexturePackerProj/wp" % ProjDir)
    elif Platform == 'Player':
        TPS_FILES_DIR = formatPath(
        "%s/PackImages/TexturePackerProj/player" % ProjDir)

    cleanImage(Platform)
    Logging.warning("开始导出贴图 %s" % Platform)
    for file in os.listdir(TPS_FILES_DIR):
        tps = os.path.join(TPS_FILES_DIR,  file)
        if tps.split('.')[-1] == 'tps':
            command = "TexturePacker %s" % tps
            executeCommand(command, False)
    exportJPGTextureIf(Platform)
    Logging.warning("导出贴图完成 %s" % Platform)
