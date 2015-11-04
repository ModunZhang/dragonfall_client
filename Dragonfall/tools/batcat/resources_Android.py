# coding=utf-8
# DannyHe
from batcat import *
from basic import *

Platform = "Android"
NEED_ENCRYPT_RES = ""  # 是否需要加密资源

RES_DEST_DIR = getExportResourcesDir(Platform)
RES_COMPILE_TOOL = getResourceTool()  # 加密工具
RES_SRC_DIR = getResourceDir()  # 资源源目录
XXTEAKey = getXXTEAKey()
XXTEASign = getXXTEASign()
TEMP_RES_DIR = getTempDir()
ETCPackTool = getETCCompressTool()  # 自定义的压缩工具

# etc
IMAGEFORMAT = "ETC1"
IMAGEQUALITY = "etcfast"
PVRTOOL = getPVRTexTool()
CONVERTTOOL = getConvertTool()

QUIET_MODE = False

ALPHA_USE_ETC = True  # alpha纹理使用etc格式压缩
COMPRESS_ETC_FILE = True  # etc格式纹理通过自定义压缩工具再压缩

Logging.DEBUG_MODE = True

def getAllArgs():

    global NEED_ENCRYPT_RES

    NEED_ENCRYPT_RES = getNeedEncryptResources(NEED_ENCRYPT_RES)
    Logging.debug("------------Debug Config------------")
    Logging.debug(Platform)
    Logging.debug(NEED_ENCRYPT_RES)
    Logging.debug(RES_DEST_DIR)
    Logging.debug(RES_COMPILE_TOOL)
    Logging.debug(RES_SRC_DIR)
    Logging.debug(ETCPackTool)
    Logging.debug("------------End Config------------")


def CompileResources(in_file_path, out_dir_path):
    comand = "%s -i %s -o %s -ek %s -es %s" % (
        RES_COMPILE_TOOL, in_file_path, out_dir_path, XXTEAKey, XXTEASign)
    if QUIET_MODE:
        comand = "%s -q" % comand
    code, ret = executeCommand(comand, QUIET_MODE)
    return code == 0


def PVRImage(in_path, out_path):
    command = "%s -f %s -i %s -o %s -q %s" % (
        PVRTOOL, IMAGEFORMAT, in_path, out_path, IMAGEQUALITY)
    return executeCommand(command)[0] == 0


def PackETCImage(in_path, out_path):
    command = "%s pack %s %s" % (ETCPackTool, in_path, out_path)
    return executeCommand(command, QUIET_MODE)[0] == 0


def RGBImage(in_path, out_path):
    command = "%s %s -alpha Off %s" % (CONVERTTOOL, in_path, out_path)
    return executeCommand(command, QUIET_MODE)[0] == 0


def AlphaImage(in_path, out_path):
    command = "%s %s -channel A -alpha extract %s" % (
        CONVERTTOOL, in_path, out_path)
    return executeCommand(command, QUIET_MODE)[0] == 0


