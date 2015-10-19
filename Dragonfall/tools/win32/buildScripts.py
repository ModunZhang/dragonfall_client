# encoding: utf-8
# DannyHe
# This scripts only for windows phone on Win32
# it will not delete the temp zip etc
# TODO: zip the normal lua file under debug mode,get debug version from git 

import functions,sys,os
import subprocess,shutil

Platform="WP8"
NEED_ENCRYPT_SCRIPTS=True
QUIET_MODE=True # quite mode:no message when compile lua
DEBUG_MODE=False # debug this scripts

SCRIPT_COMPILE_TOOL=functions.getScriptsTool()
SCRIPTS_SRC_DIR=functions.getScriptsDir()
SCRIPTS_DEST_DIR=functions.getExportScriptsDir()
XXTEAKey=functions.getXXTEAKey()
XXTEASign=functions.getXXTEASign()
TEMP_RES_DIR=functions.getTempDir()
DOCROOT=os.getcwd();
ProjDir=functions.getProjDir()
VERSION_FILE=functions.formatPath("%s/dev/scripts/debug_version.lua" % ProjDir)

if DEBUG_MODE:
	functions.Logging.debug("------------Debug Start------------")
	functions.Logging.debug(SCRIPT_COMPILE_TOOL)
	functions.Logging.debug(SCRIPTS_SRC_DIR)
	functions.Logging.debug(SCRIPTS_DEST_DIR)
	functions.Logging.debug(XXTEAKey)
	functions.Logging.debug(XXTEASign)
	functions.Logging.debug(TEMP_RES_DIR)
	functions.Logging.debug(functions.getTempDir())
	functions.Logging.debug(DOCROOT)
	functions.Logging.debug(ProjDir)
	functions.Logging.debug(VERSION_FILE)
	functions.Logging.debug(os.path.exists(VERSION_FILE))
	functions.Logging.debug("------------Debug End------------")

#export lua 
def exportScriptsEncrypt():

	outdir=SCRIPTS_DEST_DIR
	outfile=functions.formatPath("%s/game.zip" % outdir)
	tempfile=functions.formatPath("%s/game.zip" % TEMP_RES_DIR)
	if NEED_ENCRYPT_SCRIPTS:
		functions.Logging.info("-- Compile Lua Begin")
		args = [SCRIPT_COMPILE_TOOL, '-i',SCRIPTS_SRC_DIR,'-o',tempfile,'-e','xxtea_zip','-ex','lua','-ek',XXTEAKey,'-es',XXTEASign]
		if QUIET_MODE:
			args = [SCRIPT_COMPILE_TOOL, '-i',SCRIPTS_SRC_DIR,'-o',tempfile,'-e','xxtea_zip','-ex','lua','-ek',XXTEAKey,'-es',XXTEASign,'-q']
		p = subprocess.Popen(args)
		p.wait()
		if p.returncode != 0:
			functions.die("-- Compile Lua failed!")
		else:
			functions.Logging.info("-- Compile Lua Success!")
	else:
		functions.die("-- Not support the config")
	functions.Logging.info("-- Copy game.zip " + outdir)
	shutil.copy(tempfile,  outdir)
	functions.Logging.info("-- Copy Success!")


# main
if __name__=="__main__":
	exportScriptsEncrypt();
	functions.Logging.info("-- Remove temp files");
	functions.removeTempFiles(SCRIPTS_SRC_DIR,"bytes");
	functions.removeTempDir(TEMP_RES_DIR)
	functions.Logging.info("-- Compile Lua end!");
	sys.exit(0);