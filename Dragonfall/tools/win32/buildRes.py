# encoding: utf-8
# DannyHe
# This scripts only for windows phone on Win32

import functions,sys,os
import subprocess,shutil

Platform="WP"
QUIET_MODE=True # quite mode
DEBUG_MODE=False # debug this scripts

NEED_ENCRYPT_RES=True

RES_COMPILE_TOOL=functions.getResourceTool()
RES_SRC_DIR=functions.getResourceDir()
RES_DEST_DIR=functions.getExportResourcesDir()
XXTEAKey=functions.getXXTEAKey()
XXTEASign=functions.getXXTEASign()
TEMP_RES_DIR=functions.getTempDir()


if DEBUG_MODE:
	functions.Logging.debug("------------Debug Start------------")
	functions.Logging.debug(RES_COMPILE_TOOL)
	functions.Logging.debug(RES_SRC_DIR)
	functions.Logging.debug(RES_DEST_DIR)
	functions.Logging.debug(XXTEAKey)
	functions.Logging.debug(XXTEASign)
	functions.Logging.debug(TEMP_RES_DIR)
	functions.Logging.debug("------------Debug End------------")

def exportImagesRes(image_dir_path):
	outdir=os.path.join(RES_DEST_DIR,os.path.basename(image_dir_path)) #xxx/images/
	functions.Logging.info("-->%s" % image_dir_path)
	for file in os.listdir(image_dir_path):
		sourceFile = os.path.join(image_dir_path,  file) 
		targetFile = os.path.join(outdir,  file)
		if os.path.isfile(sourceFile):
			fileExt=sourceFile.split('.')[-1]
			if (fileExt == 'png' or fileExt == 'jpg') and fileExt != 'tmp':
				if NEED_ENCRYPT_RES:
					args = [RES_COMPILE_TOOL, '-i',sourceFile,'-o',outdir,'-ek',XXTEAKey,'-es',XXTEASign]
					if QUIET_MODE:
						args = [RES_COMPILE_TOOL, '-i',sourceFile,'-o',outdir,'-ek',XXTEAKey,'-es',XXTEASign,'-q']
					p = subprocess.Popen(args)
					p.wait()
					if p.returncode != 0:
						functions.Logging.error("-- RES_COMPILE_TOOL failed!--%s" % sourceFile)
				else:
					if DEBUG_MODE:
						functions.Logging.debug("copy images %s -- %s" %(sourceFile,outdir))
					shutil.copy(sourceFile,  outdir)
		elif os.path.isdir(sourceFile):
			dir_name=os.path.basename(sourceFile)
			if dir_name == '_Compressed_mac'or dir_name == 'rgba444_single' or dir_name == '_CanCompress':
				functions.Logging.info("-->%s" % dir_name)
				for image_file in os.listdir(sourceFile):
					image_sourceFile = os.path.join(sourceFile,  image_file) 
					image_targetFile = os.path.join(outdir,  image_file)
					image_outdir = os.path.dirname(image_targetFile)
					if os.path.isfile(image_sourceFile):
						fileExt=image_sourceFile.split('.')[-1]
						if fileExt != 'tmp':
							if NEED_ENCRYPT_RES:
								args = [RES_COMPILE_TOOL, '-i',image_sourceFile,'-o',image_outdir,'-ek',XXTEAKey,'-es',XXTEASign]
								if QUIET_MODE:
									args = [RES_COMPILE_TOOL, '-i',image_sourceFile,'-o',image_outdir,'-ek',XXTEAKey,'-es',XXTEASign,'-q']
								p = subprocess.Popen(args)
								p.wait()
								if p.returncode != 0:
									functions.Logging.error("-- RES_COMPILE_TOOL failed!--%s" % image_sourceFile)
							else:
								if DEBUG_MODE:
									functions.Logging.debug("copy images %s -- %s" %(image_sourceFile,image_outdir))
								shutil.copy(image_sourceFile,image_outdir)

			else:
				functions.Logging.info("not handle dir:%s" % sourceFile)

#simple copy file not handle
def exportRes(sourceDir,  targetDir): 
    if sourceDir.find(".svn") > 0: 
        return 
    for file in os.listdir(sourceDir): 
        sourceFile = os.path.join(sourceDir,  file) 
        targetFile = os.path.join(targetDir,  file) 
        
        if os.path.isfile(sourceFile): #file in res
        	outdir = os.path.dirname(targetFile)
        	fileExt=sourceFile.split('.')[-1]
        	functions.Logging.info("-->%s %s" % (fileExt,sourceFile))
        	if not os.path.exists(outdir):
        		os.makedirs(outdir)
        	if fileExt != 'po':
        		shutil.copy(sourceFile,  outdir)
        elif os.path.isdir(sourceFile):
        	dir_name=os.path.basename(sourceFile)
        	functions.Logging.info("-->%s" % dir_name)
        	if dir_name == 'images':
        		exportImagesRes(sourceFile)
        	elif dir_name == 'animations':
        		functions.Logging.debug("*animations")
        	elif dir_name == 'animations_mac':
        		functions.Logging.debug("*animations_mac")
        	else:
				exportRes(sourceFile, targetFile)

if __name__=="__main__":
	functions.Logging.info("-->begin res")
	exportRes(RES_SRC_DIR,RES_DEST_DIR)
