//
//  PayPalSDK.hpp
//  Dragonfall
//
//  Created by DannyHe on 3/3/16.
//
//

#ifndef PayPalSDK_hpp
#define PayPalSDK_hpp
#define EXT_MODULE_NAME_PAYAPL "paypal"
#include "CCLuaValue.h"
#include "CCLuaStack.h"
#include "CCLuaEngine.h"
#include "tolua_fix.h"
#include "cocos2d.h"

class PayPalSDK
{
public:
	static PayPalSDK* GetInstance();
	~PayPalSDK();
	void buy(std::string itemName,std::string itemKey,double price);
	void postInitWithTransactionListenerLua(cocos2d::LUA_FUNCTION listener,cocos2d::LUA_FUNCTION listener_failed);
	bool isPayPalSupport();
	void onPayPalDone(std::string paymentId,std::string payment);
	void onPayPalFailed();
	void updatePaypalPayments();
	void consumePaypalPayment(std::string paymentId);
private:
	cocos2d::LUA_FUNCTION m_listener;
	cocos2d::LUA_FUNCTION m_listener_failed;
	PayPalSDK(){m_listener = 0;m_listener_failed = 0;};
};

void tolua_ext_module_paypal(lua_State* tolua_S);
#endif /* PayPalSDK_hpp */
