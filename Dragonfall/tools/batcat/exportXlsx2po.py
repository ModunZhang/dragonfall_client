# coding=utf-8
# DannyHe
# 导出excel文件为po文件
from basic import *
from batcat import *
import os
PROJ_DIR = getProjDir()
I18N_DIR = formatPath("%s/dev/res/i18n" % PROJ_DIR)
EXCEL_FILE = ""
PO_LANGUAGES = []
SedCommand = "sed" #mac下默认


def sedPofile(file_path,language_code):
    args = """3a\\
\"Project-Id-Version: dragonfall\\\\n"\\
\"Language-Team: \\\\n"\\
\"Language: %s\\\\n\"\\
\"X-Poedit-SourceCharset: UTF-8\\\\n\"\\
\"X-Poedit-KeywordsList: _\\\\n\"\\
\"X-Poedit-Basepath: ../../scripts/app/\\\\n\"\\
\"X-Poedit-SearchPath-0: .\\\\n\"
			""" % language_code
    command = ""
    if isWindows():
        command = [SedCommand, "-i", "-u", args, file_path]
    else:
        command = [SedCommand,"-i","", args, file_path]
    executeListCommand(command, False)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        EXCEL_FILE = formatPath(sys.argv[1])
    else:
        EXCEL_FILE = formatPath("%s/i18n.xlsx" % os.getcwd())
    if isWindows():
        SedCommand = getWin32SedPath()
    for file in os.listdir(I18N_DIR):
        fileInfo = file.split('.')
        if fileInfo[-1] != 'po':
            continue
        PO_LANGUAGES.append(fileInfo[0])
    Logging.warning("开始导出Excel文件到Po文件")
    for language_code in PO_LANGUAGES:
        export_path = formatPath("%s/%s.po" % (I18N_DIR, language_code))
        Logging.info("导出 %s" % export_path)
        command = "xls-to-po %s %s %s" % (language_code,
                                          EXCEL_FILE, export_path)
        executeCommand(command, False)
        sedPofile(export_path,language_code)