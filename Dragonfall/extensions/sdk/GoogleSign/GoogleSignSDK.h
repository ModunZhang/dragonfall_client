
#ifndef GoogleSignSDK_hpp
#define GoogleSignSDK_hpp
#define EXT_MODULE_NAME_GOOGLE "google"
#include "CCLuaValue.h"
#include "CCLuaStack.h"
#include "CCLuaEngine.h"
#include "tolua_fix.h"
#include "cocos2d.h"

class GoogleSignSDK
{
public:
	static GoogleSignSDK* GetInstance();

	~GoogleSignSDK();

	void Initialize(){/*unused*/};

	void CallLuaFunction(std::string event,std::string userName,std::string id);

	void Login(cocos2d::LUA_FUNCTION callback);

	std::string GetGoogleName();

	std::string GetGoogleId();

	bool IsAuthenticated();
private:
	GoogleSignSDK(){m_listener = 0;};
	
	cocos2d::LUA_FUNCTION m_listener;
};

void tolua_ext_module_google(lua_State* tolua_S);
#endif /* GoogleSignSDK_hpp */