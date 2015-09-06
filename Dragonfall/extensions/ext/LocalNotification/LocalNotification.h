//
//  LocalNotification.h
//  kod
//
//  Created by Dannyhe on 8/23/14.
//
//

#ifndef __kod__LocalNotification__
#define __kod__LocalNotification__

void cancelAll();
void switchNotification(const char *type, bool enable);
bool addNotification(const char *type, long finishTime, const char *body, const char* identity);
bool cancelNotificationWithIdentity(const char* identity);

#endif /* defined(__kod__LocalNotification__) */
