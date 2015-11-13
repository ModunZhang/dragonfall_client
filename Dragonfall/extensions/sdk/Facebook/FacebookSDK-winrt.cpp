#include "FacebookSDK.h"
#if CC_TARGET_PLATFORM == CC_PLATFORM_WINRT

#include <ppltasks.h>
#include <collection.h>
#include "WinRTHelper.h"
using namespace Platform;
using namespace Windows::Foundation;
using namespace Windows::ApplicationModel;
using namespace concurrency;
using namespace Windows::Security::Authentication::Web;
using namespace Facebook;
using namespace cocos2d;

static FacebookSDK *s_FacebookSDK = NULL; // pointer to singleton


void FacebookSDK::Initialize(std::string appId /* = "" */)
{
	FBSession^ sess = FBSession::ActiveSession;
	sess->FBAppId = "1700922490127767";
	sess->WinAppId = WebAuthenticationBroker::GetCurrentApplicationCallbackUri()->DisplayUri;
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
	WinRTHelper::RunOnUIThread([=](){
		FBSession^ sess = FBSession::ActiveSession;
		Platform::Collections::Vector<Platform::String^>^ permissionList = ref new Platform::Collections::Vector<Platform::String^>();
		permissionList->Append(L"public_profile");
		permissionList->Append(L"email");
		permissionList->Append(L"user_likes");
		FBPermissions^ permissions = ref new FBPermissions(permissionList->GetView());

		// Login to Facebook
		create_task(sess->LoginAsync(permissions, SessionLoginBehavior::ForcingWebView)).then([=](FBResult^ result)
		{
			if (result->Succeeded)
			{
				FBSession^ sess_ = FBSession::ActiveSession;
				if (sess_->LoggedIn)
				{
					auto user = sess_ ->User;
					if (user)
					{
						Platform::String^ userId = L"Id : " + user->Id;
						Platform::String^ username = L"Name : " + user->Name;
						Platform::String^ locale = L"Locale : " + user->Locale;
						OutputDebugString(username->Data());
						OutputDebugString(L"\n");
					}
				}
				// Login succeeded
				OutputDebugString(L"Login succeeded");
			}
			else
			{
				// Login failed
				OutputDebugString(L"Login failed");
			}
		});
	});
}
#endif // CC_TARGET_PLATFORM == CC_PLATFORM_WINRT