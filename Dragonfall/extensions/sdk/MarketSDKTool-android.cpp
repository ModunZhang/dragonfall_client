
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

//MARK:LuaWarpper
static int tolua_market_onPlayerLogin(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S,1, 0, &tolua_err) ||
        !tolua_isstring(tolua_S,2, 0, &tolua_err) ||
        !tolua_isstring(tolua_S,3, 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        MarketSDKTool::getInstance()->onPlayerLogin(tolua_tostring(tolua_S, 1, 0), tolua_tostring(tolua_S, 2, 0),tolua_tostring(tolua_S, 3, 0));
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_market_onPlayerLogin'.",&tolua_err);
    return 0;
#endif
    return 0;
}

static int tolua_market_onPlayerChargeRequst(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S, 1, 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isnumber(tolua_S, 3, 0, &tolua_err) ||
        !tolua_isnumber(tolua_S, 4, 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        const char * default_currencyType = tolua_isstring(tolua_S, 5, 0, &tolua_err) ? tolua_tostring(tolua_S, 5, 0) : "USD";
        MarketSDKTool::getInstance()->onPlayerChargeRequst(tolua_tostring(tolua_S, 1, 0), tolua_tostring(tolua_S, 2, 0), tolua_tonumber(tolua_S, 3, 0), tolua_tonumber(tolua_S, 4, 0),default_currencyType);
         return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_market_onPlayerChargeRequst'.",&tolua_err);
    return 0;
#endif
    
    return 0;
}

static int tolua_market_onPlayerChargeSuccess(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S,1, 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        MarketSDKTool::getInstance()->onPlayerChargeSuccess(tolua_tostring(tolua_S, 1, 0));
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_market_onPlayerChargeSuccess'.",&tolua_err);
    return 0;
#endif
    
    return 0;
}

static int tolua_market_onPlayerBuyGameItems(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S, 1, 0, &tolua_err) ||
        !tolua_isnumber(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isnumber(tolua_S, 3, 0, &tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        MarketSDKTool::getInstance()->onPlayerBuyGameItems(tolua_tostring(tolua_S, 1, 0),tolua_tonumber(tolua_S, 2, 0),tolua_tonumber(tolua_S, 3, 0));
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_market_onPlayerBuyGameItems'.",&tolua_err);
    return 0;
#endif
    
    return 0;
}


static int tolua_market_onPlayerUseGameItems(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S, 1, 0, &tolua_err) ||
        !tolua_isnumber(tolua_S, 2, 0, &tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        MarketSDKTool::getInstance()->onPlayerUseGameItems(tolua_tostring(tolua_S, 1, 0),tolua_tonumber(tolua_S, 2, 0));
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_market_onPlayerUseGameItems'.",&tolua_err);
    return 0;
#endif
    
    return 0;
}


static int tolua_market_onPlayerReward(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isnumber(tolua_S, 1, 0, &tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        MarketSDKTool::getInstance()->onPlayerReward(tolua_tonumber(tolua_S, 1, 0),tolua_tostring(tolua_S, 2, 0));
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_market_onPlayerReward'.",&tolua_err);
    return 0;
#endif
    
    return 0;
}

static int tolua_market_onPlayerEvent(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S, 1, 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 2, 0, &tolua_err)        )
        goto tolua_lerror;
    else
#endif
    {
        MarketSDKTool::getInstance()->onPlayerEvent(tolua_tostring(tolua_S, 1, 0),tolua_tostring(tolua_S, 2, 0));
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_market_onPlayerEvent'.",&tolua_err);
    return 0;
#endif
    
    return 0;
}

static int tolua_market_onPlayerLevelUp(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isnumber(tolua_S, 1, 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        MarketSDKTool::getInstance()->onPlayerLevelUp(tolua_tonumber(tolua_S, 1, 0));
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_market_onPlayerLevelUp'.",&tolua_err);
    return 0;
#endif
    
    return 0;
}


void tolua_ext_module_market(lua_State* tolua_S)
{
    tolua_module(tolua_S,EXT_MODULE_NAME_MARKET,0);
    tolua_beginmodule(tolua_S, EXT_MODULE_NAME_MARKET);
    tolua_function(tolua_S,"onPlayerLogin",tolua_market_onPlayerLogin);
    tolua_function(tolua_S,"onPlayerChargeRequst",tolua_market_onPlayerChargeRequst);
    tolua_function(tolua_S,"onPlayerChargeSuccess",tolua_market_onPlayerChargeSuccess);
    tolua_function(tolua_S,"onPlayerBuyGameItems",tolua_market_onPlayerBuyGameItems);
    tolua_function(tolua_S,"onPlayerUseGameItems",tolua_market_onPlayerUseGameItems);
    tolua_function(tolua_S,"onPlayerReward",tolua_market_onPlayerReward);
    tolua_function(tolua_S,"onPlayerEvent",tolua_market_onPlayerEvent);
    tolua_function(tolua_S,"onPlayerLevelUp",tolua_market_onPlayerLevelUp);
    tolua_endmodule(tolua_S);
}