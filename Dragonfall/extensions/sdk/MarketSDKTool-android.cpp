
#include "MarketSDKTool.h"
#include "tolua_fix.h"
#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>

#define LOG_TAG ("MarketSDKTool-android.cpp")
#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__))
#define LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__))
#define CLASS_NAME "com/batcatstudio/dragonfall/sdk/MarketSDK"

static MarketSDKTool *s_MarketSDKTool = NULL; // pointer to singleton

MarketSDKTool * MarketSDKTool::getInstance()
{
    if(!s_MarketSDKTool)
    {
        s_MarketSDKTool = new MarketSDKTool();
    }
    return s_MarketSDKTool;
}

void MarketSDKTool::destroyInstance()
{
     if(s_MarketSDKTool)
     {
         delete s_MarketSDKTool;
         s_MarketSDKTool = NULL;
     }
}

void MarketSDKTool::initSDK()
{
    //Java代码中初始化
}

void MarketSDKTool::onPlayerLogin(const char *playerId,const char*playerName,const char*serverName)
{
#ifdef CC_USE_TAKING_DATA
  	cocos2d::JniMethodInfo t;
   	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "onPlayerLogin", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"))
     {
         jstring jplayerId = t.env->NewStringUTF(playerId);
         jstring jplayerName = t.env->NewStringUTF(playerName);
         jstring jserverName = t.env->NewStringUTF(serverName);
         t.env->CallStaticVoidMethod(t.classID, t.methodID,jplayerId,jplayerName,jserverName);
         t.env->DeleteLocalRef(jplayerId);
         t.env->DeleteLocalRef(jplayerName);
         t.env->DeleteLocalRef(jserverName);
         t.env->DeleteLocalRef(t.classID);
    }
#endif
}

void MarketSDKTool::onPlayerChargeRequst(const char *orderID, const char *productId, double currencyAmount, double virtualCurrencyAmount,const char *currencyType)
{
#ifdef CC_USE_TAKING_DATA
    cocos2d::JniMethodInfo t;
   	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "onPlayerChargeRequst", "(Ljava/lang/String;Ljava/lang/String;DDLjava/lang/String;)V")) 
    {
        jstring jorderID = t.env->NewStringUTF(orderID);
        jstring jproductId = t.env->NewStringUTF(productId);
        jstring jcurrencyType = t.env->NewStringUTF(currencyType);
        t.env->CallStaticVoidMethod(t.classID, t.methodID,jorderID,jproductId,currencyAmount,virtualCurrencyAmount,jcurrencyType);
        t.env->DeleteLocalRef(jorderID);
        t.env->DeleteLocalRef(jproductId);
        t.env->DeleteLocalRef(jcurrencyType);
        t.env->DeleteLocalRef(t.classID);
    }
#endif
}


void MarketSDKTool::onPlayerChargeSuccess(const char *orderID)
{
#ifdef CC_USE_TAKING_DATA
    cocos2d::JniMethodInfo t;
   	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "onPlayerChargeSuccess", "(Ljava/lang/String;)V")) 
    {
        jstring jorderID = t.env->NewStringUTF(orderID);
        t.env->CallStaticVoidMethod(t.classID, t.methodID,jorderID);
        t.env->DeleteLocalRef(jorderID);
        t.env->DeleteLocalRef(t.classID);
    }
#endif
}

void MarketSDKTool::onPlayerBuyGameItems(const char *itemID, int count, double itemPrice)
{
#ifdef CC_USE_TAKING_DATA
     cocos2d::JniMethodInfo t;
   	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "onPlayerBuyGameItems", "(Ljava/lang/String;ID)V")) 
    {   
        jstring jitemID = t.env->NewStringUTF(itemID);
        t.env->CallStaticVoidMethod(t.classID, t.methodID,jitemID,count,itemPrice);
        t.env->DeleteLocalRef(jitemID);
        t.env->DeleteLocalRef(t.classID);
    }
#endif
}


void MarketSDKTool::onPlayerUseGameItems(const char *itemID,int count)
{
#ifdef CC_USE_TAKING_DATA
    cocos2d::JniMethodInfo t;
   	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "onPlayerUseGameItems", "(Ljava/lang/String;I)V")) 
    {   
        jstring jitemID = t.env->NewStringUTF(itemID);
        t.env->CallStaticVoidMethod(t.classID, t.methodID,jitemID,count);
        t.env->DeleteLocalRef(jitemID);
        t.env->DeleteLocalRef(t.classID);
    }
#endif
}

void MarketSDKTool::onPlayerReward(double count,const char* reason)
{
#ifdef CC_USE_TAKING_DATA
    cocos2d::JniMethodInfo t;
   	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "onPlayerReward", "(DLjava/lang/String;)V")) 
    {
         jstring jreason = t.env->NewStringUTF(reason);
         t.env->CallStaticVoidMethod(t.classID, t.methodID,count,jreason);
         t.env->DeleteLocalRef(jreason);
         t.env->DeleteLocalRef(t.classID);
    }
#endif
}

void MarketSDKTool::onPlayerEvent(const char *event_id,const char*arg)
{
#ifdef CC_USE_TAKING_DATA
    cocos2d::JniMethodInfo t;
   	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "onPlayerEvent", "(Ljava/lang/String;Ljava/lang/String;)V")) 
    {
        jstring jevent_id = t.env->NewStringUTF(event_id);
        jstring jarg = t.env->NewStringUTF(arg);
         t.env->CallStaticVoidMethod(t.classID, t.methodID,jevent_id,jarg);
         t.env->DeleteLocalRef(jevent_id);
         t.env->DeleteLocalRef(jarg);
         t.env->DeleteLocalRef(t.classID);
    }
#endif
}

void MarketSDKTool::onPlayerEventAF(const char *event_id,const char*arg)
{
#ifdef CC_USE_TAKING_DATA
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "onPlayerEventAF", "(Ljava/lang/String;Ljava/lang/String;)V")) 
    {
        jstring jevent_id = t.env->NewStringUTF(event_id);
        jstring jarg = t.env->NewStringUTF(arg);
         t.env->CallStaticVoidMethod(t.classID, t.methodID,jevent_id,jarg);
         t.env->DeleteLocalRef(jevent_id);
         t.env->DeleteLocalRef(jarg);
         t.env->DeleteLocalRef(t.classID);
    }
#endif
}

void MarketSDKTool::onPlayerLevelUp(int level)
{
#ifdef CC_USE_TAKING_DATA
    cocos2d::JniMethodInfo t;
   	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "onPlayerLevelUp", "(I)V"))
    {
         t.env->CallStaticVoidMethod(t.classID, t.methodID,level);
         t.env->DeleteLocalRef(t.classID);
    }
#endif
}