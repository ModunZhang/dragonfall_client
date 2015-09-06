#coding=utf-8
#读取Android配置文件中的信息
import  xml.dom.minidom
import sys,getopt
def usage():
    print "AndroidXml xxx.xml [-v][-m]"

#打开xml文档

def initXMLDOM():
	dom = xml.dom.minidom.parse(m_file_path)
	global root
	root = dom.documentElement

def getAppVersion():
	version = root.getAttribute("android:versionName")
	return version

def getAllMetaDataElements():
	applications = root.getElementsByTagName("application")
	if applications[0].nodeName == 'application':
		return applications[0].getElementsByTagName("meta-data")

def getAppMinVersion():
	metaDatas = getAllMetaDataElements()
	for meta in metaDatas:
		if meta.getAttribute("android:name") == "AppMinVersion":
			return meta.getAttribute("android:value")

if __name__=="__main__":
	m_file_path = sys.argv[1]
	initXMLDOM()
	try:
		opts,args = getopt.getopt(sys.argv[2:], 'vm')
		for opt, arg in opts:
			if opt == '-v':
				print getAppVersion()
			elif opt == '-m':
				print getAppMinVersion()
	except getopt.GetoptError:
		usage()
		sys.exit()