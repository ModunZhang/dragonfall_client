//
//  PayPalSDK.cpp
//  Dragonfall
//
//  Created by DannyHe on 3/3/16.
//
//

#include "PayPalSDK.h"
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
//debug
#if (!defined NDEBUG)
#include <android/log.h>
#define LOG_TAG ("PayPalSDK-android.cpp")
#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__))
#define LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__))
#else
#define LOGI(...) 
#define LOGD(...)
#define LOGE(...) 
#endif /** NDEBUG **/

#define CLASS_NAME "com/batcatstudio/dragonfall/sdk/PayPalSDK"
#define PayPalSDKSDK_NATIVE_FUNCTION(function) Java_com_batcatstudio_dragonfall_sdk_##function
static PayPalSDK *s_PayPalSDK = NULL; // pointer to singleton

PayPalSDK::~PayPalSDK()
{
    if (s_PayPalSDK != NULL)
    {
        delete s_PayPalSDK;
        s_PayPalSDK = NULL;
    }
}

PayPalSDK* PayPalSDK::GetInstance()
{
    if (s_PayPalSDK == NULL)
    {
        s_PayPalSDK = new PayPalSDK();
    }
    return s_PayPalSDK;
}

void PayPalSDK::buy(std::string itemName,std::string itemKey,double price)
{
	cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "paypalBuy", "(Ljava/lang/String;Ljava/lang/String;D)V"))
    {
        jstring jitemName = t.env->NewStringUTF(itemName.c_str());
        jstring jitemKey = t.env->NewStringUTF(itemKey.c_str());
        t.env->CallStaticVoidMethod(t.classID,t.methodID,jitemName,jitemKey,price);
        t.env->DeleteLocalRef(jitemName);
        t.env->DeleteLocalRef(jitemKey);
        t.env->DeleteLocalRef(t.classID);
    }
}

void PayPalSDK::postInitWithTransactionListenerLua(cocos2d::LUA_FUNCTION listener,cocos2d::LUA_FUNCTION listener_failed)
{
	m_listener = listener;
	m_listener_failed = listener_failed;
}

bool PayPalSDK::isPayPalSupport()
{
	cocos2d::JniMethodInfo t;
	bool ret = false;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "isPayPalSupport", "()Z"))
    {
        ret = t.env->CallStaticBooleanMethod(t.classID,t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
    return ret;
}

void PayPalSDK::onPayPalDone(std::string paymentId,std::string payment)
{
	if(m_listener)
	{
		auto stack = cocos2d::LuaEngine::getInstance()->getLuaStack();
        stack->pushString(paymentId.c_str());
        stack->pushString(payment.c_str());
        stack->executeFunctionByHandler(m_listener, 2);
	}
}

void PayPalSDK::onPayPalFailed()
{
	if(m_listener_failed)
	{
		auto stack = cocos2d::LuaEngine::getInstance()->getLuaStack();
        stack->executeFunctionByHandler(m_listener_failed, 0);
	}
}

void PayPalSDK::updatePaypalPayments()
{
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "updatePaypalPayments", "()V"))
    {
        t.env->CallStaticVoidMethod(t.classID,t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
}
void PayPalSDK::consumePaypalPayment(std::string paymentId)
{
    cocos2d::JniMethodInfo t;
    if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "consumePaypalPayment", "(Ljava/lang/String;)V"))
    {
        jstring jitemKey = t.env->NewStringUTF(paymentId.c_str());
        t.env->CallStaticVoidMethod(t.classID,t.methodID,jitemKey);
        t.env->DeleteLocalRef(jitemKey);
        t.env->DeleteLocalRef(t.classID);
    }
}

/*** toLua ***/

static int tolua_ext_paypal_postInitWithTransactionListenerLua(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!toluafix_isfunction(tolua_S,1,"LUA_FUNCTION",0,&tolua_err)||
        !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        cocos2d::LUA_FUNCTION callback = (  toluafix_ref_function(tolua_S,1,0));
        cocos2d::LUA_FUNCTION callback_failed = (  toluafix_ref_function(tolua_S,2,0));
        PayPalSDK::GetInstance()->postInitWithTransactionListenerLua(callback,callback_failed);
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_ext_paypal_postInitWithTransactionListenerLua'.",&tolua_err);
    return 0;
#endif
}

static int tolua_ext_paypal_consumePaypalPayment(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S, 1, 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        std::string itemKey = tolua_tostring(tolua_S,1,0);
        PayPalSDK::GetInstance()->consumePaypalPayment(itemKey);
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_ext_paypal_consumePaypalPayment'.",&tolua_err);
    return 0;
#endif
}

static int tolua_ext_paypal_updatePaypalPayments(lua_State *tolua_S)
{
    PayPalSDK::GetInstance()->updatePaypalPayments();
    return 0;
}

static int tolua_ext_paypal_isPayPalSupport(lua_State *tolua_S)
{
    bool ret = PayPalSDK::GetInstance()->isPayPalSupport();
    tolua_pushboolean(tolua_S,ret);
    return 1;
}

static int tolua_ext_paypal_buy(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S, 1, 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 2, 0, &tolua_err) ||
    	!tolua_isnumber(tolua_S, 3, 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        std::string itemName = tolua_tostring(tolua_S,1,0);
    	std::string itemKey = tolua_tostring(tolua_S,2,0);
    	double price = tolua_tonumber(tolua_S, 3, 0);
    	PayPalSDK::GetInstance()->buy(itemName,itemKey,price);
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_ext_paypal_buy'.",&tolua_err);
    return 0;
#endif
}

void tolua_ext_module_paypal(lua_State* tolua_S)
{
	tolua_module(tolua_S,EXT_MODULE_NAME_PAYAPL,0);
    tolua_beginmodule(tolua_S, EXT_MODULE_NAME_PAYAPL);
    tolua_function(tolua_S,"buy",tolua_ext_paypal_buy);
    tolua_function(tolua_S,"init",tolua_ext_paypal_postInitWithTransactionListenerLua);
    tolua_function(tolua_S,"isPayPalSupport",tolua_ext_paypal_isPayPalSupport);
    tolua_function(tolua_S,"updatePaypalPayments",tolua_ext_paypal_updatePaypalPayments);
    tolua_function(tolua_S,"consumePurchase",tolua_ext_paypal_consumePaypalPayment);
    tolua_endmodule(tolua_S);
}
/*** Native ***/
extern "C" {

    JNIEXPORT void JNICALL PayPalSDKSDK_NATIVE_FUNCTION(PayPalSDK_onPayPalDone)(JNIEnv*  env, jclass cls,jstring jPaymentId,jstring jPaymentJson) 
    {
        PayPalSDK::GetInstance()->onPayPalDone(cocos2d::JniHelper::jstring2string(jPaymentId),cocos2d::JniHelper::jstring2string(jPaymentJson));
    }
    JNIEXPORT void JNICALL PayPalSDKSDK_NATIVE_FUNCTION(PayPalSDK_onPayPalFailed)(JNIEnv*  env, jclass cls)
    {
        PayPalSDK::GetInstance()->onPayPalFailed();
    }

    JNIEXPORT jstring JNICALL PayPalSDKSDK_NATIVE_FUNCTION(PayPalSDK_getPaypalSeedCode)(JNIEnv*  env, jclass cls)
    {
        return env->NewStringUTF("batcat");
    }

}
#endif /* CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID */