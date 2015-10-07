#include "common/RTCommonUtils.h"
#include "WinRTHelper.h"
#include <ppltasks.h>
#if defined(WINRT)

using namespace Platform;
using namespace Windows::Foundation;
using namespace Windows::ApplicationModel;
using namespace cocos2d;
using namespace concurrency;

void CopyText(const char * text)
{
	
}


void DisableIdleTimer(bool disable)
{
	
}

void CloseKeyboard()
{

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
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)
	//Windows::ApplicationModel::Email::EmailMessage^ message = ref new Windows::ApplicationModel::Email::EmailMessage();
	//Platform::String^ p = "test@test.com";
	//message->Subject = p;
	//message->Body = p;
	//Windows::ApplicationModel::Email::EmailRecipient^ recipient = ref new Windows::ApplicationModel::Email::EmailRecipient(p);
	//message->To->Append(recipient);
	//create_task(Windows::ApplicationModel::Email::EmailManager::ShowComposeNewEmailAsync(message));
#endif
	return "WP8";
}


std::string GetDeviceLanguage()
{
	return "Not support in WinRT use device.language get value";
}

int getBatteryLevel()
{
	/*return Plus2SharpHelper::NativeDelegate::GetInstance()->GlobalCallback->getBatteryLevel();*/
	return 1;
}

std::string getInternetConnectionStatus()
{
	/*Platform::String^ ps = Plus2SharpHelper::NativeDelegate::GetInstance()->GlobalCallback->getInternetConnectionStatus();
	return Plus2SharpHelper::PlatformStringToString(ps);*/
	return "0";
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
	return true;
}
#endif