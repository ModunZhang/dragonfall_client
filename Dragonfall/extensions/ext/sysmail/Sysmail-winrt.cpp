#include "Sysmail.h"
#include "cocos2d.h"
#include "WinRTHelper.h"

using namespace Platform;
using namespace Windows::Foundation;
using namespace Windows::ApplicationModel;
using namespace cocos2d;
extern void OnSendMailEnd(int function_id, std::string event);

bool CanSenMail()
{
	return true;
}
//WINRT上暂时不提供发送是否成功的回调
bool SendMail(std::vector<std::string> to, std::string subject, std::string body, int lua_function_ref)
{
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)
	WinRTHelper::RunOnUIThread([=]()
	{
		Windows::ApplicationModel::Email::EmailMessage^ message = ref new Windows::ApplicationModel::Email::EmailMessage();
		message->Subject = WinRTHelper::PlatformStringFromString(subject);
		message->Body = WinRTHelper::PlatformStringFromString(body);
		for (std::string address:to)
		{
			Windows::ApplicationModel::Email::EmailRecipient^ recipient = ref new Windows::ApplicationModel::Email::EmailRecipient(WinRTHelper::PlatformStringFromString(address));
			message->To->Append(recipient);
		}
		Windows::ApplicationModel::Email::EmailManager::ShowComposeNewEmailAsync(message);
	});
#endif
	return true;
}