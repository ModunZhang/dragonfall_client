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
static int tolua_fb_initialize(lua_State *tolua_S)
{

	std::string appId = tolua_tocppstring(tolua_S, 1, "");
	FacebookSDK::GetInstance()->Initialize(appId);
	return 0;
}

static int tolua_fb_login(lua_State *tolua_S)
{
	FacebookSDK::GetInstance()->Login();
	return 0;
}

void tolua_ext_module_facebook(lua_State* tolua_S)
{
	tolua_module(tolua_S, EXT_MODULE_NAME_FACEBOOK, 0);
	tolua_beginmodule(tolua_S, EXT_MODULE_NAME_FACEBOOK);
	tolua_function(tolua_S, "initialize", tolua_fb_initialize);
	tolua_function(tolua_S, "login", tolua_fb_login);
	tolua_endmodule(tolua_S);
}