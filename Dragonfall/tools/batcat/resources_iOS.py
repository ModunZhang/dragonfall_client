# coding=utf-8
# DannyHe
from batcat import *
from basic import *

Platform = "iOS"
NEED_ENCRYPT_RES = ""  # 是否需要加密资源

RES_DEST_DIR = getExportResourcesDir(Platform)
RES_COMPILE_TOOL = getResourceTool()  # 加密工具
RES_SRC_DIR = getResourceDir()  # 资源源目录
XXTEAKey = getXXTEAKey()
XXTEASign = getXXTEASign()
TEMP_RES_DIR = getTempDir()

QUIET_MODE = True
Logging.DEBUG_MODE = False

def getAllArgs():

    global NEED_ENCRYPT_RES

    NEED_ENCRYPT_RES = getNeedEncryptResources(NEED_ENCRYPT_RES)
    Logging.debug("------------Debug Config------------")
    Logging.debug(Platform)
    Logging.debug(NEED_ENCRYPT_RES)
    Logging.debug(RES_DEST_DIR)
    Logging.debug(RES_COMPILE_TOOL)
    Logging.debug(RES_SRC_DIR)
    Logging.debug("------------End Config------------")


def CompileResources(in_file_path, out_dir_path):
    comand = "%s -i %s -o %s -ek %s -es %s" % (
        RES_COMPILE_TOOL, in_file_path, out_dir_path, XXTEAKey, XXTEASign)
    if QUIET_MODE:
        comand = "%s -q" % comand
    code, ret = executeCommand(comand, QUIET_MODE)
    return code == 0


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
            if fileExt in ('png', 'jpg'):
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
            Logging.info("文件夹: %s" % dir_name)
            if "_Compressed" == dir_name:  # _Compressed文件夹
                for image_file in os.listdir(sourceFile):
                    image_sourceFile = os.path.join(sourceFile,  image_file)
                    image_targetFile = os.path.join(outdir,  image_file)
                    if os.path.isfile(image_sourceFile):
                        if not fileNewer(image_sourceFile, image_targetFile):
                            Logging.info("忽略 %s" % image_sourceFile)
                            continue
                        Logging.debug("处理 %s" % image_sourceFile)
                        fileExt = image_sourceFile.split('.')[-1]
                        if fileExt == 'plist':
                            shutil.copy(image_sourceFile, outdir)
                        elif fileExt not in getTempFileExtensions():
                            if NEED_ENCRYPT_RES:
                                CompileResources(
                                    image_sourceFile, outdir)
                            else:
                                shutil.copy(image_sourceFile, outdir)
            elif "rgba444_single" == dir_name:  # rgba444_single文件夹
                for image_file in os.listdir(sourceFile):
                    temp_file = os.path.join(TEMP_RES_DIR, image_file)
                    image_sourceFile = os.path.join(sourceFile,  image_file)
                    image_targetFile = os.path.join(outdir,  image_file)
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
                        CompileResources(temp_file, outdir)
                    else:
                        shutil.copy(image_sourceFile, outdir)
            elif "_CanCompress" == dir_name:  # _CanCompress文件夹
                for image_file in os.listdir(sourceFile):
                    fileName = image_file.split('.')[0]
                    temp_file = os.path.join(TEMP_RES_DIR, fileName + ".pvr")
                    image_sourceFile = os.path.join(sourceFile,  image_file)
                    image_targetFile = os.path.join(outdir,  image_file)
                    fileExt = image_sourceFile.split('.')[-1]
                    if fileExt in getTempFileExtensions():
                        continue
                    if not fileNewer(image_sourceFile, image_targetFile):
                        Logging.info("忽略 %s" % image_sourceFile)
                        continue
                    Logging.info("--- %s" % image_file)
                    command = 'TexturePacker --format cocos2d --no-trim --disable-rotation --texture-format pvr2 --premultiply-alpha --opt PVRTC4 --padding 0 %s --sheet %s --data %s/tmp.plist' % (
                        image_sourceFile, temp_file, TEMP_RES_DIR)
                    executeCommand(command)
                    finallyTemp = os.path.join(
                        TEMP_RES_DIR, fileName + "_PVR_PNG.png")
                    shutil.copy(temp_file, finallyTemp)
                    if NEED_ENCRYPT_RES:
                        CompileResources(finallyTemp, outdir)
                        shutil.move(
                            os.path.join(outdir, fileName + "_PVR_PNG.png"), image_targetFile)
                    else:
                        shutil.copy(finallyTemp, image_targetFile)
            else:
                Logging.warning("未处理:%s" % sourceFile)


def exportAnimationRes(animation_path):
    outdir = os.path.join(RES_DEST_DIR, "animations")
    Logging.warning("动画文件夹 %s" % (animation_path))
    for file in os.listdir(animation_path):
        sourceFile = os.path.join(animation_path,  file)
        targetFile = os.path.join(outdir,  file)
        fileExt = sourceFile.split('.')[-1]
        if not os.path.exists(outdir):
            os.makedirs(outdir)
        if fileExt == 'ExportJson' or fileExt == 'plist':
            if fileNewer(sourceFile, targetFile):
                Logging.debug("拷贝 %s" % sourceFile)
                shutil.copy(sourceFile,  outdir)
            else:
                Logging.info("忽略 %s" % sourceFile)
        elif fileExt not in getTempFileExtensions():
            if NEED_ENCRYPT_RES:
                CompileResources(sourceFile, outdir)
            else:
                shutil.copy(sourceFile,  outdir)


def exportRes(sourceDir,  targetDir):
    if sourceDir.find(".git") > 0:
        return
    for file in os.listdir(sourceDir):
        sourceFile = os.path.join(sourceDir,  file)
        targetFile = os.path.join(targetDir,  file)

        if os.path.isfile(sourceFile):  # file in res
            outdir = os.path.dirname(targetFile)
            fileExt = sourceFile.split('.')[-1]
            # iOS不拷贝字体文件
            if fileExt not in ('po', 'ttf') and fileExt not in getTempFileExtensions():
                if not fileNewer(sourceFile, targetFile):
                    Logging.info("忽略 %s" % sourceFile)
                    continue
                if not os.path.exists(outdir):
                    os.makedirs(outdir)
                shutil.copy(sourceFile,  outdir)
                Logging.debug("拷贝 %s" % sourceFile)
        elif os.path.isdir(sourceFile):
            dir_name = os.path.basename(sourceFile)
            if dir_name == 'images':
                exportImagesRes(sourceFile)
            elif dir_name == 'animations':
                exportAnimationRes(sourceFile)
            elif dir_name == 'animations_mac':
                Logging.warning("不处理animations_mac文件夹")
            else:
                exportRes(sourceFile, targetFile)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        NEED_ENCRYPT_RES = sys.argv[1]
    getAllArgs()
    Logging.warning("资源处理开始")
    exportRes(RES_SRC_DIR, RES_DEST_DIR)
    removeTempFiles(RES_SRC_DIR, "tmp")
    removeTempDir(TEMP_RES_DIR)
    Logging.warning("资源处理完成")
