#coding=utf-8
# DannyHe
from basic import *
import os,string
import tempfile

PLATFORMS=("iOS","Android","WP")
EncryptTypes=("True","False")
CONFIGURATIONS=("Debug","Release","Hotfix")

_TempDir_ = ""
#base 

def getTempDir():
    global _TempDir_
    if _TempDir_ == "":
        _TempDir_ = tempfile.mkdtemp()
    return _TempDir_ 

#获取平台
def getPlatform(args = ""):
	result = args
	message = "Platform :\n"
	for index in range(len(PLATFORMS)):
		message = message + str(index + 1) + "." + PLATFORMS[index] + "\n"
	while not result in PLATFORMS:
		opt = raw_input(message)
		if opt.isdigit():
			index = int(opt) - 1
			if index in range(len(PLATFORMS)):
				result = PLATFORMS[index]
	return result

#获取是否加密的选项
def getNeedEncryptScripts(args = ""):
	result = args
	message = "Scripts Encrypt:\n"
	for index in range(len(EncryptTypes)):
		message = message + str(index + 1) + "." + EncryptTypes[index] + "\n"
	while not result in EncryptTypes:
		opt = raw_input(message)
		if opt.isdigit():
			index = int(opt) - 1
			if index in range(len(EncryptTypes)):
				result = EncryptTypes[index]
	return result == 'True'

def getNeedEncryptResources(args = ""):
	result = args
	message = "Resources Encrypt:\n"
	for index in range(len(EncryptTypes)):
		message = message + str(index + 1) + "." + EncryptTypes[index] + "\n"
	while not result in EncryptTypes:
		opt = raw_input(message)
		if opt.isdigit():
			index = int(opt) - 1
			if index in range(len(EncryptTypes)):
				result = EncryptTypes[index]
	return result == 'True'

def checkPlatform(platform):
	if not platform in PLATFORMS:
		die("platform:%s is not support!" % platform)

# 获取项目模式:debug release hotfix
def getConfiguration(args = ""):
	result = args
	message = "Configuration:\n"
	for index in range(len(CONFIGURATIONS)):
		message = message + str(index + 1) + "." + CONFIGURATIONS[index] + "\n"
	while not result in CONFIGURATIONS:
		opt = raw_input(message)
		if opt.isdigit():
			index = int(opt) - 1
			if index in range(len(CONFIGURATIONS)):
				result = CONFIGURATIONS[index]
	return result

#文件加密key
def getXXTEAKey():
    return "Cbcm78HuH60MCfA7"

def getXXTEASign():
    return "XXTEA"

#项目根目录
def getProjDir():
    current = os.getcwd();
    return formatPath("%s/../.." % current);

#开发资源目录
def getResourceDir():
    root_dir=getProjDir();
    return formatPath("%s/dev/res" % root_dir);

#开发脚本目录
def getScriptsDir():
    root_dir=getProjDir(); 
    return formatPath("%s/dev/scripts" % root_dir);

#获取工具脚本的目录
def getExtraToolPath():
	root_dir=getProjDir(); 
	return formatPath("%s/../external" % root_dir);

# quick的脚本工具
def getScriptsTool():
	root_dir=getExtraToolPath()
	if isWindows():
		return formatPath("%s/quick/bin/compile_scripts.bat" % root_dir)
	else:
		return formatPath("%s/quick/bin/compile_scripts.sh" % root_dir)

# quick的资源工具
def getResourceTool():
	root_dir=getExtraToolPath()
	if isWindows():
		return formatPath("%s/quick/bin/pack_files.bat" % root_dir)
	else:
		return formatPath("%s/quick/bin/pack_files.sh" % root_dir)

#导出项目的根目录
def getExportDir(platform = 'iOS'):
	checkPlatform(platform)
	dir_name = 'update'
	if platform == 'Android':
		dir_name = 'update_android'
	elif platform == 'WP':
		dir_name = 'update_wp8'
	return formatPathCreateIf("%s/%s" % (getProjDir(),dir_name))

