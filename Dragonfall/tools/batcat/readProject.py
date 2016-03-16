# coding=utf-8
# DannyHe
# read project infomation on different platform
import xml.dom.minidom
import sys
import getopt
import ConfigParser,os

from basic import *
from batcat import *
from biplist import *

platform = ""
isReadVersion = False
isReadMinVersion = False

Logging.DEBUG_MODE = True

def usage():
    print("usage:")
    print("readProject -p platform [-v][-m]")
    print("platform:iOS,Android,WP")
    print("v:version")
    print("m:appMinVersion")
    print("readProject -p iOS -v")


def initData():
    if platform == 'Android':
        # initAndroidData()
        # use AS project ide
        initAndroidStudioData()
    if platform == 'WP':
        pass
    if platform == 'iOS':
        initiOSData()


def getAppVersion():
    if platform == 'Android':
        # return getAndroidAppVersion()
        # use AS project ide
        return getAndroidStudioAppVersion()
    if platform == 'WP':
        return getWPAppVersion()
    if platform == 'iOS':
        return getiOSAppVersion()


def getAppMinVersion():
    if platform == 'Android':
        # return getAndroidAppMinVersion()
        # use AS project ide
        return getAndroidStudioAppMinVersion()
    if platform == 'WP':
        return getWPAppMinVersion()
    if platform == 'iOS':
        return getiOSAppMinVersion()

# Android Studio

def initAndroidStudioData():
    if platform != 'Android':
        return
    m_file_path = getProjConfigPath('Android')
    global config
    config = ConfigParser.RawConfigParser()
    config.read(m_file_path)

def getAndroidStudioAppVersion():
    if platform != 'Android':
        return
    return config.get('versions','versionName') 

def getAndroidStudioAppMinVersion():
    if platform != 'Android':
        return
    return config.get('versions','appMinVersion')
# Android


def initAndroidData():
    if platform != 'Android':
        return
    m_file_path = getProjConfigPath('Android')
    dom = xml.dom.minidom.parse(m_file_path)
    global root
    root = dom.documentElement


def getAndroidAllMetaDataElements():
    if platform != 'Android':
        return
    applications = root.getElementsByTagName("application")
    if applications[0].nodeName == 'application':
        return applications[0].getElementsByTagName("meta-data")


def getAndroidAppVersion():
    if platform != 'Android':
        return
    version = root.getAttribute("android:versionName")
    return version


def getAndroidAppMinVersion():
    if platform != 'Android':
        return
    metaDatas = getAndroidAllMetaDataElements()
    for meta in metaDatas:
        if meta.getAttribute("android:name") == "AppMinVersion":
            return meta.getAttribute("android:value")

# WindowsPhone


def getWPAppVersion():
    if platform != 'WP':
        return
    xmlPath = getProjConfigPath('WP')
    dom = xml.dom.minidom.parse(xmlPath)
    root = dom.documentElement
    applications = root.getElementsByTagName("Identity")
    if len(applications) > 0 and applications[0].nodeName == 'Identity':
        version = applications[0].getAttribute("Version")
        lastIndex = version.rfind(".")
        return version[:lastIndex]
    else:
        return None


def getWPAllMetaDataElements(root):
    applications = root.getElementsByTagName("Application.Resources")
    if applications[0].nodeName == 'Application.Resources':
        return applications[0].getElementsByTagName("x:String")


def getWPAppMinVersion():
    if platform != 'WP':
        return
    xmlPath = getWPAppXmlPath()
    dom = xml.dom.minidom.parse(xmlPath)
    root = dom.documentElement
    metaDatas = getWPAllMetaDataElements(root)
    for meta in metaDatas:
        if meta.getAttribute("x:Key") == "AppMinVersion":
            return meta.firstChild.data
# iOS
def initiOSData():
    m_file_path = getProjConfigPath('iOS')
    global root
    root = readPlist(m_file_path)

def getiOSAppVersion():
    return root['CFBundleShortVersionString']

def getiOSAppMinVersion():
    return root['AppMinVersion']
if __name__ == "__main__":
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'p:vm')
        for opt, arg in opts:
            if opt in ('-p'):
                platform = arg
                initData()
            elif opt in ('-m'):
                isReadMinVersion = True
            elif opt in ('-v'):
                isReadVersion = True

        if isReadVersion:
            print getAppVersion()
            sys.exit(0)
        elif isReadMinVersion:
            print getAppMinVersion()
            sys.exit(0)
    except getopt.GetoptError:
        usage()
        sys.exit()
