#coding=utf-8
#DannyHe
#导出po文件为excel文件
from basic import *
from batcat import *
import os,string

EXPORT_EXCEL_PATH = ""
FILE_NAMES = []
I18N_DIR = formatPath("%s/dev/res/i18n" % getProjDir())
# main
if __name__=="__main__":
	if len(sys.argv) > 1:
		EXPORT_EXCEL_PATH = formatPath(sys.argv[1])
	else:
		EXPORT_EXCEL_PATH = formatPath("%s/i18n.xlsx" % os.getcwd()) 
		
	for file in os.listdir(I18N_DIR):
		fileInfo = file.split('.')
		if fileInfo[-1] != 'po':continue
		FILE_NAMES.append(os.path.join(I18N_DIR,file))
	Logging.warning("开始导出Po文件到Excel")
	command = "po-to-xls -o %s %s" % (EXPORT_EXCEL_PATH,string.join(FILE_NAMES," "))
	executeCommand(command,False)
	Logging.warning("导出Excel文件结束:%s" % EXPORT_EXCEL_PATH)