#导出项目的脚本目录
def getExportScriptsDir(platform = 'iOS'):
	result = "%s/scripts" % getExportDir(platform)
	return formatPathCreateIf(result)

#导出项目的资源目录
def getExportResourcesDir(platform = 'iOS'):
	result = "%s/res" % getExportDir(platform)
	return formatPathCreateIf(result)

#获取版本的tag号
def getAppBuildTag():
    args=['git','rev-list','HEAD','--count']
    process = subprocess.Popen(args,stdout=subprocess.PIPE)
    output = process.communicate()[0].rstrip()
    return output

#自定义的纹理压缩
def getETCCompressTool():
    root_dir=getProjDir()
    if isWindows():
    	return formatPath("%s/tools/TextureTools/win32/CompressETCTexture.exe" % root_dir) 
    else:
    	return formatPath("%s/tools/TextureTools/CompressETCTexture" % root_dir) 

#DDS压缩软件(windows)
def getDXTConvertTool(platform):
	if not isWindows() or platform != 'WP':
		die("仅支持windows下进行windows phone平台的dds文件压缩!")
	root_dir=getProjDir()
	if is64bit():
		return formatPath("%s/tools/TextureTools/win32/crunch_x64.exe" % root_dir)
	else:
		return formatPath("%s/tools/TextureTools/win32/crunch.exe" % root_dir)

def getPVRTexTool():
	root_dir=getProjDir()
	if isWindows():
		if is64bit():
			return formatPath("%s/tools/TextureTools/win32/PVRTexToolCLI_x64.exe" % root_dir)
		else:
			return formatPath("%s/tools/TextureTools/win32/PVRTexToolCLI.exe" % root_dir)
	else:
		return formatPath("%s/tools/TextureTools/PVRTexToolCLI" % root_dir)

#windows下必须提前安装convert
#http://www.imagemagick.org/script/binary-releases.php
def getConvertTool():
	root_dir=getProjDir()
	if isWindows():
		return "convert"
	else:
		return formatPath("%s/tools/TextureTools/convert" % root_dir)

def getWin32SedPath():
	if not isWindows():
		die("该版本Sed只能在windows下使用")
	root_dir=getProjDir()
	return formatPath("%s/tools/win32/sed/sed.exe" % root_dir)

def getProjConfigPath(platform):
	platformProjectRoot = getPlatformProjectRoot(platform)
	if platform == 'iOS':
		return formatPath("%s/ios/Info.plist" % platformProjectRoot)
	elif platform == 'Android':
		return formatPath("%s/AndroidManifest.xml" % platformProjectRoot)
	elif platform == 'WP':
		return formatPath("%s/App.WindowsPhone/Package.appxmanifest" % platformProjectRoot)

def getWPAppXmlPath():
	platformProjectRoot = getPlatformProjectRoot("WP")
	return formatPath("%s/App.Shared/App.xaml" % platformProjectRoot)

def getPlatformProjectRoot(platform):
	root_dir=getProjDir()
	if platform == 'iOS':
		return formatPath("%s/frameworks/runtime-src/proj.ios_mac" % root_dir)
	elif platform == 'Android':
		return formatPath("%s/frameworks/runtime-src/proj.android" % root_dir)
	elif platform == 'WP':
		return formatPath("%s/frameworks/runtime-src/proj.win8.1-universal" % root_dir)

def getAppVersion(platform):
	command = "python readProject.py -p %s -v" % platform
	code,ret = executeCommand(command)
	return ret[0].rstrip()

def getAppMinVersion(platform):
	command = "python readProject.py -p %s -m" % platform
	code,ret = executeCommand(command)
	return ret[0].rstrip()
	
def getUpdatePythonMainScriptPath():
    root_dir=getProjDir();
    return formatPath("%s/tools/buildUpdate/buildUpdate.py" % root_dir)