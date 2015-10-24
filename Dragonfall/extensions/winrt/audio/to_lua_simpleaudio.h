#ifndef __tolua_ext_module_audio__
#define __tolua_ext_module_audio__
#include "tolua++.h"
#include "cocos2d.h"

#define EXT_MODULE_NAME "audio"

void tolua_ext_module_audio(lua_State* tolua_S);

void OnExtAudioPlayDone();

#endif /* defined(__tolua_ext_module_audio__) */