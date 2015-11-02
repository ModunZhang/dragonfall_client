#include "to_lua_adeasygo_helper.h"
#include "CCLuaValue.h"
#include "CCLuaStack.h"
#include "CCLuaEngine.h"
#include "tolua_fix.h"
#include "AdeasygoHelper.h"
#include "WinRTHelper.h"
#include "cocos2d.h"
#include "LuaBasicConversions.h"

// extern method
void OnPayDone(int handleId, cocos2d::ValueVector valVector)
{
#if defined(__AdeasygoSDK__)
	auto stack = cocos2d::LuaEngine::getInstance()->getLuaStack();
	ccvaluevector_to_luaval(stack->getLuaState(), valVector);
	stack->executeFunctionByHandler(handleId, 1);
#endif
}

//lua part
static int tolua_adeasygo_pay(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isstring(tolua_S, 1, 0, &tolua_err))
		goto tolua_lerror;
	else
#endif
	{
#if defined(__AdeasygoSDK__)
		std::string product_id = tolua_tocppstring(tolua_S, 1, 0);
		cocos2d::LUA_FUNCTION func = toluafix_ref_function(tolua_S, 2, 0);
		cocos2d::AdeasygoHelper::Instance->handleId = func;
		cocos2d::AdeasygoHelper::Instance->Pay(cocos2d::WinRTHelper::PlatformStringFromString(product_id));
#endif
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(tolua_S, "#ferror in function 'tolua_adeasygo_pay'.", &tolua_err);
	return 0;
#endif
}


static int tolua_adeasygo_register_global_paydone_func(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!toluafix_isfunction(tolua_S, 1, "LUA_FUNCTION", 0, &tolua_err))
		goto tolua_lerror;
	else
#endif
	{
#if defined(__AdeasygoSDK__)
		cocos2d::LUA_FUNCTION func = toluafix_ref_function(tolua_S, 1, 0);
		cocos2d::AdeasygoHelper::Instance->handleId = func;
#endif
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(tolua_S, "#ferror in function 'tolua_adeasygo_register_global_paydone_func'.", &tolua_err);
	return 0;
#endif
	return 0;
}

static int tolua_adeasygo_unregister_global_paydone_func(lua_State *tolua_S)
{
#if defined(__AdeasygoSDK__)
	cocos2d::AdeasygoHelper::Instance->handleId = 0;
#endif
	return 0;
}

static int tolua_adeasygo_device_unique_id(lua_State *tolua_S)
{
#if defined(__AdeasygoSDK__)
	lua_pushstring(tolua_S,WinRTHelper::PlatformStringToString(cocos2d::AdeasygoHelper::DeviceUniqueId).c_str());
#else
	lua_pushnil(tolua_S);
#endif
	return 1;
}


static int tolua_adeasygo_updatetransactionstates(lua_State *tolua_S)
{
#if defined(__AdeasygoSDK__)
	cocos2d::AdeasygoHelper::Instance->updateTransactionStates();
#endif
	return 0;
}

static int tolua_adeasygo_init(lua_State *tolua_S)
{
#if defined(__AdeasygoSDK__)
	//init sdk asysc
	cocos2d::AdeasygoHelper::Instance->Init();
#endif
	return 0;
}

void tolua_ext_module_adeasygo(lua_State* tolua_S)
{
	tolua_module(tolua_S, EXT_MODULE_NAME, 0);
	tolua_beginmodule(tolua_S, EXT_MODULE_NAME);
	tolua_function(tolua_S, "registerPayDoneEvent", tolua_adeasygo_register_global_paydone_func);
	tolua_function(tolua_S, "unregisterPayDoneEvent", tolua_adeasygo_register_global_paydone_func);
	tolua_function(tolua_S, "getUid", tolua_adeasygo_device_unique_id);
	tolua_function(tolua_S, "buy", tolua_adeasygo_pay);
	tolua_function(tolua_S, "updateTransactionStates", tolua_adeasygo_updatetransactionstates);
	tolua_function(tolua_S, "init", tolua_adeasygo_init);
	tolua_endmodule(tolua_S);
}