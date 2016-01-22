# coding=utf-8
# DannyHe
from batcat import *
from basic import *
import shutil
import os
import sys

Platform = "WP"
DXT_FOMAT = "/DXT3"  # 定义dds纹理的格式
ZIP_TEXTURE = True #是否使用工具第二次压缩纹理 游戏逻辑部分必须开启宏CC_USE_ETC1_ZLIB
USE_DXT_COMPRESS = True  # use DXT format texture
NEED_ENCRYPT_RES = ""  # 纹理是否进行加密
RES_COMPILE_TOOL = getResourceTool()
RES_SRC_DIR = getResourceDir()
XXTEAKey = getXXTEAKey()
XXTEASign = getXXTEASign()
TEMP_RES_DIR = getTempDir()
ZIP_TEXTURE_TOOL = getETCCompressTool()
RES_DEST_DIR = getExportResourcesDir(Platform)
DXT_COMPRESS_TOOL = getDXTConvertTool(Platform)

QUIET_MODE = True  # 安静模式:命令行工具是否打印输出

Logging.DEBUG_MODE = True  # 控制debug日志是否输出

def getAllArgs():

    global NEED_ENCRYPT_RES

    NEED_ENCRYPT_RES = getNeedEncryptResources(NEED_ENCRYPT_RES)

#自定义工具压缩纹理数据
def PackImage(in_file_path, out_file_path):
    comand = "%s pack %s %s" % (ZIP_TEXTURE_TOOL, in_file_path, out_file_path)
    code, ret = executeCommand(comand, QUIET_MODE)
    return code == 0

#dds纹理压缩
def DXTFormatResources(in_file_path, out_file_path):
    comand = "%s -file %s -fileformat dds %s /rescalemode nearest /mipMode None /out %s" % (
        DXT_COMPRESS_TOOL, in_file_path, DXT_FOMAT, out_file_path)
    if QUIET_MODE:
        comand = "%s /quiet" % comand
    code, ret = executeCommand(comand, QUIET_MODE)
    return code == 0

#加密文件
def CompileResources(in_file_path, out_dir_path):
    comand = "%s -i %s -o %s -ek %s -es %s" % (
        RES_COMPILE_TOOL, in_file_path, out_dir_path, XXTEAKey, XXTEASign)
    if QUIET_MODE:
        comand = "%s -q" % comand
    code, ret = executeCommand(comand, QUIET_MODE)
    return code == 0

def GetExincludeFiles():
    return ['jpg_png1.png']

def exportImagesRes(image_dir_path):
    outdir = os.path.join(RES_DEST_DIR, os.path.basename(
        image_dir_path))  # xxx/images/
    Logging.info("图片文件夹:%s" % image_dir_path)
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    for file in os.listdir(image_dir_path):
        sourceFile = os.path.join(image_dir_path,  file)
        targetFile = os.path.join(outdir,  file)
        if os.path.isfile(sourceFile):
            fileExt = sourceFile.split('.')[-1]
            if fileExt in ('png','jpg'):
                if NEED_ENCRYPT_RES:
                    CompileResources(sourceFile, outdir)
                else:
                    Logging.debug("拷贝 %s" % sourceFile)
                    shutil.copy(sourceFile,  outdir)

        elif os.path.isdir(sourceFile):
            dir_name = os.path.basename(sourceFile)
            Logging.warning("文件件 %s" % dir_name)
            if dir_name == 'rgba444_single':
                for image_file in os.listdir(sourceFile):
                    current_sourceFile = os.path.join(sourceFile,  image_file)
                    if os.path.isfile(current_sourceFile):
                        fileExt = current_sourceFile.split('.')[-1]
                        if fileExt not in getTempFileExtensions() and fileExt != 'plist':
                            if NEED_ENCRYPT_RES:
                                CompileResources(
                                    current_sourceFile, outdir)
                                Logging.debug("拷贝 %s" % current_sourceFile)
                            else:
                                shutil.copy(current_sourceFile, outdir)
                        elif fileExt == 'plist':
                            Logging.debug("拷贝 %s" % current_sourceFile)
                            shutil.copy(current_sourceFile, outdir)

            elif dir_name == '_CanCompress' or dir_name == '_Compressed_wp':
                for image_file in os.listdir(sourceFile):
                    current_sourceFile = os.path.join(sourceFile, image_file)
                    if os.path.isfile(current_sourceFile):
                        fileExt = current_sourceFile.split('.')[-1]
                        if fileExt not in getTempFileExtensions() and fileExt != 'plist':
                            if USE_DXT_COMPRESS:
                                temp_file = os.path.join(
                                    TEMP_RES_DIR, image_file)
                                temp_final_file = temp_file
                                if ZIP_TEXTURE and image_file not in GetExincludeFiles():
                                    temp_file = os.path.join(
                                        TEMP_RES_DIR, os.path.splitext(image_file)[0] + '_dds.png')
                                if DXTFormatResources(current_sourceFile, temp_file):
                                    if ZIP_TEXTURE and image_file not in GetExincludeFiles():
                                        if PackImage(temp_file, temp_final_file):
                                            current_sourceFile = temp_final_file
                                        else:
                                            Logging.error("压缩失败")
                                    else:
                                        current_sourceFile = temp_file
                            if NEED_ENCRYPT_RES:
                                CompileResources(
                                    current_sourceFile, outdir)
                            else:
                                Logging.debug("拷贝 %s" % current_sourceFile)
                                shutil.copy(current_sourceFile, outdir)
                        elif fileExt == 'plist':
                            Logging.debug("拷贝 %s" % current_sourceFile)
                            shutil.copy(current_sourceFile, outdir)
            else:
                Logging.info("未处理:%s" % sourceFile)


