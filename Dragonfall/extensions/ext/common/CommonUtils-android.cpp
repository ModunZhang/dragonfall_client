#include "CommonUtils.h"
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#if (!defined NDEBUG)
#define LOG_TAG ("jni_CommonUtils.cpp")
#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__))
#define LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__))
#else
#define LOGI(...)
#define LOGD(...)
#define LOGE(...)
#endif
#define CLASS_NAME "com/batcatstudio/dragonfall/utils/CommonUtils"
/*****VERSION****/
//define the so version from shell
//readelf -p .bugly_version libxxx.so

#define STRINGIFY2(X) #X
#define STRINGIFY(X) STRINGIFY2(X)
extern "C" const char SO_FILE_VERSION[]  __attribute__ ((section (".bugly_version"))) = STRINGIFY(BUGLY_VERSION);
/*****VERSION****/
static char* m_UDID = NULL;

void CopyText(std::string text)
{
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "copyText", "(Ljava/lang/String;)V"))
    {
        jstring jtext = t.env->NewStringUTF(text.c_str());
        t.env->CallStaticVoidMethod(t.classID,t.methodID,jtext);
        t.env->DeleteLocalRef(jtext);
        t.env->DeleteLocalRef(t.classID);
    }
}
std::string GetAppVersion()
{
    //获取大版本号
    char* appVersion = NULL;
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getAppVersion", "()Ljava/lang/String;"))
    {

         jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
         const char *resultC = t.env->GetStringUTFChars(jResult, NULL);

         appVersion = new char[strlen(resultC) + 2];
         strcpy(appVersion, resultC);
         t.env->ReleaseStringUTFChars(jResult, resultC);
         t.env->DeleteLocalRef(jResult);
         t.env->DeleteLocalRef(t.classID);
    }
    return std::string(appVersion);
}

void DisableIdleTimer(bool disable)
{
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "disableIdleTimer", "(Z)V")) 
    {
        t.env->CallStaticVoidMethod(t.classID,t.methodID,disable);
        t.env->DeleteLocalRef(t.classID);
    }
}
/**
 * MARK:Android中不实现的方法
 */
//CloseKeyboard
void CloseKeyboard(){}
//Register the GCM service
void RegistereForRemoteNotifications()
{
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "RegistereForRemoteNotifications", "()V")) 
    {
        t.env->CallStaticVoidMethod(t.classID,t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
}
//debug方法
void ClearOpenUdidData(){}

std::string GetOSVersion()
{   
    char* osVersion = NULL;
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getOSVersion", "()Ljava/lang/String;"))
    {

         jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
         const char *resultC = t.env->GetStringUTFChars(jResult, NULL);

         osVersion = new char[strlen(resultC) + 2];
         strcpy(osVersion, resultC);
         t.env->ReleaseStringUTFChars(jResult, resultC);
         t.env->DeleteLocalRef(jResult);
         t.env->DeleteLocalRef(t.classID);
    }
    return std::string(osVersion);
}
std::string GetDeviceModel()
{
    char* deviceModel = NULL;
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getDeviceModel", "()Ljava/lang/String;")) 
    {

         jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
         const char *resultC = t.env->GetStringUTFChars(jResult, NULL);

         deviceModel = new char[strlen(resultC) + 2];
         strcpy(deviceModel, resultC);
         t.env->ReleaseStringUTFChars(jResult, resultC);
         t.env->DeleteLocalRef(jResult);
         t.env->DeleteLocalRef(t.classID);
    }
    return std::string(deviceModel);
}
void WriteLog_(std::string str)
{
    //just print
    ((void)__android_log_print(ANDROID_LOG_DEBUG,"LuaDebug", "%s",str.c_str()));
}
std::string GetAppBundleVersion()
{
    char* appBundleVersion = NULL;
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getAppBundleVersion", "()Ljava/lang/String;")) 
    {
        jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        const char *resultC = t.env->GetStringUTFChars(jResult, NULL);

        appBundleVersion = new char[strlen(resultC) + 2];
        strcpy(appBundleVersion, resultC);
        t.env->ReleaseStringUTFChars(jResult, resultC);
        t.env->DeleteLocalRef(jResult);
        t.env->DeleteLocalRef(t.classID);
    }
    return std::string(appBundleVersion);
}
std::string GetDeviceToken()
{   
    char* deviceToken = NULL;
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "GetDeviceToken", "()Ljava/lang/String;")) 
    {

        jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        const char *resultC = t.env->GetStringUTFChars(jResult, NULL);
        deviceToken = new char[strlen(resultC) + 2];
        strcpy(deviceToken, resultC);
        t.env->ReleaseStringUTFChars(jResult, resultC);
        t.env->DeleteLocalRef(jResult);
        t.env->DeleteLocalRef(t.classID);
        return std::string(deviceToken);
    }
    return "";
}
std::string GetOpenUdid()
{
    if (m_UDID == NULL)
    {
        cocos2d::JniMethodInfo t;
        if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getUDID", "()Ljava/lang/String;")) 
        {

         jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
         const char *resultC = t.env->GetStringUTFChars(jResult, NULL);

         m_UDID = new char[strlen(resultC) + 2];
         strcpy(m_UDID, resultC);
         t.env->ReleaseStringUTFChars(jResult, resultC);
         t.env->DeleteLocalRef(jResult);
         t.env->DeleteLocalRef(t.classID);
        }
    }
    return std::string(m_UDID);
}
std::string GetDeviceLanguage()
{
    char* languageCode = NULL;
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getDeviceLanguage", "()Ljava/lang/String;")) 
    {

         jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
         const char *resultC = t.env->GetStringUTFChars(jResult, NULL);

         languageCode = new char[strlen(resultC) + 2];
         strcpy(languageCode, resultC);
         t.env->ReleaseStringUTFChars(jResult, resultC);
         t.env->DeleteLocalRef(jResult);
         t.env->DeleteLocalRef(t.classID);
    }
    return std::string(languageCode);
}
void AndroidCheckFistInstall()
{
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "checkGameFirstInstall", "()V")) 
    {
        t.env->CallStaticVoidMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
}

