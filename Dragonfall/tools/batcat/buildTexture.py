# coding=utf-8
# DannyHe
from basic import *
from batcat import *

NATIVEPLATFORMS = ("iOS", "Player", "Android", "WP")


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

Platform = ""

if __name__ == "__main__":
    if len(sys.argv) > 1:
        Platform = sys.argv[1]
    Platform = getPlatform(Platform)
    ProjDir = getProjDir()
    TPS_FILES_DIR = formatPath(
        "%s/PackImages/TexturePackerProj/player" % ProjDir)
    if Platform == 'iOS' or Platform == 'Android':
        TPS_FILES_DIR = formatPath(
            "%s/PackImages/TexturePackerProj/iOS" % ProjDir)
    elif Platform == 'WP':
        TPS_FILES_DIR = formatPath(
            "%s/PackImages/TexturePackerProj/wp" % ProjDir)

    Logging.warning("开始导出贴图 %s" % Platform)

    for file in os.listdir(TPS_FILES_DIR):
        tps = os.path.join(TPS_FILES_DIR,  file)
        if tps.split('.')[-1] == 'tps':
            command = "TexturePacker %s" % tps
            executeCommand(command, False)

    Logging.warning("导出贴图完成 %s" % Platform)
