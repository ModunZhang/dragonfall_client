#ifndef __tolua_ext_module_adeasygo__
#define __tolua_ext_module_adeasygo__
#include "tolua++.h"
#include "cocos2d.h"

#define EXT_MODULE_NAME "adeasygo"

void tolua_ext_module_adeasygo(lua_State* tolua_S);

void OnPayDone(int handleId,cocos2d::ValueVector valVector);

#endif /* defined(__tolua_ext_module_adeasygo__) */