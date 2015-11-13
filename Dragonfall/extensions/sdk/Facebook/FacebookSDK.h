//
//  FacebookSDK.h
//  
//
//  Created by dannyhe on 2015/11/12.
//

#ifndef DRAGONFALL_SDK_FACEBOOK_H_
#define DRAGONFALL_SDK_FACEBOOK_H_
#include "cocos2d.h"
#include "FacebookSimple.h"
class FacebookSDK
{
public:

	static FacebookSDK* GetInstance();

	void Initialize(std::string appId = "");

	void Login();
	~FacebookSDK();
private:
	FacebookSDK(){};
};

#endif //DRAGONFALL_SDK_FACEBOOK_H_