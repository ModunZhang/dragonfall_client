# encoding: utf-8
# DannyHe
# This scripts only for windows phone on Win32
import functions,sys,os
import subprocess,shutil

Platform="WP"
QUIET_MODE=True # quite mode
DEBUG_MODE=False # debug this scripts

ExportDir=functions.getExportDir()

functions.Logging.info("> Clean Game On Win32") 
functions.Logging.info(">> Clean %s" % ExportDir)
functions.emptyDir(ExportDir)
functions.Logging.info("> Finish Clean Game On Win32") 
sys.exit(0);