def exportAnimationRes(animation_path):
    outdir = os.path.join(RES_DEST_DIR, "animations")
    Logging.info("动画文件夹 %s" % (animation_path))
    for file in os.listdir(animation_path):
        sourceFile = os.path.join(animation_path,  file)
        targetFile = os.path.join(outdir,  file)
        fileExt = sourceFile.split('.')[-1]
        if not os.path.exists(outdir):
            os.makedirs(outdir)
        if fileExt == 'ExportJson' or fileExt == 'plist':
            shutil.copy(sourceFile,  outdir)
        elif fileExt not in getTempFileExtensions():
            if USE_DXT_COMPRESS:
                temp_file = os.path.join(TEMP_RES_DIR, file)
                temp_final_file = temp_file
                if ZIP_TEXTURE:
                    temp_file = os.path.join(
                        TEMP_RES_DIR, os.path.splitext(file)[0] + '_dds.png')
                # dxt
                if DXTFormatResources(sourceFile, temp_file):
                    if ZIP_TEXTURE and PackImage(temp_file, temp_final_file):
                        sourceFile = temp_final_file
                    else:
                        sourceFile = temp_file
            if NEED_ENCRYPT_RES:
                CompileResources(sourceFile, outdir)
            else:
                shutil.copy(sourceFile,  outdir)


def exportRes(sourceDir,  targetDir):
    if sourceDir.find(".git") > 0:
        Logging.warning("git文件不处理")
        return
    for file in os.listdir(sourceDir):
        sourceFile = os.path.join(sourceDir,  file)
        targetFile = os.path.join(targetDir,  file)

        if os.path.isfile(sourceFile):  # file in res
            outdir = os.path.dirname(targetFile)
            fileExt = sourceFile.split('.')[-1]
            if not os.path.exists(outdir):
                os.makedirs(outdir)
            if fileExt not in ('po') and fileExt not in getTempFileExtensions():
                if fileExt in ('png','jpg') and NEED_ENCRYPT_RES:
                    CompileResources(sourceFile, outdir)
                else:
                    shutil.copy(sourceFile,  outdir)
                    Logging.debug("拷贝 %s" % sourceFile)
        elif os.path.isdir(sourceFile):
            dir_name = os.path.basename(sourceFile)
            if dir_name == 'images':
                exportImagesRes(sourceFile)
            elif dir_name == 'animations':
                Logging.warning("未处理animations文件夹")
            elif dir_name == 'animations_mac':
                exportAnimationRes(sourceFile)
            else:
                exportRes(sourceFile, targetFile)

# main
if __name__ == "__main__":
    if len(sys.argv) > 1:
        NEED_ENCRYPT_RES = sys.argv[1]
    getAllArgs()
    exportRes(RES_SRC_DIR, RES_DEST_DIR)
    removeTempFiles(RES_SRC_DIR, "tmp")
    removeTempDir(TEMP_RES_DIR)
    Logging.info("> 资源处理完成")
