
#include "jni_StoreKit.h"
#include "CCLuaValue.h"
#include "CCLuaStack.h"
#include "CCLuaEngine.h"
#include "tolua_fix.h"
#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#if (!defined NDEBUG)
#include <android/log.h>
#define LOG_TAG ("jni_StoreKit.cpp")
#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__))
#define LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__))
#else
#define LOGI(...) 
#define LOGD(...)
#define LOGE(...) 
#endif /** NDEBUG **/
#define CLASS_NAME "com/batcatstudio/dragonfall/google/billing/StoreKit"
#define HASHSET_CLASS "java/util/HashSet"
#define LIST_CLASS "java/util/ArrayList"
#define STORE_NATIVE_FUNCTION(function) Java_com_batcatstudio_dragonfall_google_billing_##function


static jclass jcStoreKit = NULL;
static jmethodID jmBuy = NULL;
static jmethodID jmConsumePurchase = NULL;
static jclass jcHashSet = NULL;
static jmethodID jmInitHashSet = NULL;
static jmethodID jmAddHashSet = NULL;
static jmethodID jmRequestProductData = NULL;
static jmethodID jmUpdateTransactionStates = NULL;
static jclass jcList = NULL;
static jmethodID jmInitList = NULL;
static jmethodID jmAddList = NULL;
static jmethodID jmIsGMSSupport = NULL;
static jmethodID jmGetGMSSupport = NULL;


static cocos2d::LUA_FUNCTION m_loadProductsCallback = 0;
static cocos2d::LUA_FUNCTION m_listener = 0;
static cocos2d::LUA_FUNCTION m_listener_failed = 0;

static bool m_isLoadProductsLuaNotCompleted = false;

static bool initJNI(JNIEnv* env, jclass cls) {
    if (env == NULL) {
        LOGE("env null error");
        return false;
    }

    jcStoreKit = (jclass) env->NewGlobalRef(cls);
    if (jcStoreKit == NULL) { /* Exception thrown */
        LOGE("Get jcStoreKit failed");
        return false;
    }

    jmIsGMSSupport = env->GetStaticMethodID(jcStoreKit, "isGMSSupport", "()Z");
    if (jmIsGMSSupport == NULL)
    {
        LOGE("Get jmIsGMSSupport failed");
        return false;
    }

    jmGetGMSSupport = env->GetStaticMethodID(jcStoreKit, "getGMSSupport", "()V");
    if (jmGetGMSSupport == NULL)
    {
        LOGE("Get jmGetGMSSupport failed");
        return false;
    }

    jmBuy = env->GetStaticMethodID(jcStoreKit, "buy", "(Ljava/lang/String;)V");
    if (jmBuy == NULL) {
        LOGE("Get jmBuy failed");
        return false;
    }
    jmConsumePurchase =  env->GetStaticMethodID(jcStoreKit, "consumePurchase", "(Ljava/lang/String;)V");
    if (jmConsumePurchase == NULL) {
        LOGE("Get jmConsumePurchase failed");
        return false;
    }

    jmRequestProductData = env->GetStaticMethodID(jcStoreKit, "requestProductData", "(Ljava/util/Set;)V");
    if (jmRequestProductData == NULL) {
        LOGE("Get jmRequestProductData failed");
        return false;
    }


    jmUpdateTransactionStates = env->GetStaticMethodID(jcStoreKit, "updateTransactionStates", "(Ljava/util/ArrayList;)V");
    if (jmUpdateTransactionStates == NULL) {
        LOGE("Get jmUpdateTransactionStates failed");
        return false;
    }
    //hashset
    jclass localRefCls = env->FindClass(HASHSET_CLASS);
    if (localRefCls == NULL) { /* Exception thrown */
        LOGE("Get jcHashSet failed");
        return false;
    }
    jcHashSet = (jclass) env->NewGlobalRef(localRefCls);
    env->DeleteLocalRef(localRefCls);

    jmInitHashSet = env->GetMethodID(jcHashSet, "<init>", "()V");
    if (jmInitHashSet == NULL) {
        LOGE("Get jmInitHashSet failed");
        return false;
    }

    jmAddHashSet = env->GetMethodID(jcHashSet, "add", "(Ljava/lang/Object;)Z");
    if (jmAddHashSet == NULL) {
        LOGE("Get jmAddHashSet failed");
        return false;
    }
    //list
    jclass localRefCls_List = env->FindClass(LIST_CLASS);
    if (localRefCls_List == NULL) { /* Exception thrown */
        LOGE("Get jcList failed");
        return false;
    }
    jcList = (jclass) env->NewGlobalRef(localRefCls_List);
    env->DeleteLocalRef(localRefCls_List);

    jmInitList = env->GetMethodID(jcList, "<init>", "()V");
    if (jmInitList == NULL) {
        LOGE("Get jmInitList failed");
        return false;
    }

    jmAddList = env->GetMethodID(jcList, "add", "(Ljava/lang/Object;)Z");
    if (jmAddList == NULL) {
        LOGE("Get jmAddList failed");
        return false;
    }
    return true;
}

