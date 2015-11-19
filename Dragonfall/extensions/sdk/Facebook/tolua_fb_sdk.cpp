//
//  tolua_fb_sdk.cpp
//  
//
//  Created by dannyhe on 2015/11/12.
//

#include "tolua_fb_sdk.h"
#include "cocos2d.h"
#include "Sysmail.h"
#include "CCLuaValue.h"
#include "CCLuaStack.h"
#include "CCLuaEngine.h"
#include "tolua_fix.h"
#include "FacebookSDK.h"
#include "LuaBasicConversions.h"

void FacebookCallback(int handleId, cocos2d::ValueMap valMap)
{
	auto stack = cocos2d::LuaEngine::getInstance()->getLuaStack();
	ccvaluemap_to_luaval(stack->getLuaState(),valMap);
	stack->executeFunctionByHandler(handleId, 1);
}

static int tolua_fb_initialize(lua_State *tolua_S)
{

	std::string appId = tolua_tocppstring(tolua_S, 1, "");
	FacebookSDK::GetInstance()->Initialize(appId);
	return 0;
}

static int tolua_fb_isAuthenticated(lua_State *tolua_S)
{
	tolua_pushboolean(tolua_S, FacebookSDK::GetInstance()->IsAuthenticated());
	return 1;
}

static int tolua_fb_login(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!toluafix_isfunction(tolua_S, 1, "LUA_FUNCTION", 0, &tolua_err))
		goto tolua_lerror;
	else
#endif
	{
		cocos2d::LUA_FUNCTION func = toluafix_ref_function(tolua_S, 1, 0);
		FacebookSDK::GetInstance()->RegisterLuaCllback(func);
		FacebookSDK::GetInstance()->Login();
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(tolua_S, "#ferror in function 'tolua_fb_login'.", &tolua_err);
	return 0;
#endif
}

static int tolua_fb_getUserNameAndId(lua_State *tolua_S)
{
    std::string name = FacebookSDK::GetInstance()->GetFBUserName();
    std::string id = FacebookSDK::GetInstance()->GetFBUserId();
    tolua_pushcppstring(tolua_S,name);
    tolua_pushcppstring(tolua_S,id);
    return 2;
}

void tolua_ext_module_facebook(lua_State* tolua_S)
{
	tolua_module(tolua_S, EXT_MODULE_NAME_FACEBOOK, 0);
	tolua_beginmodule(tolua_S, EXT_MODULE_NAME_FACEBOOK);
	tolua_function(tolua_S, "initialize", tolua_fb_initialize);
	tolua_function(tolua_S, "login", tolua_fb_login);
	tolua_function(tolua_S, "isAuthenticated", tolua_fb_isAuthenticated);
    tolua_function(tolua_S, "getPlayerNameAndId", tolua_fb_getUserNameAndId);
	tolua_endmodule(tolua_S);
}