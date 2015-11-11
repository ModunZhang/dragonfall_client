#include "to_lua_adeasygo_helper.h"
#include "CCLuaValue.h"
#include "CCLuaStack.h"
#include "CCLuaEngine.h"
#include "tolua_fix.h"
#include "AdeasygoHelper.h"
#include "WinRTHelper.h"
#include "cocos2d.h"
#include "LuaBasicConversions.h"
#include <collection.h>
#include <windows.h>
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
	lua_pushstring(tolua_S,WinRTHelper::PlatformStringToString(cocos2d::AdeasygoHelper::Instance->DeviceUniqueId()).c_str());
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

static int tolua_adeasygo_consumePurchase(lua_State *tolua_S)
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
		cocos2d::AdeasygoHelper::Instance->MSReportProductFulfillment(cocos2d::WinRTHelper::PlatformStringFromString(product_id));
#endif
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(tolua_S, "#ferror in function 'tolua_adeasygo_consumePurchase'.", &tolua_err);
	return 0;
#endif
}

static int tolua_adeasygo_canMakePurchases(lua_State *tolua_S)
{
#if defined(__AdeasygoSDK__)
	tolua_pushboolean(tolua_S,true);
#else
	tolua_pushboolean(tolua_S,false);
#endif
	return 1;
}

static int tolua_adeasygo_validateMSReceipts(lua_State *tolua_S)
{
#if defined(__AdeasygoSDK__)
	cocos2d::AdeasygoHelper::Instance->MSValidateReceipts();
#endif
	return 0;
}

static void tolua_push_ListingInformation_to_lua(lua_State *tolua_S,
	Windows::Foundation::Collections::IMap<Platform::String^, Windows::Foundation::Collections::IVector<Platform::String^>^>^ cxMap)
{
	cocos2d::ValueVector cc_map_vec;

	for (auto itMap : cxMap)
	{
		auto cxVec = itMap->Value;
		cocos2d::ValueMap productMap;
		productMap["productId"] = WinRTHelper::PlatformStringToString(itMap->Key);
		productMap["name"] = WinRTHelper::PlatformStringToString(cxVec->GetAt(0));
		productMap["formattedPrice"] = WinRTHelper::PlatformStringToString(cxVec->GetAt(1));
		productMap["description"] = WinRTHelper::PlatformStringToString(cxVec->GetAt(2));
		cc_map_vec.push_back(cocos2d::Value(productMap));
	}
	ccvaluevector_to_luaval(tolua_S, cc_map_vec);
}

static int tolua_adeasygo_MSLoadListingInformationByProductIds(lua_State *tolua_S)
{
#if defined(__AdeasygoSDK__)
	cocos2d::ValueVector productIds;
	luaval_to_ccvaluevector(tolua_S, 1, &productIds, "tolua_adeasygo_MSLoadListingInformationByProductIds");
	if (productIds.size() > 0)
	{
		Platform::Collections::Vector<Platform::String^>^ cxproductIds = ref new Platform::Collections::Vector<Platform::String^>();
		for (auto it = productIds.begin(); it != productIds.end(); it++)
		{
			auto productId = (*it).asString();
			cxproductIds->Append(WinRTHelper::PlatformStringFromString(productId));
		}
		auto ret = cocos2d::AdeasygoHelper::Instance->MSLoadListingInformationByProductIds(cxproductIds);
		tolua_push_ListingInformation_to_lua(tolua_S, ret);
		return 1;
	}
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
	tolua_function(tolua_S, "consumePurchase", tolua_adeasygo_consumePurchase);
	tolua_function(tolua_S, "canMakePurchases", tolua_adeasygo_canMakePurchases);
	tolua_function(tolua_S, "validateMSReceipts", tolua_adeasygo_validateMSReceipts);
	tolua_function(tolua_S, "loadMicrosoftListingInformationByProductIds", tolua_adeasygo_MSLoadListingInformationByProductIds);
	
	tolua_endmodule(tolua_S);
}