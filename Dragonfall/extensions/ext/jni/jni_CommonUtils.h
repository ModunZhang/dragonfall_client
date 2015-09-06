#ifndef Android_jni_CommonUtils_h
#define Android_jni_CommonUtils_h
#include "cocos2d.h"
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>

//copy text to Pasteboard
void CopyText(const char * text);
void DisableIdleTimer(bool disable=false);
void CloseKeyboard();
const char* GetOSVersion();
const char* GetDeviceModel();
void WriteLog_(const char *str);
const char* GetAppVersion();
const char* GetAppBundleVersion();
const char* GetDeviceToken();
const char* GetOpenUdid();
void registereForRemoteNotifications();
void ClearOpenUdidData(); // 注意！这个方法绝对不能在发布环境里调用
const char* GetDeviceLanguage();
void AndroidCheckFistInstall();
float getBatteryLevel();
const char* getInternetConnectionStatus();
const bool isAppAdHocMode();
#endif