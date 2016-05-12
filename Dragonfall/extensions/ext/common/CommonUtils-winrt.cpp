#include "CommonUtils.h"
#if CC_TARGET_PLATFORM == CC_PLATFORM_WINRT
#include "WinRTHelper.h"
#include <ppltasks.h>

using namespace Platform;
using namespace Windows::Foundation;
using namespace Windows::ApplicationModel;
using namespace cocos2d;
using namespace concurrency;
using namespace Windows::UI::Popups;
static int isAppHoc = -1;
static int isLowMemoryDevice = -1;
void ShowAlert(std::string title, std::string content, std::string okString, std::function<void(void)> callbackFunc)
{
	auto pTitle = WinRTHelper::PlatformStringFromString(title);
	auto pContent = WinRTHelper::PlatformStringFromString(content);
	auto pOkString = WinRTHelper::PlatformStringFromString(okString);
	WinRTHelper::RunOnUIThread([=](){
		auto dialog = ref new MessageDialog(pContent, pTitle);
		dialog->CancelCommandIndex = 0;
		dialog->Commands->Append(ref new UICommand(pOkString, ref new UICommandInvokedHandler([=](IUICommand^ command)
		{
			if (callbackFunc)
			{
				WinRTHelper::QueueEvent(callbackFunc);
			}
		})));
		dialog->ShowAsync();
	});
}

void OpenUrl(std::string url)
{
	auto pURL = WinRTHelper::PlatformStringFromString(url);
	auto uri = ref new Uri(pURL);
	WinRTHelper::RunOnUIThread([uri](){
		Windows::System::Launcher::LaunchUriAsync(uri);
	});
}

//wp8.1 not support: https://social.msdn.microsoft.com/Forums/sqlserver/en-US/ac4f3329-d7ee-455f-80be-0e1685fea971/how-to-copy-text-to-the-clipboard-in-wp81-using-vs2013-can-not-refer-to-the-correct-namespace?forum=wpdevelop
void CopyText(std::string text)
{
	
}

void DisableIdleTimer(bool disable)
{
	WinRTHelper::RunOnUIThread([disable](){
		if (disable)
		{
			WinRTHelper::Device::Instance->DisplayRequestActive();
		}
		else
		{
			WinRTHelper::Device::Instance->DisplayRequestRelease();
		}
	});
}

void CloseKeyboard()
{
	//not support
}

std::string GetOSVersion()
{
	Windows::Security::ExchangeActiveSyncProvisioning::EasClientDeviceInformation^ info = ref new Windows::Security::ExchangeActiveSyncProvisioning::EasClientDeviceInformation();
	Platform::String^ output = info->FriendlyName;
	return cocos2d::WinRTHelper::PlatformStringToString(output);
}

std::string GetDeviceModel()
{
	Windows::Security::ExchangeActiveSyncProvisioning::EasClientDeviceInformation^ info = ref new Windows::Security::ExchangeActiveSyncProvisioning::EasClientDeviceInformation();
	Platform::String^ output = info->SystemProductName;
	return cocos2d::WinRTHelper::PlatformStringToString(output);
}
//log
void WriteLog_(std::string cppstr)
{
	OutputDebugString(cocos2d::WinRTHelper::PlatformStringFromString(cppstr)->Data());
}

std::string GetAppVersion()
{
	Windows::ApplicationModel::Package^ package = Windows::ApplicationModel::Package::Current;
	Windows::ApplicationModel::PackageId^ packageId = package->Id;
	Windows::ApplicationModel::PackageVersion version = packageId->Version;

	Platform::String^ output = version.Major.ToString() + "." + version.Minor.ToString() + "." +
		version.Build.ToString();
	return cocos2d::WinRTHelper::PlatformStringToString(output);
}

std::string GetAppBundleVersion()
{
	Windows::ApplicationModel::Package^ package = Windows::ApplicationModel::Package::Current;
	Windows::ApplicationModel::PackageId^ packageId = package->Id;
	Windows::ApplicationModel::PackageVersion version = packageId->Version;
	return cocos2d::WinRTHelper::PlatformStringToString(version.Revision.ToString());;
}
std::string GetDeviceToken()
{
	if (Windows::Storage::ApplicationData::Current->LocalSettings->Values->HasKey("push_url"))
	{
		Platform::String^ oldUrl = static_cast<Platform::String^>(Windows::Storage::ApplicationData::Current->LocalSettings->Values->Lookup("push_url"));
		return WinRTHelper::PlatformStringToString(oldUrl);
	}
	return "";
}

std::string GetDeviceLanguage()
{
	return "Not support in WinRT use device.language get value";
}

