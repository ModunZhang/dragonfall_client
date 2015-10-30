//
//  LocalNotification.h
//  kod
//
//  Created by Dannyhe on 8/23/14.
//
//

#ifndef __kod__LocalNotification__
#define __kod__LocalNotification__
#include <string>
#include <stdlib.h>

void cancelAll();
void switchNotification(std::string type, bool enable);
bool addNotification(std::string type, long finishTime, std::string body, std::string identity);
bool cancelNotificationWithIdentity(std::string identity);

#endif /* defined(__kod__LocalNotification__) */
