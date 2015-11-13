#include "FacebookSimple.h"
using namespace cocos2d::FacebookSimple;
using namespace Windows::Security::Authentication::Web;
using namespace Windows::ApplicationModel::Activation;
#include "WinRTHelper.h"
Uri^ FacebookSimple::BuildLoginUri(Platform::String^ clientID)
{
	Platform::String^ facebookURL = "https://www.facebook.com/dialog/oauth?client_id=";

	if (clientID == nullptr || clientID->IsEmpty())
	{
		return nullptr;
	}

	facebookURL += clientID + "&redirect_uri=" + GetRedirectUriString();
	facebookURL += "&scope=public_profile&display=popup&response_type=token";
	return ref new Uri(facebookURL);
}

Platform::String^ FacebookSimple::GetRedirectUriString()
{
	return WebAuthenticationBroker::GetCurrentApplicationCallbackUri()->DisplayUri;
}

void FacebookSimple::Initialize(Platform::String^ clientID)
{
	m_clientID = clientID;
}

void FacebookSimple::SetAccessToken(Platform::String^ token)
{
	if (nullptr != m_clientID)
	{
		Windows::Storage::ApplicationData::Current->LocalSettings->Values->Insert(m_clientID, token);
	}
}

Platform::String^ FacebookSimple::GetAccessToken()
{
	if (nullptr != m_clientID)
	{
		if (Windows::Storage::ApplicationData::Current->LocalSettings->Values->HasKey(m_clientID))
		{
			Platform::String^ token = static_cast<Platform::String^>(Windows::Storage::ApplicationData::Current->LocalSettings->Values->Lookup(m_clientID));
			return token;
		}
	}
	return "";
}


void FacebookSimple::Login()
{
	if (nullptr == m_clientID)return;
	cocos2d::WinRTHelper::RunOnUIThread([=](){
		try
		{
			auto startURI = BuildLoginUri(m_clientID);
			auto endURI = ref new Uri(GetRedirectUriString());
			OutputDebugString(startURI->ToString()->Data());
			OutputDebugString(L"\n");
			OutputDebugString(endURI->ToString()->Data());
			OutputDebugString(L"\n");
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)
			WebAuthenticationBroker::AuthenticateAndContinue(startURI, endURI, nullptr, WebAuthenticationOptions::None);
#endif
		}
		catch (Platform::Exception^ e)
		{
			OutputDebugString(e->ToString()->Data());
		}
	});
	
	
}