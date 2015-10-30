# encoding: utf-8
# DannyHe
# This scripts only for windows phone on Win32
import functions,sys,os,subprocess

Platform="WP8"
UPDATE_TOOL=functions.getUpdatePythonMainScriptPath()
RES_DEST_DIR=functions.getExportDir()
APP_BUILD_TAG=functions.getAppBuildTag()
APP_VERSION=functions.getAppVersion()
APP_MIN_VERSION=functions.getAppMinVersion()

functions.Logging.info("> build update json data")
functions.Logging.info("> APP_VERSION:%s APP_MIN_VERSION:%s APP_BUILD_TAG:%s" % (APP_VERSION,APP_MIN_VERSION,APP_BUILD_TAG))
args = ['python',UPDATE_TOOL,'--appVersion=' + APP_VERSION,'--minVersion=' + APP_MIN_VERSION,'--appTag='+APP_BUILD_TAG,'--output=' + RES_DEST_DIR]
p = subprocess.Popen(args)
p.wait()
if p.returncode != 0:
	functions.die("> build update data failed!")
else:
	functions.Logging.info("> build update data success!")