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
}

extern "C" {

    JNIEXPORT void JNICALL FaceBookSDK_NATIVE_FUNCTION(FaceBookSDK_initJNI)(JNIEnv*  env, jclass cls) 
    {
        if (!initJNI(env, cls)) {
            LOGE("initJNI failed");
        }
    }
}

//MARK:FaceBookSDK cpp part
static FacebookSDK *s_FacebookSDK = NULL; // pointer to singleton

void FacebookSDK::Initialize(std::string appId /* = "" */)
{
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
    return false;
}

std::string FacebookSDK::GetFBUserName()
{
    return std::string("");
}

std::string FacebookSDK::GetFBUserId()
{
    return std::string("");
}

/**
 *  登录facebook
 */
void FacebookSDK::Login()
{
}
#endif