float GetBatteryLevel()
{
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)
	return Windows::Phone::Devices::Power::Battery::GetDefault()->RemainingChargePercent;
#else
	return 1;
#endif
}
/// <summary>
/// Property that returns the connection profile [ ie, availability of Internet ]
/// Interface type can be [ 1,6,9,23,24,37,71,131,144 ]
/// 1 - > Some other type of network interface.
/// 6 - > An Ethernet network interface.
/// 9 - > A token ring network interface.
/// 23 -> A PPP network interface.
/// 24 -> A software loopback network interface.
/// 37 -> An ATM network interface.
/// 71 -> An IEEE 802.11 wireless network interface.
/// 131 -> A tunnel type encapsulation network interface.
/// 144 -> An IEEE 1394 (Firewire) high performance serial bus network interface.
/// </summary>
std::string GetInternetConnectionStatus()
{
	auto profile = Windows::Networking::Connectivity::NetworkInformation::GetInternetConnectionProfile();
	switch (profile->NetworkAdapter->IanaInterfaceType)
	{
	case 1:
		return "unknow";
	default:
		return "unknow";
		break;
	}
}

std::string GetOpenUdid()
{
	Windows::System::Profile::HardwareToken^ token = Windows::System::Profile::HardwareIdentification::GetPackageSpecificToken(nullptr);
	auto  hardwareId = token->Id;
	Windows::Security::Cryptography::Core::HashAlgorithmProvider^ hasher = Windows::Security::Cryptography::Core::HashAlgorithmProvider::OpenAlgorithm("MD5");
	auto hashed = hasher->HashData(hardwareId);
	Platform::String^ hashedString = Windows::Security::Cryptography::CryptographicBuffer::EncodeToHexString(hashed);
	return cocos2d::WinRTHelper::PlatformStringToString(hashedString);
}

void RegistereForRemoteNotifications()
{
	create_task(Windows::Networking::PushNotifications::PushNotificationChannelManager::CreatePushNotificationChannelForApplicationAsync())
		.then([=](task<Windows::Networking::PushNotifications::PushNotificationChannel^> task)
	{
		try
		{
			auto channel = task.get();
			Platform::String^ url = channel->Uri;
			if (!Windows::Storage::ApplicationData::Current->LocalSettings->Values->HasKey("push_url"))
			{
				Windows::Storage::ApplicationData::Current->LocalSettings->Values->Insert("push_url", url);
			}
			else
			{
				Platform::String^ oldUrl = static_cast<Platform::String^>(Windows::Storage::ApplicationData::Current->LocalSettings->Values->Lookup("push_url"));
				if (oldUrl != url)
				{
					Windows::Storage::ApplicationData::Current->LocalSettings->Values->Insert("push_url", url);
				}
			}
		}
		catch (Platform::COMException^ e)
		{
			//如果获取失败 清空本地缓存的push标识码
			if (!Windows::Storage::ApplicationData::Current->LocalSettings->Values->HasKey("push_url"))
			{
				Windows::Storage::ApplicationData::Current->LocalSettings->Values->Remove("push_url");
			}
		}
	});
}

void ClearOpenUdidData()
{
}
const bool IsAppAdHocMode()
{
	if (isAppHoc != -1)
	{
		return isAppHoc == 1;
	}
	bool flag = false;
	create_task(cocos2d::WinRTHelper::RunOnUIThread([=, &flag](){
		Platform::Object^ val = Windows::UI::Xaml::Application::Current->Resources->Lookup(L"AppHoc");
		flag = val->Equals(Platform::Boolean(true));
	}, Windows::UI::Core::CoreDispatcherPriority::High)).wait();
	isAppHoc = flag ? 1 : 0;
	return flag;
}


bool IsLowMemoryDevice()
{
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)
	if (isLowMemoryDevice != -1)
	{
		return isLowMemoryDevice == 1;
	}
	unsigned long  long usage = Windows::System::MemoryManager::AppMemoryUsageLimit;
	auto ret = usage / (1024 * 1024);
	isLowMemoryDevice = ret <= 400 ? 1 : 0;
	return isLowMemoryDevice == 1;
#else
	return false;
#endif
}

long GetAppMemoryUsage()
{
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)
	long usage = Windows::System::MemoryManager::AppMemoryUsage / (1024 * 1024);
	return usage;
#else
	return 0;
#endif
}
//just for android IMEI,other platform return "unknown"
std::string GetDeviceId()
{
    return "unknown";
}
//just for android id,other platform return "unknown"
std::string GetAndroidId()
{
    return "unknown";
}
#endif