//
//  tolua_fb_sdk.h
//  
//
//  Created by dannyhe on 2015/11/12.
//

#ifndef DRAGONFALL_SDK_FACEBOOK_TOLUA_FB_SDK_H_
#define DRAGONFALL_SDK_FACEBOOK_TOLUA_FB_SDK_H_

#include "tolua++.h"
#include "cocos2d.h"
#define EXT_MODULE_NAME_FACEBOOK "facebook"

void tolua_ext_module_facebook(lua_State* tolua_S);

void FacebookCallback(int handleId, cocos2d::ValueMap valMap);
#endif