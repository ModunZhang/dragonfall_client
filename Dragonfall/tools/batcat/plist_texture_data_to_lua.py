# -*- coding: utf-8 -*-
# https://github.com/wooster/biplist
# 通过plist文件生成包含大图信息的lua文件
import string
import os
import json
import string
import subprocess
import sys
import getopt
from biplist import *
from basic import *
import re
global m_plist_dir
global m_out_path


def usage():
    Logging.warning('''使用方式:
    python texture_data_to_lua.py -p plist_path -o xxx.lua
    plist_path:包含plist文件夹路径
    xxx.lua:导出的lua路径
        ''')


def readPlistFile(filePath):
    plist = readPlist(filePath)
    return plist


def getFileTextureName(plistFile):
    return plistFile['metadata']['realTextureFileName']

def generalLowRawFileNameDict(lowRaWFiles):
    lowRaWFileMap = {}
    for plistFile in lowRaWFiles:
        name = os.path.basename(plistFile)
        final_name = name.replace('_low_ram','')
        final_name = final_name.replace('.plist','.png')
        lowRaWFileMap[final_name] = name.replace('.plist','.png')
    return lowRaWFileMap

def generalPlistFileData(plist_dir):
    sdFiles = []
    normalFiles = []
    lowRaWFiles = []
    for root, dirs, files in os.walk(plist_dir):
        for fileName in files:
            if fileName.endswith((".plist")) and not "~$" in fileName:
                path = os.path.join(root, fileName)
                if "-sd" in fileName:
                    sdFiles.append(path)
                elif "_low_ram" in fileName:
                    lowRaWFiles.append(path)
                else:
                    normalFiles.append(path)
    normalFiles.sort()
    sdFiles.sort()
    lowRaWFiles.sort()
    return (normalFiles,sdFiles,lowRaWFiles)

def exportLuaFile(filePath,normalFiles,sdFiles,lowRaWFiles,lowRaWFiles_dict):
    file = open(filePath, "w")
    file.write("local texture_data = {}\n")
    file.write("local sd = {}\n")
    file.write("local low_raw_map = {}\n")
    file.write("local low_raw_texture = {}\n")
    for plistFile in normalFiles:
        dic = readPlistFile(plistFile)
        texture_name = getFileTextureName(dic)
        Logging.info("--处理%s" % (texture_name))
        pngs = dic.frames.keys()
        pngs.sort()
        for png in pngs:
            file.write("texture_data[\"%s\"] = \"%s\"\n" % (png, texture_name))
    file.write("--------------------\n")
    for plistFile in sdFiles:
        dic = readPlistFile(plistFile)
        texture_name = getFileTextureName(dic)
        Logging.info("--处理%s" % (texture_name))
        pngs = dic.frames.keys()
        pngs.sort()
        for png in pngs:
            file.write("sd[\"%s\"] = \"%s\"\n" % (png, texture_name))
    file.write("--------------------\n")
    for plistFile in lowRaWFiles:
        dic = readPlistFile(plistFile)
        texture_name = getFileTextureName(dic)
        Logging.info("--处理%s" % (texture_name))
        pngs = dic.frames.keys()
        pngs.sort()
        for png in pngs:
            file.write("low_raw_texture[\"%s\"] = \"%s\"\n" % (png, texture_name))
    file.write("--------------------\n")
    for normalFile in lowRaWFiles_dict:
        file.write("low_raw_map[\"%s\"] = \"%s\"\n" % (normalFile, lowRaWFiles_dict[normalFile]))
    file.write("texture_data.sd = sd\n")
    file.write("texture_data.low_raw_map = low_raw_map\n")
    file.write("texture_data.low_raw_texture = low_raw_texture\n")
    file.write("return texture_data\n")
    

if __name__ == "__main__":
    if len(sys.argv) < 3:
        usage()
        sys.exit()
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'p:o:')
    except getopt.GetoptError:
        usage()
        sys.exit()

    for opt, arg in opts:
        if opt == '-p':
            if not arg:
                sys.exit(-1)
            m_plist_dir = formatPath(arg)
        elif opt == '-o':
            if not arg:
                sys.exit(-1)
            m_out_path = formatPath(arg)
    Logging.info("------开始通过plist文件生成包含大图信息的lua文件------")
    Logging.info("---资源路径:" + m_plist_dir)
    Logging.info("---导出路径:" + m_out_path)
    (normalFiles,sdFiles,lowRaWFiles) = generalPlistFileData(m_plist_dir)
    lowRaWFiles_dict = generalLowRawFileNameDict(lowRaWFiles)
    exportLuaFile(m_out_path,normalFiles,sdFiles,lowRaWFiles,lowRaWFiles_dict)
    Logging.info("------生成成功------")