#include "common/RTCommonUtils.h"
#include "WinRTHelper.h"
#include <ppltasks.h>
#if defined(WINRT)

using namespace Platform;
using namespace Windows::Foundation;
using namespace Windows::ApplicationModel;
using namespace cocos2d;
using namespace concurrency;

//wp8.1不支持 参考 https://social.msdn.microsoft.com/Forums/sqlserver/en-US/ac4f3329-d7ee-455f-80be-0e1685fea971/how-to-copy-text-to-the-clipboard-in-wp81-using-vs2013-can-not-refer-to-the-correct-namespace?forum=wpdevelop
void CopyText(const char * text)
{
	
}


void DisableIdleTimer(bool disable)
{
	//不支持?
}

void CloseKeyboard()
{
	//不提供
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
void WriteLog_(const char *str)
{
	
}
//wp上我们只取前三位作为版本号
std::string GetAppVersion()
{
	Windows::ApplicationModel::Package^ package = Windows::ApplicationModel::Package::Current;
	Windows::ApplicationModel::PackageId^ packageId = package->Id;
	Windows::ApplicationModel::PackageVersion version = packageId->Version;

	Platform::String^ output = version.Major.ToString() + "." + version.Minor.ToString() + "." +
		version.Build.ToString();
	return cocos2d::WinRTHelper::PlatformStringToString(output);
}
//暂时使用version
std::string GetAppBundleVersion()
{
	return GetAppVersion();
}
std::string GetDeviceToken()
{
	return "WP8";
}

std::string GetDeviceLanguage()
{
	return "Not support in WinRT use device.language get value";
}

int getBatteryLevel()
{
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)
	return Windows::Phone::Devices::Power::Battery::GetDefault()->RemainingChargePercent;
#endif
	return 1;
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
std::string getInternetConnectionStatus()
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

void registereForRemoteNotifications()
{
}

void ClearOpenUdidData()
{
}
const bool isAppAdHocMode()
{
	/*cocos2d::WinRTHelper::RunOnUIThread([=](){
		Platform::Object^ val = Windows::UI::Xaml::Application::Current->Resources->Lookup(L"AppHoc");
		val->Equals(Platform::Boolean(true));
	});*/
	return true;
}
#endif