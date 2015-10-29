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

void WriteLog_(std::string str);

std::string GetAppVersion();

std::string GetAppBundleVersion();

std::string GetDeviceToken();

long long GetOSTime();

std::string GetOpenUdid();

void RegistereForRemoteNotifications();

void ClearOpenUdidData(); // 注意！这个方法绝对不能在发布环境里调用
                          // 
std::string GetDeviceLanguage();

float GetBatteryLevel();

std::string GetInternetConnectionStatus();

const bool IsAppAdHocMode();

#if CC_TARGET_PLATFORM == CC_PLATFORM_WINRT
void OpenUrl(std::string url);
void ShowAlert(std::string title, std::string content,std::string okString,std::function<void(void)> callbackFunc);
#endif

#endif