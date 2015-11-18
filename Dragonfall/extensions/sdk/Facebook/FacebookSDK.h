//
//  FacebookSDK.h
//  
//
//  Created by dannyhe on 2015/11/12.
//

#ifndef DRAGONFALL_SDK_FACEBOOK_H_
#define DRAGONFALL_SDK_FACEBOOK_H_
#include "cocos2d.h"
extern void FacebookCallback(int handleId, cocos2d::ValueMap valMap);

class FacebookSDK
{
public:

	static FacebookSDK* GetInstance();

	void Initialize(std::string appId = "");

	void Login();
    
	void RegisterLuaCllback(int luaHandId){ if (luaHandId > 0)m_handId = luaHandId; };

	void UnRegisterLuaCallback(){ m_handId = -1; };

	~FacebookSDK();
    
    void CallLuaCallback(cocos2d::ValueMap valMap)
    {
        if (m_handId > 0)
        {
            FacebookCallback(m_handId, valMap);
        }
    };

    bool IsAuthenticated();
private:

	int m_handId;

	bool m_isLogining;

	FacebookSDK(){ m_handId = -1; m_isLogining = false; };

#if CC_TARGET_PLATFORM == CC_PLATFORM_WINRT 
	void saveUserProfile(Facebook::Graph::FBUser^ user);
	void clearFacebookCookies();
#endif
};
#endif //DRAGONFALL_SDK_FACEBOOK_H_