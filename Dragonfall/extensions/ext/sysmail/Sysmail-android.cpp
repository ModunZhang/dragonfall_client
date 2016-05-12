
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

static void createArrayList(){
    cocos2d::JniMethodInfo t;
    if( cocos2d::JniHelper::getStaticMethodInfo(t
                                       , "org/cocos2dx/utils/PSJNIHelper"
                                       , "createArrayList"
                                       , "()V"))
    {
        t.env->CallStaticVoidMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
}

static jobject getArrayList(){
    cocos2d::JniMethodInfo t;
    if( cocos2d::JniHelper::getStaticMethodInfo(t
                                       , "org/cocos2dx/utils/PSJNIHelper"
                                       , "getArrayList"
                                       , "()Ljava/util/ArrayList;"))
    {
        jobject jobj = (jobject)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        return jobj;
    }
    return NULL;
    
}

static void pushArrayListElement(std::string value){
    cocos2d::JniMethodInfo t;
    if( cocos2d::JniHelper::getStaticMethodInfo(t
                                       , "org/cocos2dx/utils/PSJNIHelper"
                                       , "pushArrayListElement"
                                       , "(Ljava/lang/String;)V"))
    {
        jstring jvalue = t.env->NewStringUTF(value.c_str());
        
        t.env->CallStaticVoidMethod(t.classID, t.methodID, jvalue);
        
        t.env->DeleteLocalRef(jvalue);
        t.env->DeleteLocalRef(t.classID);
    }
}

static jobject vector_string_to_arraylist_object(std::vector<std::string> strings)
{
    createArrayList();
    for (std::string address:strings)
    {
        pushArrayListElement(address);
    }
    
    return getArrayList();
}

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

bool SendMail(std::vector<std::string> to,std::string subject,std::string body,int lua_function_ref)
{
	cocos2d::JniMethodInfo t;
	jboolean jresult = false;
   	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "sendMail", "(Ljava/util/ArrayList;Ljava/lang/String;Ljava/lang/String;)Z"))
     {
         jobject jto = vector_string_to_arraylist_object(to);
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
