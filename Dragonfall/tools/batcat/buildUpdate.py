# coding=utf-8
# DannyHe
from batcat import *
from basic import *

Platform = "WP"
APP_BUILD_TAG = getAppBuildTag()
APP_VERSION = getAppVersion(Platform)
APP_MIN_VERSION = getAppMinVersion(Platform)
UPDATE_TOOL = getUpdatePythonMainScriptPath()
RES_DEST_DIR = getExportDir(Platform)

Logging.info(APP_BUILD_TAG)
Logging.info(APP_VERSION)
Logging.info(APP_MIN_VERSION)
Logging.info(UPDATE_TOOL)
Logging.info(RES_DEST_DIR)
