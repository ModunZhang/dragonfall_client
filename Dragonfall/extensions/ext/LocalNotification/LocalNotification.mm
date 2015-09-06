//
//  LocalNotification.cpp
//  kod
//
//  Created by Dannyhe on 8/23/14.
//
//

#include "LocalNotification.h"
#import <UIKit/UIKit.h>
#include <map>
#include <string>

static std::map<std::string, bool> m_localNotificationState;

NSMutableDictionary *m_localNotification_dictionary = NULL;


static void _cancelAllLocalDic()
{
    if (m_localNotification_dictionary == NULL)
    {
         m_localNotification_dictionary = [[NSMutableDictionary alloc]init];
    }
    if (m_localNotification_dictionary != NULL)
    {
        [m_localNotification_dictionary removeAllObjects];
    }
}

static  bool _cancelNotificationWithIdentity(NSString *identity)
{
    if (m_localNotification_dictionary != NULL)
    {
        UILocalNotification *exist_notification = [m_localNotification_dictionary objectForKey:identity];
        if (exist_notification)
        {
            [[UIApplication sharedApplication] cancelLocalNotification:exist_notification];
            [m_localNotification_dictionary removeObjectForKey:identity];
            NSLog(@"cancelNotificationWithIdentity------>%@",identity);
            return true;
        }
    }
    return false;
}

static void _addLocalDic(NSString *identity,UILocalNotification *localNotification)
{    
    _cancelNotificationWithIdentity(identity);
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    [m_localNotification_dictionary setObject:localNotification forKey:identity];
#ifdef DEBUG
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *notifDate = [formatter stringFromDate:localNotification.fireDate];
    NSLog(@"scheduleLocalNotification--->%@:@%@",identity,notifDate);
#endif

}



void cancelAll()
{
    NSLog(@"cancelAll------>");
    _cancelAllLocalDic();
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

void switchNotification(const char *type, bool enable)
{
    std::map<std::string, bool>::iterator it = m_localNotificationState.find(type);
    if (it != m_localNotificationState.end())
    {
        m_localNotificationState.erase(it);
    }
    
    m_localNotificationState.insert(std::pair<std::string, bool>(type, enable));
}

bool addNotification(const char *type, long finishTime, const char *body, const char* identity)
{
    std::map<std::string, bool>::const_iterator it = m_localNotificationState.find(type);
    if (it != m_localNotificationState.end())
    {
        if ( !it->second )
        {
            return false;
        }
    }
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [[[NSDate alloc] initWithTimeIntervalSince1970:finishTime] autorelease];
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.userInfo = [NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithUTF8String:identity], @"identity",nil];
    localNotification.alertBody = [NSString stringWithCString:body encoding:NSUTF8StringEncoding];
    localNotification.applicationIconBadgeNumber = 1;
    // localNotification.soundName = UILocalNotificationDefaultSoundName;
    _addLocalDic([NSString stringWithUTF8String:identity],localNotification);
    [localNotification release];
    return true;
}

bool cancelNotificationWithIdentity(const char* identity)
{
    if (_cancelNotificationWithIdentity([NSString stringWithUTF8String:identity]))
    {
        return true;
    }
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSString *identity_ns = [NSString stringWithUTF8String:identity];
    for (UILocalNotification *notification in notifications)
    {
        
        NSString* identityObject = (NSString*)[notification.userInfo objectForKey:@"identity"];
        if (identityObject && [identityObject isEqualToString:identity_ns])
        {
            NSLog(@"cancelNotificationWithIdentity------>%@",identity_ns);
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            return  true;
        }
    }
    return  false;
}