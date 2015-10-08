#pragma once
#ifndef __LocalNotificationWinRT__h__
#define __LocalNotificationWinRT__h__
#if defined(WINRT)
void cancelAll();
void switchNotification(std::string type, bool enable);
bool addNotification(std::string type, long finishTime, std::string body, std::string identity);
bool cancelNotificationWithIdentity(std::string identity);
#endif
#endif /* defined(__LocalNotificationWinRT__h__) */