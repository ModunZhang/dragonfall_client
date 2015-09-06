#include "jni_CommonUtils.h"
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

static char* m_UDID = NULL;

void CopyText(const char * text)
{
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "copyText", "(Ljava/lang/String;)V")) {
        jstring jtext = t.env->NewStringUTF(text);
        t.env->CallStaticVoidMethod(t.classID,t.methodID,jtext);
        t.env->DeleteLocalRef(jtext);
        t.env->DeleteLocalRef(t.classID);
    }
}
const char* GetAppVersion()
{
    //获取大版本号
    char* appVersion = NULL;
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getAppVersion", "()Ljava/lang/String;")) {

         jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
         const char *resultC = t.env->GetStringUTFChars(jResult, NULL);

         appVersion = new char[strlen(resultC) + 2];
         strcpy(appVersion, resultC);
         t.env->ReleaseStringUTFChars(jResult, resultC);
         t.env->DeleteLocalRef(jResult);
         t.env->DeleteLocalRef(t.classID);
    }
    return appVersion;
}

void DisableIdleTimer(bool disable)
{
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "disableIdleTimer", "(Z)V")) {
        t.env->CallStaticVoidMethod(t.classID,t.methodID,disable);
        t.env->DeleteLocalRef(t.classID);
    }
}
void CloseKeyboard()
{
    LOGD("CloseKeyboard暂不实现");
}
const char* GetOSVersion()
{   
    char* osVersion = NULL;
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getOSVersion", "()Ljava/lang/String;")) {

         jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
         const char *resultC = t.env->GetStringUTFChars(jResult, NULL);

         osVersion = new char[strlen(resultC) + 2];
         strcpy(osVersion, resultC);
         t.env->ReleaseStringUTFChars(jResult, resultC);
         t.env->DeleteLocalRef(jResult);
         t.env->DeleteLocalRef(t.classID);
    }
    return osVersion;
}
const char* GetDeviceModel()
{
    char* deviceModel = NULL;
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getDeviceModel", "()Ljava/lang/String;")) {

         jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
         const char *resultC = t.env->GetStringUTFChars(jResult, NULL);

         deviceModel = new char[strlen(resultC) + 2];
         strcpy(deviceModel, resultC);
         t.env->ReleaseStringUTFChars(jResult, resultC);
         t.env->DeleteLocalRef(jResult);
         t.env->DeleteLocalRef(t.classID);
    }
    return deviceModel;
}
void WriteLog_(const char *str)
{
    //just print
    ((void)__android_log_print(ANDROID_LOG_DEBUG,"LuaDebug", "%s",str));
}
const char* GetAppBundleVersion()
{
    char* appBundleVersion = NULL;
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getAppBundleVersion", "()Ljava/lang/String;")) {

         jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
         const char *resultC = t.env->GetStringUTFChars(jResult, NULL);

         appBundleVersion = new char[strlen(resultC) + 2];
         strcpy(appBundleVersion, resultC);
         t.env->ReleaseStringUTFChars(jResult, resultC);
         t.env->DeleteLocalRef(jResult);
         t.env->DeleteLocalRef(t.classID);
    }
    return appBundleVersion;
}
const char* GetDeviceToken()
{
    LOGD("Android GetDeviceToken暂不实现");
    return "";
}
const char* GetOpenUdid()
{
    if (m_UDID == NULL)
    {
         cocos2d::JniMethodInfo t;
         if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getUDID", "()Ljava/lang/String;")) {

             jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
             const char *resultC = t.env->GetStringUTFChars(jResult, NULL);

             m_UDID = new char[strlen(resultC) + 2];
             strcpy(m_UDID, resultC);
             t.env->ReleaseStringUTFChars(jResult, resultC);
             t.env->DeleteLocalRef(jResult);
             t.env->DeleteLocalRef(t.classID);
         }
     }
    return m_UDID;
}
void registereForRemoteNotifications()
{
    LOGD("Android registereForRemoteNotifications暂不实现");
}
void ClearOpenUdidData()
{
}
const char* GetDeviceLanguage()
{
    char* languageCode = NULL;
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getDeviceLanguage", "()Ljava/lang/String;")) {

         jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
         const char *resultC = t.env->GetStringUTFChars(jResult, NULL);

         languageCode = new char[strlen(resultC) + 2];
         strcpy(languageCode, resultC);
         t.env->ReleaseStringUTFChars(jResult, resultC);
         t.env->DeleteLocalRef(jResult);
         t.env->DeleteLocalRef(t.classID);
    }
    return languageCode;
}
void AndroidCheckFistInstall()
{
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "checkGameFirstInstall", "()V")) {
         t.env->CallStaticVoidMethod(t.classID, t.methodID);
         t.env->DeleteLocalRef(t.classID);
    }
}
float getBatteryLevel()
{
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "batteryLevel", "()F")) {
        jfloat level = t.env->CallStaticFloatMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        return level;
    }
    return -1;
}
const char* getInternetConnectionStatus()
{
    cocos2d::JniMethodInfo t;
    std::string ret("NotReachable");

    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getInternetConnectionStatus", "()Ljava/lang/String;")) {
        jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        ret = cocos2d::JniHelper::jstring2string(jResult);
        t.env->DeleteLocalRef(jResult);
    }
    return ret.c_str();
}
const bool isAppAdHocMode()
{
    cocos2d::JniMethodInfo t;
    bool ret = false;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "isAppHocMode", "()Z")) {
        ret = t.env->CallStaticBooleanMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
    LOGD("isAppAdHocMode---->%d",ret);
    return ret;
}