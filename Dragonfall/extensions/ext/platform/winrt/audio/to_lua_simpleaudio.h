#ifndef __tolua_ext_module_audio__
#define __tolua_ext_module_audio__
#include "tolua++.h"
#include "cocos2d.h"

#define EXT_MODULE_NAME "audio"

#if CC_TARGET_PLATFORM == CC_PLATFORM_WINRT 

void tolua_ext_module_audio(lua_State* tolua_S);

void OnExtAudioPlayDone();

#endif // CC_TARGET_PLATFORM == CC_PLATFORM_WINRT


#endif /* defined(__tolua_ext_module_audio__) */