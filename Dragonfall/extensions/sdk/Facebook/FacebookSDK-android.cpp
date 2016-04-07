#include "FacebookSDK.h"
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
//debug
#if (!defined NDEBUG)
#include <android/log.h>
#define LOG_TAG ("FacebookSDK-android.cpp")
#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__))
#define LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__))
#else
#define LOGI(...) 
#define LOGD(...)
#define LOGE(...) 
#endif /** NDEBUG **/

#define CLASS_NAME "com/batcatstudio/dragonfall/sdk/FaceBookSDK"
#define FaceBookSDK_NATIVE_FUNCTION(function) Java_com_batcatstudio_dragonfall_sdk_##function

//MARK:Jni native method

static jclass jcFaceBookSDK = NULL;
static jmethodID jmInitialize = NULL;
static jmethodID jmIsAuthenticated = NULL;
static jmethodID jmLogin = NULL;
static jmethodID jmGetFBUserName = NULL;
static jmethodID jmGetFBUserId = NULL;
static jmethodID jmAppInvite = NULL;
//method
static bool initJNI(JNIEnv* env, jclass cls) 
{
    if (env == NULL) {
        LOGE("env null error");
        return false;
    }

    jcFaceBookSDK = (jclass) env->NewGlobalRef(cls);
    if (jcFaceBookSDK == NULL) { /* Exception thrown */
        LOGE("Get jcFaceBookSDK failed");
        return false;
    }

    jmInitialize = env->GetStaticMethodID(jcFaceBookSDK, "Initialize", "()V");
    if (jmInitialize == NULL)
    {
        LOGE("Get jmInitialize failed");
        return false;
    }
    
    jmIsAuthenticated = env->GetStaticMethodID(jcFaceBookSDK, "IsAuthenticated", "()Z");
    if(jmIsAuthenticated == NULL)
    {
        LOGE("Get jmIsAuthenticated failed");
        return false;
    } 

    jmLogin = env->GetStaticMethodID(jcFaceBookSDK, "Login", "()V");
    if(jmLogin == NULL)
    {
        LOGE("Get jmLogin failed");
        return false;
    }

    jmGetFBUserName = env->GetStaticMethodID(jcFaceBookSDK, "GetFBUserName", "()Ljava/lang/String;");
    if(jmGetFBUserName == NULL)
    {
        LOGE("Get jmGetFBUserName failed");
        return false;
    } 

    jmGetFBUserId = env->GetStaticMethodID(jcFaceBookSDK, "GetFBUserId", "()Ljava/lang/String;");
    if(jmGetFBUserId == NULL)
    {
        LOGE("Get jmGetFBUserId failed");
        return false;
    }
    jmAppInvite = env->GetStaticMethodID(jcFaceBookSDK, "AppInvite", "(Ljava/lang/String;Ljava/lang/String;)V");
    if(jmAppInvite == NULL)
    {
        LOGE("Get jmAppInvite failed");
        return false;
    }
    
    return true;
}

extern "C" {

    JNIEXPORT void JNICALL FaceBookSDK_NATIVE_FUNCTION(FaceBookSDK_initJNI)(JNIEnv*  env, jclass cls) 
    {
        if (!initJNI(env, cls)) {
            LOGE("initJNI FacebookSDK failed");
        }
    }
    JNIEXPORT void JNICALL FaceBookSDK_NATIVE_FUNCTION(FaceBookSDK_FaceBookEvent)(JNIEnv*  env, jclass cls,jstring eventName,jstring fbUserName,jstring fbUserId) 
    {
        LOGD("FaceBookSDK_FaceBookEvent");
        cocos2d::ValueMap tempMap;
        tempMap["event"] = cocos2d::JniHelper::jstring2string(eventName);
        tempMap["username"] = cocos2d::JniHelper::jstring2string(fbUserName);
        tempMap["userid"] = cocos2d::JniHelper::jstring2string(fbUserId);
        FacebookSDK::GetInstance()->CallLuaCallback(tempMap);
    }
}

//MARK:FaceBookSDK cpp part
static FacebookSDK *s_FacebookSDK = NULL; // pointer to singleton

void FacebookSDK::Initialize(std::string appId /* = "" */)
{
    if(NULL == jmInitialize) {
        return;
    }
    JNIEnv* env = cocos2d::JniHelper::getEnv();
    env->CallStaticVoidMethod(jcFaceBookSDK,jmInitialize);
}

FacebookSDK::~FacebookSDK()
{
    if (s_FacebookSDK != NULL)
    {
        delete s_FacebookSDK;
        s_FacebookSDK = NULL;
    }
}

FacebookSDK* FacebookSDK::GetInstance()
{
    if (s_FacebookSDK == NULL)
    {
        s_FacebookSDK = new FacebookSDK();
    }
    return s_FacebookSDK;
}
/*
 * 返回是否已经有取到过账号
 */
bool FacebookSDK::IsAuthenticated()
{
    if(NULL == jmIsAuthenticated)
    {
        return false;
    }
    jboolean ret = JNI_FALSE;
    JNIEnv* env = cocos2d::JniHelper::getEnv();
    ret = env->CallStaticBooleanMethod(jcFaceBookSDK,jmIsAuthenticated);
    return ret;
}

std::string FacebookSDK::GetFBUserName()
{
    std::string ret = "";
    if (NULL != jmGetFBUserName)
    {
        JNIEnv* env = cocos2d::JniHelper::getEnv();
        jstring jResult = (jstring)env->CallStaticObjectMethod(jcFaceBookSDK, jmGetFBUserName);
        ret = cocos2d::JniHelper::jstring2string(jResult);
    }
    return ret;
}

std::string FacebookSDK::GetFBUserId()
{
    std::string ret = "";
    if (NULL != jmGetFBUserId)
    {
        JNIEnv* env = cocos2d::JniHelper::getEnv();
        jstring jResult = (jstring)env->CallStaticObjectMethod(jcFaceBookSDK, jmGetFBUserId);
        ret = cocos2d::JniHelper::jstring2string(jResult);
    }
    return ret;
}
void FacebookSDK::AppInvite(std::string title,std::string message)
{
    if (NULL != jmAppInvite)
    {
        JNIEnv* env = cocos2d::JniHelper::getEnv();
        jstring jtitle = env->NewStringUTF(title.c_str());
        jstring jmessage = env->NewStringUTF(message.c_str());
        env->CallStaticVoidMethod(jcFaceBookSDK, jmAppInvite,jtitle,jmessage);
        env->DeleteLocalRef(jtitle);
        env->DeleteLocalRef(jmessage);
    }
}
/**
 *  登录facebook
 */
void FacebookSDK::Login()
{
    if(NULL == jmLogin)
    {
        return;
    }
    JNIEnv* env = cocos2d::JniHelper::getEnv();
    env->CallStaticVoidMethod(jcFaceBookSDK,jmLogin);
}
#endif