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
SCRIPTS_SRC_DIR = ""
RES_SRC_DIR = ""


def getArgs(Platform):
    if Platform == 'iOS':
        return "%s/images/_Compressed" % RES_SRC_DIR, "%s/app/texture_data_iOS.lua" % SCRIPTS_SRC_DIR
    elif Platform == 'Player' or Platform == 'Android':
        return "%s/images/_Compressed_mac" % RES_SRC_DIR, "%s/app/texture_data.lua" % SCRIPTS_SRC_DIR
    elif Platform == 'WP':
        return "%s/images/_Compressed_wp" % RES_SRC_DIR, "%s/app/texture_data_wp.lua" % SCRIPTS_SRC_DIR

# main
if __name__ == "__main__":
    if len(sys.argv) > 1:
        Platform = sys.argv[1]
    Platform = getNativePlatform(Platform)
    SCRIPTS_SRC_DIR = getScriptsDir()
    RES_SRC_DIR = getResourceDir()

    plist_dir_path, export_lua_path = getArgs(Platform)

    command = 'python plist_texture_data_to_lua.py -p %s -o %s' % (
        plist_dir_path, export_lua_path)

    executeCommand(command)
