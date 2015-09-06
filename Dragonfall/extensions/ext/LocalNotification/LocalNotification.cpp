#include "LocalNotification.h"
#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>
#define LOG_TAG ("LocalNotification.cpp")
#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__))
#define LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__))
#define CLASS_NAME "com/batcatstudio/dragonfall/notifications/NotificationUtils"


void cancelAll()
{
	cocos2d::JniMethodInfo t;
   	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "cancelAllLocalPush", "()V"))
     {
		t.env->CallStaticVoidMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
}

void switchNotification(const char *type, bool enable)
{

}
bool addNotification(const char *type, long finishTime, const char *body, const char* identity)
{
	cocos2d::JniMethodInfo t;
	jboolean jresult = false;
   	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "addLocalPush", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;J)Z"))
    {
        jstring jtype = t.env->NewStringUTF(type);
        jstring jbody = t.env->NewStringUTF(body);
        jstring jidentity = t.env->NewStringUTF(identity);
        jlong fireTime = (jlong) finishTime * 1000;
        jresult = t.env->CallStaticBooleanMethod(t.classID, t.methodID,jtype,jbody,jidentity,fireTime);
        t.env->DeleteLocalRef(jidentity);
        t.env->DeleteLocalRef(jbody);
        t.env->DeleteLocalRef(jtype);
        t.env->DeleteLocalRef(t.classID);
    }
	return jresult;
}
bool cancelNotificationWithIdentity(const char* identity)
{
	cocos2d::JniMethodInfo t;
	jboolean jresult = false;
   	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "cancelNotificationWithIdentity", "(Ljava/lang/String;)Z"))
     {
     	jstring jsidentity = t.env->NewStringUTF(identity);
        jresult = t.env->CallStaticBooleanMethod(t.classID, t.methodID,jsidentity);
        t.env->DeleteLocalRef(jsidentity);
        t.env->DeleteLocalRef(t.classID);
    }
	return jresult;
}