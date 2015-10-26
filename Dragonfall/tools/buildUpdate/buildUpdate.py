# -*- coding: utf-8 -*-
import os
import json
import string
import subprocess
import sys,getopt
# global m_currentDir
# global app_version
def getFileTag( fullPath ):
	if sys.platform != 'win32':
		bashCommand = "git log -1 --pretty=format:%h -- path " + fullPath
		process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
		output = process.communicate()[0].rstrip()
		return output
	else:
		args = ['git', 'log','-1','--pretty=format:%h','--','path',os.path.normpath(fullPath)]
		process = subprocess.Popen(args,stdout=subprocess.PIPE)
		output = process.communicate()[0].rstrip()
		return output

def getFileGitPath( fullPath ):
	if sys.platform != 'win32':
		bashCommand = "git ls-tree --name-only --full-name HEAD " + fullPath
		process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
		output = process.communicate()[0].rstrip()
		output = output[7:]
		if not output.strip():
			print bashCommand
			print "get path failed:" + fullPath
			sys.exit(1)
		return output
	else:
		args = ['git', 'ls-tree','--name-only','--full-name','HEAD',os.path.normpath(fullPath)]
		process = subprocess.Popen(args,stdout=subprocess.PIPE)
		process.wait()
		output = process.communicate()[0].rstrip()
		if not output.strip():
			print bashCommand
			print "get path failed:" + fullPath
			sys.exit(1)
		index = output.find("update_wp8")
		if index > 0:
			output = output[index + 11:]
		return output

def getFileSize( fullPath ):
	return os.path.getsize(fullPath)

def getFileCrc32( fullPath ):
	if sys.platform != 'win32':
		bashCommand = m_currentDir + "/crc32 " + fullPath
		process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
		output = process.communicate()[0].rstrip()
		return output
	else:
		args = [os.path.normpath(m_currentDir + "/crc32.exe"),os.path.normpath(fullPath)]
		process = subprocess.Popen(args,stdout=subprocess.PIPE)
		output = process.communicate()[0].rstrip()
		return output
	

def browseFolder( fullPath, fileList ):
	for root, dirs, files in os.walk(fullPath):
		for fileName in files:
			if fileName != ".DS_Store" and fileName != "fileList.json" and fileName != "version.json":
				path = root + "/" + fileName
				svnPath = getFileGitPath(path)
				tag = getFileTag(path)
				size = getFileSize(path)
				crc32 = getFileCrc32(path)
				fileList["files"][svnPath] = {
					"tag":tag,
					"size":size,
					"crc32":crc32
				}

def writeJsonFile( fileList ):
	fileJson = json.dumps(fileList)
	jsonFile = open(app_export_dir_name+"/res/fileList.json", 'w')
	jsonFile.write(fileJson)
	jsonFile.close()

# def getAppVersion():
# 	configFile = open("../../update/scripts/config.lua")
# 	appVersion = ""
# 	for line in configFile:
# 		if "CONFIG_APP_VERSION" in line:
# 			line = line.rstrip()
# 			appVersion = line[-6:-1]
# 	configFile.close()
# 	return appVersion

def writeTagJsonFile(jsonList):
	jsonFormat = json.dumps(jsonList)
	jsonFile = open(app_export_dir_name+"/res/version.json", 'w')
	jsonFile.write(jsonFormat)
	jsonFile.close()

#参数检查
def checkAllArgs():
	allargs = ('app_export_dir_name','app_version','app_min_version','app_build_tag')
	for argName in allargs:
		if not argName in globals():
			print "参数错误:"+argName
			sys.exit(1)

if __name__=="__main__":
	try:
		opts,args = getopt.getopt(sys.argv[1:], 'v:m:t:o:',['output=','appVersion=','minVersion=','appTag='])
		for opt, arg in opts:
			if opt in ('-o',"--output"):
				app_export_dir_name = arg
			elif opt in ('-v',"--appVersion"):
				app_version = arg
			elif opt in ('-m',"--minVersion"):
				app_min_version = arg 
			elif opt in ('-t',"--appTag"):
				app_build_tag = arg
	except getopt.GetoptError:
		sys.exit(1)

	checkAllArgs()
	m_currentDir = os.path.dirname(os.path.realpath(__file__))
	fileList = {
		"appVersion":app_version,
		"tag":app_build_tag,
		"appMinVersion":app_min_version,
		"files":{},
	}
	browseFolder(app_export_dir_name+"/res", fileList)
	browseFolder(app_export_dir_name+"/scripts", fileList)
	writeJsonFile(fileList)

	versionList= {
		"appVersion":app_version,
		"tag":app_build_tag,
		"appMinVersion":app_min_version,
	}
	writeTagJsonFile(versionList)