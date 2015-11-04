# coding=utf-8
# DannyHe
from basic import *
from batcat import *

ProjDir = getProjDir()
ClientDir = formatPath("%s/dev/scripts/app/map" % ProjDir)
GameDataDir = formatPath("%s/gameData/tmxMap" % ProjDir)

# main
if __name__ == "__main__":
    luaFile = open(formatPath("%s/pvemap.lua" % ClientDir), 'w')
    luaFile.write("return {\n")
    count = 1
    for file in os.listdir(GameDataDir):
        fileInfo = file.split('.')
        filePath = os.path.join(GameDataDir, file)
        outLuaPath = os.path.join(ClientDir, fileInfo[0] + ".lua")
        if fileInfo[-1] != 'tmx':
            continue
        command = "python tmxmap2lua.py -i %s -o %s" % (filePath, outLuaPath)
        executeCommand(command, False)
        luaFile.write("import(\".pve_%d\"),\n" % count)
        count = count + 1
    luaFile.write("}")
    luaFile.close()