def exportImagesRes(image_dir_path):
    outdir = os.path.join(RES_DEST_DIR, os.path.basename(image_dir_path))
    Logging.warning("图片文件夹 %s" % image_dir_path)
    if not os.path.exists(outdir):
        os.makedirs(outdir)
    for file in os.listdir(image_dir_path):
        sourceFile = os.path.join(image_dir_path,  file)
        targetFile = os.path.join(outdir,  file)
        if os.path.isfile(sourceFile):
            # 拷贝[加密images下的jpg/png图片]
            fileExt = sourceFile.split('.')[-1]
            if fileExt in ('png','jpg'):
                if not fileNewer(sourceFile, targetFile):
                    Logging.info("忽略 %s" % sourceFile)
                    continue
                if NEED_ENCRYPT_RES:
                    CompileResources(sourceFile, outdir)
                else:
                    Logging.debug("拷贝 %s" % sourceFile)
                    shutil.copy(sourceFile,  outdir)
        elif os.path.isdir(sourceFile):
            dir_name = os.path.basename(sourceFile)
            Logging.warning("文件夹: %s" % dir_name)
            if "_Compressed_mac" == dir_name:  # _Compressed_mac文件夹
                for image_file in os.listdir(sourceFile):
                    image_sourceFile = os.path.join(sourceFile,  image_file)
                    image_targetFile = os.path.join(outdir,  image_file)
                    if not os.path.isfile(image_sourceFile):
                        continue
                    if not fileNewer(image_sourceFile, image_targetFile):
                        Logging.info("忽略 %s" % image_sourceFile)
                        continue
                    Logging.debug("处理 %s" % image_sourceFile)
                    fileInfo = image_file.split('.')
                    fileExt = fileInfo[-1]
                    if fileExt == 'plist':
                        shutil.copy(image_sourceFile, outdir)
                    elif fileExt not in getTempFileExtensions():
                        tempfileName = fileInfo[0]
                        tempRGBfile = os.path.join(
                            TEMP_RES_DIR, tempfileName + '.png')
                        tempRGBfile_ETC = os.path.join(
                            TEMP_RES_DIR, tempfileName + '.pvr')
                        tempAlphaFile = os.path.join(
                            TEMP_RES_DIR, tempfileName + '_alpha_etc1.png')
                        outAlphaFile = os.path.join(
                            outdir, tempfileName + '_alpha_etc1.png')
                        RGBImage(image_sourceFile, tempRGBfile)
                        AlphaImage(image_sourceFile, tempAlphaFile)
                        if ALPHA_USE_ETC:
                            tempAlphaFile_ETC = os.path.join(
                                TEMP_RES_DIR, tempfileName + '_alpha_etc1.pvr')
                            PVRImage(tempAlphaFile, tempAlphaFile_ETC)
                            if COMPRESS_ETC_FILE:
                                PackETCImage(tempAlphaFile_ETC, tempAlphaFile)
                            else:
                                shutil.move(tempAlphaFile_ETC, tempAlphaFile)
                        PVRImage(tempRGBfile, tempRGBfile_ETC)
                        if NEED_ENCRYPT_RES:
                            if COMPRESS_ETC_FILE:
                                PackETCImage(tempRGBfile_ETC, tempRGBfile)
                            else:
                                shutil.move(tempRGBfile_ETC, tempRGBfile)
                            CompileResources(tempRGBfile, outdir)
                            CompileResources(tempAlphaFile, outdir)
                        else:
                            if COMPRESS_ETC_FILE:
                                PackETCImage(tempRGBfile_ETC, image_targetFile)
                            else:
                                shutil.move(tempRGBfile_ETC, image_targetFile)
                            shutil.move(tempAlphaFile, outAlphaFile)
            elif "_CanCompress" == dir_name:  # _CanCompress文件夹
                for image_file in os.listdir(sourceFile):
                    image_sourceFile = os.path.join(sourceFile,  image_file)
                    image_targetFile = os.path.join(outdir,  image_file)
                    if not os.path.isfile(image_sourceFile):
                        continue
                    if not fileNewer(image_sourceFile, image_targetFile):
                        Logging.info("忽略 %s" % image_sourceFile)
                        continue
                    Logging.debug("处理 %s" % image_sourceFile)
                    fileInfo = image_file.split('.')
                    fileExt = fileInfo[-1]
                    if fileExt in getTempFileExtensions():
                        continue
                    tempfileName = fileInfo[0]
                    tempRGBfile = os.path.join(
                        TEMP_RES_DIR, tempfileName + '.png')
                    tempRGBfile_ETC = os.path.join(
                        TEMP_RES_DIR, tempfileName + '.pvr')
                    tempAlphaFile = os.path.join(
                        TEMP_RES_DIR, tempfileName + '_alpha_etc1.png')
                    outAlphaFile = os.path.join(
                        outdir, tempfileName + '_alpha_etc1.png')
                    RGBImage(image_sourceFile, tempRGBfile)
                    AlphaImage(image_sourceFile, tempAlphaFile)
                    if ALPHA_USE_ETC:
                        tempAlphaFile_ETC = os.path.join(
                            TEMP_RES_DIR, tempfileName + '_alpha_etc1.pvr')
                        PVRImage(tempAlphaFile, tempAlphaFile_ETC)
                        if COMPRESS_ETC_FILE:
                            PackETCImage(tempAlphaFile_ETC, tempAlphaFile)
                        else:
                            shutil.move(tempAlphaFile_ETC, tempAlphaFile)
                    PVRImage(tempRGBfile, tempRGBfile_ETC)
                    if NEED_ENCRYPT_RES:
                        if COMPRESS_ETC_FILE:
                            PackETCImage(tempRGBfile_ETC, tempRGBfile)
                        else:
                            shutil.move(tempRGBfile_ETC, tempRGBfile)
                        CompileResources(tempRGBfile, outdir)
                        CompileResources(tempAlphaFile, outdir)
                    else:
                        if COMPRESS_ETC_FILE:
                            PackETCImage(tempRGBfile_ETC, image_targetFile)
                        else:
                            shutil.move(tempRGBfile_ETC, image_targetFile)
                        shutil.move(tempAlphaFile, outAlphaFile)
            elif "rgba444_single" == dir_name:  # rgba444_single文件夹
                for image_file in os.listdir(sourceFile):
                    temp_file = os.path.join(TEMP_RES_DIR, image_file)
                    image_sourceFile = os.path.join(sourceFile,  image_file)
                    image_targetFile = os.path.join(outdir,  image_file)
                    image_outdir = os.path.dirname(image_targetFile)
                    fileExt = image_sourceFile.split('.')[-1]
                    if fileExt in getTempFileExtensions():
                        continue
                    if not fileNewer(image_sourceFile, image_targetFile):
                        Logging.info("忽略 %s" % image_sourceFile)
                        continue
                    # 是否考虑 pvr ccz + premultiply-alpha?
                    command = 'TexturePacker --format cocos2d --no-trim --disable-rotation --texture-format png --opt RGBA4444 --png-opt-level 7 --allow-free-size --padding 0 %s --sheet %s --data %s/tmp.plist' % (
                        image_sourceFile, temp_file, TEMP_RES_DIR)
                    executeCommand(command, QUIET_MODE)
                    if NEED_ENCRYPT_RES:
                        CompileResources(temp_file, image_outdir)
                    else:
                        shutil.copy(image_sourceFile, image_outdir)
            else:
                Logging.warning("未处理:%s" % sourceFile)


