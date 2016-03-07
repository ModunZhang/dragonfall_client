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
using namespace cocos2d::WinRTHelper;

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

bool FacebookSDK::IsAuthenticated()
{
	return Windows::Storage::ApplicationData::Current->LocalSettings->Values->HasKey("FBUser_Id");
}

std::string FacebookSDK::GetFBUserName()
{
	if (IsAuthenticated())
	{
		Platform::String^ userName = static_cast<Platform::String^>(Windows::Storage::ApplicationData::Current->LocalSettings->Values->Lookup("FBUser_Name"));
		return PlatformStringToString(userName);
	}
	return "";
}

std::string FacebookSDK::GetFBUserId()
{
	if (IsAuthenticated())
	{
		Platform::String^ userId = static_cast<Platform::String^>(Windows::Storage::ApplicationData::Current->LocalSettings->Values->Lookup("FBUser_Id"));
		return PlatformStringToString(userId);
	}
	return "";
}

void FacebookSDK::Login()
{
	clearFacebookCookies();//clear cookies!
	WinRTHelper::RunOnUIThread([=](){
		FBSession^ sess = FBSession::ActiveSession;
		if (m_isLogining || sess->LoggedIn)
		{
			return;
		}
		m_isLogining = true;
		Platform::Collections::Vector<Platform::String^>^ permissionList = ref new Platform::Collections::Vector<Platform::String^>();
		permissionList->Append(L"public_profile");
		FBPermissions^ permissions = ref new FBPermissions(permissionList->GetView());

		// Login to Facebook
		create_task(sess->LoginAsync(permissions, SessionLoginBehavior::ForcingWebView)).then([=](task<FBResult^> task)
		{
			try
			{
				FBResult^ result = task.get();
				if (result->Succeeded)
				{
					FBSession^ sess_ = FBSession::ActiveSession;
					if (sess_->LoggedIn)
					{
						auto user = sess_->User;
						if (user)
						{
							CCLOG("Login succeeded");
							cocos2d::ValueMap tempMap;
							tempMap["userid"] = PlatformStringToString(user->Id);
							tempMap["username"] = PlatformStringToString(user->Name);
							tempMap["event"] = "login_success";
							CallLuaCallback(tempMap);
							saveUserProfile(user);
							sess_->LogoutAsync();
						}
					}
				}
				else
				{
					// Login failed
					CCLOG("Login failed");
					cocos2d::ValueMap tempMap;
					tempMap["event"] = "login_failed";
					CallLuaCallback(tempMap);
				}
				m_isLogining = false;
			}
			catch (Platform::COMException^ e)
			{
				//Login Exception
				CCLOG("Login Exception");
				cocos2d::ValueMap tempMap;
				tempMap["event"] = "login_exception";
				CallLuaCallback(tempMap);
				m_isLogining = false;
			}
		});
	});
}
void FacebookSDK::saveUserProfile(Facebook::Graph::FBUser^ user)
{
	if (nullptr == user)return;
	Windows::Storage::ApplicationData::Current->LocalSettings->Values->Insert("FBUser_Id", user->Id);
	Windows::Storage::ApplicationData::Current->LocalSettings->Values->Insert("FBUser_Name", user->Name);
}

void FacebookSDK::clearFacebookCookies()
{
	//just for SessionLoginBehavior::ForcingWebView
	Windows::Web::Http::Filters::HttpBaseProtocolFilter^ fileter = ref new Windows::Web::Http::Filters::HttpBaseProtocolFilter();
	auto cookieManager = fileter->CookieManager;
	auto myCookieJar = cookieManager->GetCookies(ref new Uri("https://facebook.com"));
	for (auto iter : myCookieJar)
	{
		cookieManager->DeleteCookie(iter);
	}
}

void FacebookSDK::CallLuaCallback(cocos2d::ValueMap valMap)
{
	if (m_handId > 0)
	{
		WinRTHelper::QueueEvent([=]()
		{
			FacebookCallback(m_handId, valMap);
		});
	}
}

void FacebookSDK::AppInvite(std::string title,std::string message)
{
    //TODO:windows phone
}

#endif // CC_TARGET_PLATFORM == CC_PLATFORM_WINRT