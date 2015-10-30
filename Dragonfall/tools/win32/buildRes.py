# encoding: utf-8
# DannyHe
# This scripts only for windows phone on Win32
import functions,sys,os
import subprocess,shutil

Platform="WP8"

DEBUG_MODE=False # debug this scripts
QUIET_MODE=True # quite mode
DXT_FOMAT='/DXT3' # the format of DXT texture
ZIP_TEXTURE=True # zip the texture data(cocos2dx must open macro 'CC_USE_ETC1_ZLIB')
NEED_ENCRYPT_RES=True #encrypt resources(only texture)
USE_DXT_COMPRESS=True #use DXT format texture

DXT_RES_TOOL=functions.getDXTConvertTool()
RES_COMPILE_TOOL=functions.getResourceTool()
RES_SRC_DIR=functions.getResourceDir()
RES_DEST_DIR=functions.getExportResourcesDir()
XXTEAKey=functions.getXXTEAKey()
XXTEASign=functions.getXXTEASign()
TEMP_RES_DIR=functions.getTempDir()
ZIP_TOOL=functions.getETCCompressTool()

if DEBUG_MODE:
	functions.Logging.debug("------------Debug Start------------")
	functions.Logging.debug(RES_COMPILE_TOOL)
	functions.Logging.debug(RES_SRC_DIR)
	functions.Logging.debug(RES_DEST_DIR)
	functions.Logging.debug(XXTEAKey)
	functions.Logging.debug(XXTEASign)
	functions.Logging.debug(TEMP_RES_DIR)
	functions.Logging.debug("------------Debug End------------")

def ZipResources(in_file_path,out_file_path):
	args = [ZIP_TOOL, 'pack',in_file_path,out_file_path]
	p = subprocess.Popen(args)
	p.wait()
	if p.returncode != 0:
		functions.die("ZipResources failed: %s" % in_file_path)
	else:
		return True

def DXTFormatResources(in_file_path,out_file_path):
	args = [DXT_RES_TOOL, '-file',in_file_path,'-fileformat','dds',DXT_FOMAT,'/rescalemode','nearest','/mipMode','None','/out',out_file_path]
	if QUIET_MODE:
		args = [DXT_RES_TOOL, '-file',in_file_path,'-fileformat','dds',DXT_FOMAT,'/rescalemode','nearest','/mipMode','None','/out',out_file_path,'/quiet']
	p = subprocess.Popen(args)
	p.wait()
	if p.returncode != 0:
		functions.die("DXTFormatResources failed: %s" % in_file_path)
	else:
		return True

def CompileResources(in_file_path,out_dir_path):
	args = [RES_COMPILE_TOOL, '-i',in_file_path,'-o',out_dir_path,'-ek',XXTEAKey,'-es',XXTEASign]
	if QUIET_MODE:
		args = [RES_COMPILE_TOOL, '-i',in_file_path,'-o',out_dir_path,'-ek',XXTEAKey,'-es',XXTEASign,'-q']
	p = subprocess.Popen(args)
	p.wait()
	if p.returncode != 0:
		functions.die("CompileResources failed: %s" % in_file_path)
	else:
		return True

