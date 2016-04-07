#include "GoogleSignSDK.h"
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include "LuaBasicConversions.h"
//debug
#if (!defined NDEBUG)
#include <android/log.h>
#define LOG_TAG ("GoogleSignSDK-android.cpp")
#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__))
#define LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__))
#else
#define LOGI(...) 
#define LOGD(...)
#define LOGE(...) 
#endif /** NDEBUG **/

#define CLASS_NAME "com/batcatstudio/dragonfall/sdk/GoogleSignSDK"
#define GOOGLESIGNSDK_NATIVE_FUNCTION(function) Java_com_batcatstudio_dragonfall_sdk_##function
static GoogleSignSDK *s_GoogleSignSDK = NULL; // pointer to singleton

GoogleSignSDK::~GoogleSignSDK()
{
    if (s_GoogleSignSDK != NULL)
    {
        delete s_GoogleSignSDK;
        s_GoogleSignSDK = NULL;
    }
}

GoogleSignSDK* GoogleSignSDK::GetInstance()
{
    if (s_GoogleSignSDK == NULL)
    {
        s_GoogleSignSDK = new GoogleSignSDK();
    }
    return s_GoogleSignSDK;
}

void GoogleSignSDK::CallLuaFunction(std::string eventName,std::string userName,std::string id)
{
    if(m_listener > 0){
        cocos2d::ValueMap tempMap;
        tempMap["event"] = eventName;
        tempMap["username"] = userName;
        tempMap["userid"] = id;
        auto stack = cocos2d::LuaEngine::getInstance()->getLuaStack();
        ccvaluemap_to_luaval(stack->getLuaState(),tempMap);
        stack->executeFunctionByHandler(m_listener, 1);
    }
}

void GoogleSignSDK::Login(cocos2d::LUA_FUNCTION callback)
{
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "Login", "()V"))
    {
        m_listener = callback;
        t.env->CallStaticVoidMethod(t.classID,t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
}

std::string GoogleSignSDK::GetGoogleName()
{
    cocos2d::JniMethodInfo t;
    std::string ret = "";
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "GetGoogleUserName", "()Ljava/lang/String;"))
    {
        jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID,t.methodID);
        ret = cocos2d::JniHelper::jstring2string(jResult);
    }
    return ret;
}
std::string GoogleSignSDK::GetGoogleId()
{
    cocos2d::JniMethodInfo t;
    std::string ret = "";
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "GetGoogleId", "()Ljava/lang/String;"))
    {
        jstring jResult = (jstring)t.env->CallStaticObjectMethod(t.classID,t.methodID);
        ret = cocos2d::JniHelper::jstring2string(jResult);
    }
    return ret;
}
bool GoogleSignSDK::IsAuthenticated()
{
    jboolean ret = JNI_FALSE;
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "IsAuthenticated", "()Z"))
    {
        ret = t.env->CallStaticBooleanMethod(t.classID,t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }    
    return ret;
}

static int tolua_google_login(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!toluafix_isfunction(tolua_S, 1, "LUA_FUNCTION", 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        cocos2d::LUA_FUNCTION func = toluafix_ref_function(tolua_S, 1, 0);
        GoogleSignSDK::GetInstance()->Login(func);
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror :
    tolua_error(tolua_S, "#ferror in function 'tolua_google_login'.", &tolua_err);
    return 0;
#endif
}

static int tolua_google_getGoogleNameAndId(lua_State *tolua_S)
{
    std::string name = GoogleSignSDK::GetInstance()->GetGoogleName();
    std::string id = GoogleSignSDK::GetInstance()->GetGoogleId();
    tolua_pushcppstring(tolua_S,name);
    tolua_pushcppstring(tolua_S,id);
    return 2;
}

static int tolua_google_isAuthenticated(lua_State *tolua_S)
{
    tolua_pushboolean(tolua_S, GoogleSignSDK::GetInstance()->IsAuthenticated());
    return 1;
}

void tolua_ext_module_google(lua_State* tolua_S)
{
	tolua_module(tolua_S,EXT_MODULE_NAME_GOOGLE,0);
    tolua_beginmodule(tolua_S, EXT_MODULE_NAME_GOOGLE);
    tolua_function(tolua_S,"login",tolua_google_login);
    tolua_function(tolua_S,"getPlayerNameAndId",tolua_google_getGoogleNameAndId);
    tolua_function(tolua_S,"isAuthenticated",tolua_google_isAuthenticated);
    tolua_endmodule(tolua_S);
}
/*** Native ***/
extern "C" {

    JNIEXPORT void JNICALL GOOGLESIGNSDK_NATIVE_FUNCTION(GoogleSignSDK_GoogleSignEvent)(JNIEnv*  env, jclass cls,jstring eventName,jstring userName,jstring id) 
    {
        GoogleSignSDK::GetInstance()->CallLuaFunction(cocos2d::JniHelper::jstring2string(eventName),
            cocos2d::JniHelper::jstring2string(userName),cocos2d::JniHelper::jstring2string(id));
    }
}
#endif /* CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID */