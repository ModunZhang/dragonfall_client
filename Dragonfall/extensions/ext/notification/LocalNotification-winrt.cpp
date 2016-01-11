#include "LocalNotification.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_WINRT
#include <string>
#include "collection.h"
#include "WinRTHelper.h"

using namespace Windows::UI::Notifications;
using namespace Windows::Data::Xml::Dom;
using namespace Windows::Foundation::Collections;
using namespace cocos2d;
static Windows::UI::Notifications::ToastNotifier ^getNotifier()
{
	static Windows::UI::Notifications::ToastNotifier ^notifier = ToastNotificationManager::CreateToastNotifier();
	return notifier;
}

void cancelAll()
{
	auto notifier = getNotifier();
	auto scheduled = notifier->GetScheduledToastNotifications();
	for (int i = 0; i < scheduled->Size; i++)
	{
		notifier->RemoveFromSchedule(scheduled->GetAt(i));
	}
}
void switchNotification(std::string type, bool enable)
{
	//Not Support!
}
bool addNotification(std::string type, long finishTime, std::string body, std::string identity)
{
	ToastTemplateType toastTemplate = ToastTemplateType::ToastText01;
	XmlDocument^ toastXml = ToastNotificationManager::GetTemplateContent(toastTemplate);
	XmlNodeList^ toastTextElements = toastXml->GetElementsByTagName("text");
	toastTextElements->Item(0)->InnerText = WinRTHelper::PlatformStringFromString(body);
	Windows::Globalization::Calendar^ c = ref new Windows::Globalization::Calendar;
	Windows::Foundation::DateTime dt = c->GetDateTime();
	int diff = (finishTime + 11644473600) - dt.UniversalTime / 10000000;
	if (diff <= 0)
	{
		return false; //如果推送时间已经小于当前时间 忽略
	}
	c->AddSeconds(diff);
	Windows::Foundation::DateTime dueTime = c->GetDateTime();
	ScheduledToastNotification^ scheduledToast = ref new ScheduledToastNotification(toastXml, dueTime);
	scheduledToast->Id = WinRTHelper::PlatformStringFromString(identity);
	getNotifier()->AddToSchedule(scheduledToast);
	return true;
}
bool cancelNotificationWithIdentity(std::string identity)
{
	auto notifier = getNotifier();
	auto scheduled = notifier->GetScheduledToastNotifications();
	Platform::String^ psId = WinRTHelper::PlatformStringFromString(identity);

	for (int i = 0; i < scheduled->Size; i++)
	{
		if (scheduled->GetAt(i)->Id == psId)
		{
			notifier->RemoveFromSchedule(scheduled->GetAt(i));
			return true;
		}
	}
	return false;
}
#endif // CC_TARGET_PLATFORM == CC_PLATFORM_WINRT

