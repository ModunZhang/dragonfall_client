#ifndef __kod_commonutils__RTCommonUtils
#define __kod_commonutils__RTCommonUtils
#if defined(WINRT)
//copy text to Pasteboard
void CopyText(const char * text);
void DisableIdleTimer(bool disable=false);
void CloseKeyboard();
std::string GetOSVersion();
std::string GetDeviceModel();
void WriteLog_(const char *str);
std::string GetAppVersion();
std::string GetAppBundleVersion();
std::string GetDeviceToken();
std::string GetOpenUdid();
void registereForRemoteNotifications();
void ClearOpenUdidData(); // 注意！这个方法绝对不能在发布环境里调用
std::string GetDeviceLanguage();
int getBatteryLevel();
std::string getInternetConnectionStatus();
const bool isAppAdHocMode();
#endif
#endif