def exportImagesRes(image_dir_path):
	outdir=os.path.join(RES_DEST_DIR,os.path.basename(image_dir_path)) #xxx/images/
	functions.Logging.info("> %s" % image_dir_path)
	if not os.path.exists(outdir):
		os.makedirs(outdir)
	for file in os.listdir(image_dir_path):
		sourceFile = os.path.join(image_dir_path,  file) 
		targetFile = os.path.join(outdir,  file)
		if os.path.isfile(sourceFile):
			fileExt=sourceFile.split('.')[-1]
			if (fileExt == 'png' or fileExt == 'jpg') and fileExt != 'tmp':
				if NEED_ENCRYPT_RES:
					CompileResources(sourceFile,outdir)
				else:
					if DEBUG_MODE:
						functions.Logging.debug("copy images %s -- %s" %(sourceFile,outdir))
					shutil.copy(sourceFile,  outdir)

		elif os.path.isdir(sourceFile):
			dir_name=os.path.basename(sourceFile)
			if dir_name == 'rgba444_single':
				functions.Logging.info("> %s" % dir_name)
				for image_file in os.listdir(sourceFile):
					image_sourceFile = os.path.join(sourceFile,  image_file) 
					image_targetFile = os.path.join(outdir,  image_file)
					image_outdir = os.path.dirname(image_targetFile)
					if os.path.isfile(image_sourceFile):
						fileExt=image_sourceFile.split('.')[-1]
						if fileExt != 'tmp' and fileExt != 'plist':
							if NEED_ENCRYPT_RES:
								CompileResources(image_sourceFile,image_outdir)
								if DEBUG_MODE:
									functions.Logging.debug("copy images %s -- %s" %(image_sourceFile,image_outdir))
								shutil.copy(image_sourceFile,image_outdir)
						elif fileExt == 'plist':
							if DEBUG_MODE:
								functions.Logging.debug("copy images %s -- %s" %(image_sourceFile,image_outdir))
							shutil.copy(image_sourceFile,image_outdir)

			elif dir_name == '_CanCompress' or dir_name == '_Compressed_wp':

				functions.Logging.info("> %s" % dir_name)
				for image_file in os.listdir(sourceFile):
					image_sourceFile = os.path.join(sourceFile,image_file) 
					image_targetFile = os.path.join(outdir,  image_file)
					image_outdir = os.path.dirname(image_targetFile)
					if os.path.isfile(image_sourceFile):
						fileExt=image_sourceFile.split('.')[-1]
						if fileExt != 'tmp' and fileExt != 'plist':
							if USE_DXT_COMPRESS:
								temp_file = os.path.join(TEMP_RES_DIR,image_file)
								temp_final_file = temp_file
								if ZIP_TEXTURE:
									temp_file = os.path.join(TEMP_RES_DIR,os.path.splitext(image_file)[0] + '_dds.png')
								if DXTFormatResources(image_sourceFile,temp_file):
									if ZIP_TEXTURE and ZipResources(temp_file,temp_final_file):
										image_sourceFile = temp_final_file
									else:
										image_sourceFile = temp_file
							if NEED_ENCRYPT_RES:
								CompileResources(image_sourceFile,image_outdir)
							else:
								if DEBUG_MODE:
									functions.Logging.debug("copy images %s -- %s" %(image_sourceFile,image_outdir))
								shutil.copy(image_sourceFile,image_outdir)
						elif fileExt == 'plist':
							if DEBUG_MODE:
								functions.Logging.debug("copy images %s -- %s" %(image_sourceFile,image_outdir))
							shutil.copy(image_sourceFile,image_outdir)

			else:
				functions.Logging.info("Not handle dir: %s" % sourceFile)

def exportAnimationRes(animation_path):
	outdir=os.path.join(RES_DEST_DIR,"animations")
	functions.Logging.info("> %s" % (animation_path))
	for file in os.listdir(animation_path):
		sourceFile = os.path.join(animation_path,  file) 
		targetFile = os.path.join(outdir,  file)
		fileExt=sourceFile.split('.')[-1]
		if not os.path.exists(outdir):
			os.makedirs(outdir)
		if fileExt == 'ExportJson' or fileExt == 'plist':
			shutil.copy(sourceFile,  outdir)
		else:
			if USE_DXT_COMPRESS:
				temp_file = os.path.join(TEMP_RES_DIR,file)
				temp_final_file = temp_file
				if ZIP_TEXTURE:
					temp_file = os.path.join(TEMP_RES_DIR,os.path.splitext(file)[0] + '_dds.png')
				#dxt
				if DXTFormatResources(sourceFile,temp_file):
					if ZIP_TEXTURE and ZipResources(temp_file,temp_final_file):
						sourceFile = temp_final_file
					else:
						sourceFile = temp_file
			if NEED_ENCRYPT_RES:
				CompileResources(sourceFile,outdir)
			else:
				shutil.copy(sourceFile,  outdir)

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
        	if not os.path.exists(outdir):
        		os.makedirs(outdir)
        	if fileExt != 'po':
        		shutil.copy(sourceFile,  outdir)
        		functions.Logging.info(">> %s" % sourceFile)
        elif os.path.isdir(sourceFile):
        	dir_name=os.path.basename(sourceFile)
        	if dir_name == 'images':
        		exportImagesRes(sourceFile)
        	elif dir_name == 'animations':
        		functions.Logging.debug("*animations")
        	elif dir_name == 'animations_mac':
        		exportAnimationRes(sourceFile)
        	else:
				exportRes(sourceFile, targetFile)

if __name__=="__main__":
	functions.Logging.info("> Begin resources")
	exportRes(RES_SRC_DIR,RES_DEST_DIR)
	functions.removeTempFiles(RES_SRC_DIR,"tmp")
	functions.removeTempDir(TEMP_RES_DIR)
	functions.Logging.info("> End resources")
	sys.exit(0);