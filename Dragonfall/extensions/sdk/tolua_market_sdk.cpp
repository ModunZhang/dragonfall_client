//
//  tolua_market_sdk.cpp
//  Dragonfall
//
//  Created by DannyHe on 6/1/16.
//
//

#include "tolua_market_sdk.h"
#include "CCLuaValue.h"
#include "CCLuaStack.h"
#include "CCLuaEngine.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"
#include "MarketSDKTool.h"

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
        !tolua_isnumber(tolua_S, 3, 0, &tolua_err)||
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

static int tolua_market_onPlayerEventAF(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (!tolua_isstring(tolua_S, 1, 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 2, 0, &tolua_err)        )
        goto tolua_lerror;
    else
#endif
    {
        MarketSDKTool::getInstance()->onPlayerEventAF(tolua_tostring(tolua_S, 1, 0),tolua_tostring(tolua_S, 2, 0));
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
    tolua_function(tolua_S,"onPlayerEventAF",tolua_market_onPlayerEventAF);
    tolua_function(tolua_S,"onPlayerLevelUp",tolua_market_onPlayerLevelUp);
    tolua_endmodule(tolua_S);
}