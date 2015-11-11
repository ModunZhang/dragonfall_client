# coding=utf-8
# DannyHe
# #如果执行这个文件出现异常或者错误日志,脚本环境就未配置成功
from batcat import *
from basic import *
import sys
try:
	if isWindows():
		find_environment_variable("CONVERT_PATH", False)
	else:
		pass
	find_environment_variable("GIT_REPOSITOTY_AUTO_UPDATE", False)
except Exception, e:
	print "脚本环境就未配置成功!"
	sys.exit(1)