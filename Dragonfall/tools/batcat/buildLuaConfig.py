##coding=utf-8
#DannyHe
from batcat import *
from basic import * 

ProjDir = getProjDir()
ClientDir = formatPath("%s/app/datas" % getScriptsDir())
GameDataDir = formatPath("%s/gameData" % ProjDir)

formatPathCreateIf(ClientDir)
command = 'python %s/tools/buildGameData/buildGameData.py %s %s client' % (ProjDir,GameDataDir,ClientDir)

Logging.info("开始导出lua配置文件")
executeCommand(command,True)
Logging.info("导出lua配置文件结束")