bool isGMSSupport()
{
    jboolean ret = JNI_FALSE;
    JNIEnv* env = cocos2d::JniHelper::getEnv();
    ret = env->CallStaticBooleanMethod(jcStoreKit,jmIsGMSSupport);
    return ret;
}

void getGMSSupport()
{
    JNIEnv* env = cocos2d::JniHelper::getEnv();
    env->CallStaticVoidMethod(jcStoreKit,jmGetGMSSupport);
}

void buy(const char * sku)
{
    JNIEnv* env = cocos2d::JniHelper::getEnv();
    jstring jtext = env->NewStringUTF(sku);
    env->CallStaticVoidMethod(jcStoreKit,jmBuy,jtext);
    env->DeleteLocalRef(jtext);
}

void consumePurchase(const char * sku)
{
	JNIEnv* env = cocos2d::JniHelper::getEnv();
    jstring jtext = env->NewStringUTF(sku);
    env->CallStaticVoidMethod(jcStoreKit,jmConsumePurchase,jtext);
    env->DeleteLocalRef(jtext);
}

void loadProductsLua(lua_State *L, cocos2d::LUA_FUNCTION callback)
{
    if(m_isLoadProductsLuaNotCompleted)return;
    m_loadProductsCallback = callback;
    JNIEnv* env = cocos2d::JniHelper::getEnv();
    jobject joItemIdSet = env->NewObject(jcHashSet, jmInitHashSet);
    lua_pushnil(L);
    while (lua_next(L, -3) != 0) {
        const char* itemId = lua_tostring(L, -1);
        LOGI("itemId: %s", itemId);
        jstring jItemId = env->NewStringUTF(itemId);
        env->CallVoidMethod(joItemIdSet, jmAddHashSet, jItemId);
        env->DeleteLocalRef(jItemId);
        lua_pop(L, 1);
    }
    env->CallStaticVoidMethod(jcStoreKit, jmRequestProductData, joItemIdSet);
    env->DeleteLocalRef(joItemIdSet);
    m_isLoadProductsLuaNotCompleted = true;
}

void postInitWithTransactionListenerLua(cocos2d::LUA_FUNCTION listener,cocos2d::LUA_FUNCTION listener_failed)
{
    m_listener = listener;
    m_listener_failed = listener_failed;
}

void updateTransactionStates(lua_State *L)
{
    JNIEnv* env = cocos2d::JniHelper::getEnv();
    jobject joItemIdList = env->NewObject(jcList, jmInitList);
    lua_pushnil(L);
    while (lua_next(L, -2) != 0) {
        const char* itemId = lua_tostring(L, -1);
        LOGI("itemId: %s", itemId);
        jstring jItemId = env->NewStringUTF(itemId);
        env->CallBooleanMethod(joItemIdList, jmAddList, jItemId);
        env->DeleteLocalRef(jItemId);
        lua_pop(L, 1);
    }
    env->CallStaticVoidMethod(jcStoreKit, jmUpdateTransactionStates, joItemIdList);
    env->DeleteLocalRef(joItemIdList);
}

static int tolua_ext_store_postInitWithTransactionListenerLua(lua_State *tolua_S)
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
        postInitWithTransactionListenerLua(callback,callback_failed);
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_ext_store_postInitWithTransactionListenerLua'.",&tolua_err);
    return 0;
#endif
}

static int tolua_ext_store_loadProductsLua(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!toluafix_istable(tolua_S,1,"LUA_TABLE",0,&tolua_err)
        ||!toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        cocos2d::LUA_TABLE __LUA_TABLE__ = (  toluafix_totable(tolua_S,1,0));
        cocos2d::LUA_FUNCTION callback = (  toluafix_ref_function(tolua_S,2,0));
        loadProductsLua(tolua_S,callback);
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_ext_store_loadProductsLua'.",&tolua_err);
    return 0;
#endif
}

static int tolua_ext_store_updateTransactionStatesLua(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!toluafix_istable(tolua_S,1,"LUA_TABLE",0,&tolua_err))
        goto tolua_lerror;
    else
#endif
    {
        updateTransactionStates(tolua_S);
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_ext_store_updateTransactionStatesLua'.",&tolua_err);
    return 0;
#endif
}