bool isGameLaunched()
{
    cocos2d::JniMethodInfo t;
    bool ret = false;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "isGameLaunched", "()Z")) 
    {
        ret = t.env->CallStaticBooleanMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
    return ret;
}

float GetBatteryLevel()
{
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "batteryLevel", "()F")) 
    {
        jfloat level = t.env->CallStaticFloatMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        return level;
    }
    return -1;
}
std::string GetInternetConnectionStatus()
{
    cocos2d::JniMethodInfo t;
    std::string ret("NotReachable");

    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getInternetConnectionStatus", "()Ljava/lang/String;")) 
    {
        jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        ret = cocos2d::JniHelper::jstring2string(jResult);
        t.env->DeleteLocalRef(jResult);
    }
    return ret;
}
const bool IsAppAdHocMode()
{
    cocos2d::JniMethodInfo t;
    bool ret = false;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "isAppHocMode", "()Z")) 
    {
        ret = t.env->CallStaticBooleanMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
    return ret;
}
bool IsLowMemoryDevice()
{
    cocos2d::JniMethodInfo t;
    bool ret = false;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "isLowMemoryDevice", "()Z")) 
    {
        ret = t.env->CallStaticBooleanMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
    return ret;
}

long GetAppMemoryUsage()
{
    return 0;
}

//just for android IMEI,other platform return "unknown"
std::string GetDeviceId()
{
    cocos2d::JniMethodInfo t;
    std::string ret("unknown");

    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getDeviceId", "()Ljava/lang/String;")) 
    {
        jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        ret = cocos2d::JniHelper::jstring2string(jResult);
        t.env->DeleteLocalRef(jResult);
    }
    return ret;
}
//just for android id,other platform return "unknown"
std::string GetAndroidId()
{
    cocos2d::JniMethodInfo t;
    std::string ret("unknown");

    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getAndroidId", "()Ljava/lang/String;")) 
    {
        jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        ret = cocos2d::JniHelper::jstring2string(jResult);
        t.env->DeleteLocalRef(jResult);
    }
    return ret;
}
//channelName:  gNetTop sugarcanetechnology etc..
const bool ChannelIsEqTo(std::string channelName)
{
    cocos2d::JniMethodInfo t;
    bool ret = false;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "ChannelIsEqTo", "(Ljava/lang/String;)Z"))
    {
        jstring jChannelName = t.env->NewStringUTF(channelName.c_str());
        ret = t.env->CallStaticBooleanMethod(t.classID,t.methodID,jChannelName);
        t.env->DeleteLocalRef(jChannelName);
        t.env->DeleteLocalRef(t.classID);
    }
    return ret;
}

std::string GetAppBundleId()
{
    cocos2d::JniMethodInfo t;
    std::string ret("unknown");

    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "GetAppBundleId", "()Ljava/lang/String;")) 
    {
        jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        ret = cocos2d::JniHelper::jstring2string(jResult);
        t.env->DeleteLocalRef(jResult);
    }
    return ret;
}

std::string GetBuglyId()
{
    cocos2d::JniMethodInfo t;
    std::string ret("unknown");

    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "GetBuglyId", "()Ljava/lang/String;")) 
    {
        jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        ret = cocos2d::JniHelper::jstring2string(jResult);
        t.env->DeleteLocalRef(jResult);
    }
    return ret;
}

//marketName: Apple GooglePlay Microsoft 360 etc...
const bool MarketIsEqTo(std::string marketName)
{
    cocos2d::JniMethodInfo t;
    bool ret = false;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "MarketIsEqTo", "(Ljava/lang/String;)Z"))
    {
        jstring jmarketName = t.env->NewStringUTF(marketName.c_str());
        ret = t.env->CallStaticBooleanMethod(t.classID,t.methodID,jmarketName);
        t.env->DeleteLocalRef(jmarketName);
        t.env->DeleteLocalRef(t.classID);
    }
    return ret;
}
#endif