def exportRes(sourceDir,  targetDir):
    if sourceDir.find(".git") > 0:
        return
    for file in os.listdir(sourceDir):
        sourceFile = os.path.join(sourceDir,  file)
        targetFile = os.path.join(targetDir,  file)

        if os.path.isfile(sourceFile):  # file in res
            outdir = os.path.dirname(targetFile)
            fileExt = sourceFile.split('.')[-1]
            if fileExt not in ('po','ttf') and fileExt not in getTempFileExtensions(): 
                if not fileNewer(sourceFile, targetFile):
                    Logging.info("忽略 %s" % sourceFile)
                    continue
                if not os.path.exists(outdir):
                    os.makedirs(outdir)
                shutil.copy(sourceFile,  outdir)
                Logging.debug("拷贝 %s" % sourceFile)
            elif fileExt == 'ttf': #android 拷贝字体文件到res下
                Logging.debug("拷贝 %s" % file)
                shutil.copy(sourceFile,  RES_DEST_DIR)
        elif os.path.isdir(sourceFile):
            dir_name = os.path.basename(sourceFile)
            if dir_name == 'images':
                exportImagesRes(sourceFile)
            elif dir_name == 'animations':
                Logging.warning("不处理animations文件夹")
            elif dir_name == 'animations_mac':
                Logging.warning("animations_mac")
                exportAnimationRes(sourceFile)
            else:
                exportRes(sourceFile, targetFile)


def exportAnimationRes(animation_path):
    Logging.warning("-- png生成etc1格式的动画资源")
    outdir = os.path.join(RES_DEST_DIR, "animations")
    for file in os.listdir(animation_path):
        sourceFile = os.path.join(animation_path,  file)
        targetFile = os.path.join(outdir,  file)
        fileInfo = file.split(".")
        fileName = fileInfo[0]
        fileExt = fileInfo[-1]
        if not os.path.exists(outdir):
            os.makedirs(outdir)
        if not fileNewer(sourceFile, targetFile) or fileExt == 'DS_Store':
            continue
        if fileExt == "plist" or fileExt == "ExportJson":
            shutil.copy(sourceFile, targetFile)
        else:
            tempRGBfile = os.path.join(TEMP_RES_DIR, "%s.png" % fileName)
            tempRGBfile_ETC = os.path.join(TEMP_RES_DIR, "%s.pvr" % fileName)
            tempAlphaFile = os.path.join(
                TEMP_RES_DIR, "%s_alpha_etc1.png" % fileName)
            outAlphaFile = os.path.join(outdir, "%s_alpha_etc1.png" % fileName)
            RGBImage(sourceFile, tempRGBfile)
            AlphaImage(sourceFile, tempAlphaFile)
            if ALPHA_USE_ETC:
                tempAlphaFile_ETC = os.path.join(
                    TEMP_RES_DIR, "%s_alpha_etc1.pvr" % fileName)
                PVRImage(tempAlphaFile, tempAlphaFile_ETC)
                if COMPRESS_ETC_FILE:
                    PackETCImage(tempAlphaFile_ETC, tempAlphaFile)
                else:
                    shutil.move(tempAlphaFile_ETC, tempAlphaFile)
            PVRImage(tempRGBfile, tempRGBfile_ETC)
            if NEED_ENCRYPT_RES:
                if COMPRESS_ETC_FILE:
                    PackETCImage(tempRGBfile_ETC, tempRGBfile)
                else:
                    shutil.move(tempRGBfile_ETC, tempRGBfile)
                CompileResources(tempRGBfile, outdir)
                CompileResources(tempAlphaFile, outdir)
            else:
                if COMPRESS_ETC_FILE:
                    PackETCImage(tempRGBfile_ETC, targetFile)
                else:
                    shutil.move(tempRGBfile_ETC, targetFile)
                shutil.move(tempAlphaFile, outAlphaFile)
if __name__ == "__main__":
    if len(sys.argv) > 1:
        NEED_ENCRYPT_RES = sys.argv[1]
    getAllArgs()
    Logging.warning("资源处理开始")
    exportRes(RES_SRC_DIR, RES_DEST_DIR)
    removeTempFiles(RES_SRC_DIR, "tmp")
    removeTempDir(TEMP_RES_DIR)
    Logging.warning("资源处理完成")
