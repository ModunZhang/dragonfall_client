#include "ext_local_push.h"
#include "LocalNotification.h"

static int tolua_localpush_cancelAll(lua_State* tolua_S)
{
    cancelAll();
    return 0;
}

static int tolua_localpush_addNotification(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if ((lua_gettop(tolua_S)< 4) ||
        !tolua_isstring(tolua_S, 1, 0, &tolua_err) ||
        !tolua_isnumber(tolua_S, 2, 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 3, 0, &tolua_err) ||
        !tolua_isstring(tolua_S, 4, 0, &tolua_err)
        )
        goto tolua_lerror;
    else
#endif
    {
        const char* type = tolua_tostring(tolua_S, 1, 0);
        long finishTime  = tolua_tonumber(tolua_S, 2,0);
        const char* body = tolua_tostring(tolua_S, 3, 0);
        const char* identity = "";
        if (lua_gettop(tolua_S) > 3)
        {
            identity = tolua_tostring(tolua_S, 4, 0);
        }
        bool r = addNotification(type, finishTime, body,identity);
        tolua_pushboolean(tolua_S,r);
        return 1;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_localpush_addNotification'.",&tolua_err);
#endif
    return 0;
}

static int tolua_localpush_switchNotification(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (lua_gettop(tolua_S)!= 2)
        goto tolua_lerror;
    else
#endif
    {
        const char* type = tolua_tostring(tolua_S, 1, 0);
        bool  enable  = tolua_toboolean(tolua_S, 2, 0);
        switchNotification(type,enable);
        return 0;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_localpush_switchNotification'.",&tolua_err);
#endif
    return 0;
}


static int tolua_localpush_cancelNotificationWithIdentity(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
    tolua_Error tolua_err;
    if (lua_gettop(tolua_S)!= 1)
        goto tolua_lerror;
    else
#endif
    {
        const char* identity = tolua_tostring(tolua_S, 1, 0);
        bool r = cancelNotificationWithIdentity(identity);
        tolua_pushboolean(tolua_S, r);
        return 1;
    }
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'tolua_localpush_cancelNotificationWithIdentity'.",&tolua_err);
#endif
    return 0;
}

void tolua_ext_module_localpush(lua_State* tolua_S)
{
    tolua_module(tolua_S,EXT_MODULE_NAME,0);
    tolua_beginmodule(tolua_S, EXT_MODULE_NAME);
    tolua_function(tolua_S,"cancelAll",tolua_localpush_cancelAll);
    tolua_function(tolua_S,"addNotification",tolua_localpush_addNotification);
    tolua_function(tolua_S,"switchNotification",tolua_localpush_switchNotification);
    tolua_function(tolua_S,"cancelNotification",tolua_localpush_cancelNotificationWithIdentity);
    tolua_endmodule(tolua_S);
}