static int tolua_ext_store_buy(lua_State *tolua_S)
{
	#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S, 1, 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
    	const char* str = ((const char*)  tolua_tostring(tolua_S,1,0));
    	buy(str);
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_ext_store_buy'.",&tolua_err);
    return 0;
#endif
}


static int tolua_ext_store_consumePurchase(lua_State *tolua_S)
{
	#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S, 1, 0, &tolua_err))
        goto tolua_lerror;
    else
#endif
    {
    	const char* str = ((const char*)  tolua_tostring(tolua_S,1,0));
    	consumePurchase(str);
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_ext_store_consumePurchase'.",&tolua_err);
    return 0;
#endif
}

static int tolua_ext_store_canMakePurchases(lua_State *tolua_S)
{
    bool ret = isGMSSupport();
    tolua_pushboolean(tolua_S,ret);
    return 1;
}

static int tolua_ext_store_getStoreSupport(lua_State *tolua_S)
{
    getGMSSupport();
    return 0;
}

void tolua_ext_module_store(lua_State* tolua_S)
{
    tolua_module(tolua_S,EXT_MODULE_NAME_STORE_KIT,0);
    tolua_beginmodule(tolua_S, EXT_MODULE_NAME_STORE_KIT);
    tolua_function(tolua_S,"buy",tolua_ext_store_buy);
    tolua_function(tolua_S,"consumePurchase",tolua_ext_store_consumePurchase);
    tolua_function(tolua_S,"loadProducts",tolua_ext_store_loadProductsLua);
    tolua_function(tolua_S,"init",tolua_ext_store_postInitWithTransactionListenerLua);
    tolua_function(tolua_S,"updateTransactionStates",tolua_ext_store_updateTransactionStatesLua);
    tolua_function(tolua_S,"canMakePurchases",tolua_ext_store_canMakePurchases);
    tolua_function(tolua_S,"getStoreSupport",tolua_ext_store_getStoreSupport);
    tolua_endmodule(tolua_S);
}

extern "C" {

    JNIEXPORT void JNICALL STORE_NATIVE_FUNCTION(StoreKit_initJNI)(JNIEnv*  env, jclass cls) 
    {
        if (!initJNI(env, cls)) {
            LOGE("initJNI failed");
        }
    }
    JNIEXPORT void JNICALL STORE_NATIVE_FUNCTION(StoreKit_productDataReceived)(JNIEnv*  env, jclass cls, jobjectArray jItemIds, jobjectArray jItemPrices)
    {
        if(m_loadProductsCallback)
        {
            cocos2d::LuaValueArray itemIds;
            cocos2d::LuaValueArray itemPrices;
            int arrayLength = env->GetArrayLength(jItemIds);
            for (int i = 0; i < arrayLength; i++) {
                jstring jItemId = (jstring) env->GetObjectArrayElement(jItemIds, i);
                jstring jItemPrice = (jstring) env->GetObjectArrayElement(jItemPrices, i);
                const char* itemId = env->GetStringUTFChars(jItemId, NULL);
                const char* itemPrice = env->GetStringUTFChars(jItemPrice, NULL);
                itemIds.push_back(cocos2d::LuaValue::stringValue(itemId));
                itemPrices.push_back(cocos2d::LuaValue::stringValue(itemPrice));
            }
            auto stack = cocos2d::LuaEngine::getInstance()->getLuaStack();
            stack->pushLuaValueArray(itemIds);
            stack->pushLuaValueArray(itemPrices);
            stack->executeFunctionByHandler(m_loadProductsCallback, 2);
            m_loadProductsCallback = 0;
            m_isLoadProductsLuaNotCompleted = false;
        }
    }

    JNIEXPORT void JNICALL STORE_NATIVE_FUNCTION(StoreKit_verifyGPV3Purchase)(JNIEnv*  env, jclass cls, jstring jOrderId, jstring jPurchaseData,
        jstring jSignature)
    {
        if(m_listener)
        {
            auto stack = cocos2d::LuaEngine::getInstance()->getLuaStack();
            stack->pushString(cocos2d::JniHelper::jstring2string(jOrderId).c_str());
            stack->pushString(cocos2d::JniHelper::jstring2string(jPurchaseData).c_str());
            stack->pushString(cocos2d::JniHelper::jstring2string(jSignature).c_str());
            stack->executeFunctionByHandler(m_listener, 3);
        }
    }

    JNIEXPORT void JNICALL STORE_NATIVE_FUNCTION(StoreKit_onPurchaseFailed)(JNIEnv*  env, jclass cls) 
    {
        if(m_listener_failed)
        {
            auto stack = cocos2d::LuaEngine::getInstance()->getLuaStack();
            stack->executeFunctionByHandler(m_listener_failed, 0);
        }
    }
}
