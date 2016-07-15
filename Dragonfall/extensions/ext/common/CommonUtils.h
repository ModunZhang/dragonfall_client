#ifndef __kod_commonutils__
#define __kod_commonutils__
#include "cocos2d.h"
#include <stdlib.h>
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>
#elif CC_TARGET_PLATFORM == CC_PLATFORM_WINRT
#include <functional>
#endif

//copy text to Pasteboard
void CopyText(std::string text);

void DisableIdleTimer(bool disable=false);

void CloseKeyboard();

std::string GetOSVersion();

std::string GetDeviceModel();
//print log in release
void WriteLog_(std::string str);

std::string GetAppVersion();

std::string GetAppBundleVersion();

std::string GetDeviceToken();

long long GetOSTime();

std::string GetOpenUdid();

void RegistereForRemoteNotifications();

void ClearOpenUdidData();

std::string GetDeviceLanguage();

float GetBatteryLevel();

std::string GetInternetConnectionStatus();

const bool IsAppAdHocMode();

//memory about
bool IsLowMemoryDevice();

long GetAppMemoryUsage();

//just for android IMEI,other platform return "unknown"
std::string GetDeviceId();
//just for android id,other platform return "unknown"
std::string GetAndroidId();

//channelName:  gNetTop sugarcanetechnology etc..
const bool ChannelIsEqTo(std::string channelName);

std::string GetAppBundleId();

std::string GetBuglyId();

//marketName: Apple GooglePlay Microsoft 360 etc...
const bool MarketIsEqTo(std::string marketName);

#if CC_TARGET_PLATFORM == CC_PLATFORM_WINRT

void OpenUrl(std::string url);

void ShowAlert(std::string title, std::string content,std::string okString,std::function<void(void)> callbackFunc);

#elif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID

void AndroidCheckFistInstall();
bool isGameLaunched();//finish the unzip resources on android

#endif

#endif