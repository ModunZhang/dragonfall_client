#include "FacebookSDK.h"
#if CC_TARGET_PLATFORM == CC_PLATFORM_WINRT

#include <ppltasks.h>
#include <collection.h>
#include "WinRTHelper.h"
#include "FacebookSimple.h"
using namespace Platform;
using namespace Windows::Foundation;
using namespace Windows::ApplicationModel;
using namespace concurrency;
using namespace cocos2d::FacebookSimple;
using namespace Windows::Security::Authentication::Web;

static FacebookSDK *s_FacebookSDK = NULL; // pointer to singleton

void FacebookSDK::Initialize(std::string appId /* = "" */)
{
	FacebookSimple::Instance->Initialize("1700922490127767");
}

FacebookSDK::~FacebookSDK()
{
	if (s_FacebookSDK != NULL)
	{
		delete s_FacebookSDK;
		s_FacebookSDK = NULL;
	}
}

FacebookSDK* FacebookSDK::GetInstance()
{
	if (s_FacebookSDK == NULL)
	{
		s_FacebookSDK = new FacebookSDK();
	}
	return s_FacebookSDK;
}

void FacebookSDK::Login()
{
	FacebookSimple::Instance->Login();
}
#endif // CC_TARGET_PLATFORM == CC_PLATFORM_WINRT