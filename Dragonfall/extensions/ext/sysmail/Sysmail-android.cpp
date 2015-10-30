
#include "Sysmail.h"
#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>
extern void OnSendMailEnd(int function_id,std::string event);


#define LOG_TAG ("Sysmail.cpp")
#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__))
#define LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__))
#define CLASS_NAME "com/batcatstudio/dragonfall/utils/CommonUtils"

bool CanSenMail()
{
	cocos2d::JniMethodInfo t;
	jboolean jresult = false;
   	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "canSendMail", "()Z"))
     {
        jresult = t.env->CallStaticBooleanMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
	return jresult;
}
bool SendMail(std::string to,std::string subject,std::string body,int lua_function_ref)
{
	cocos2d::JniMethodInfo t;
	jboolean jresult = false;
   	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "sendMail", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)Z"))
     {
         jstring jto = t.env->NewStringUTF(to.c_str());
         jstring jsubject = t.env->NewStringUTF(subject.c_str());
         jstring jbody = t.env->NewStringUTF(body.c_str());
         jresult = t.env->CallStaticBooleanMethod(t.classID, t.methodID,jto,jsubject,jbody);
         t.env->DeleteLocalRef(jto);
         t.env->DeleteLocalRef(jsubject);
         t.env->DeleteLocalRef(jbody);
         t.env->DeleteLocalRef(t.classID);
    }
    OnSendMailEnd(lua_function_ref,"Sent");
	return jresult;
}