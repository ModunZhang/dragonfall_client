#include "CommonUtils.h"
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_MAC
#import <UIKit/UIKit.h>
#include <sys/utsname.h>
#import "AppController.h"
#import <CoreFoundation/CoreFoundation.h>
#import "UICKeyChainStore.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CommonCrypto/CommonDigest.h> // Need to import for CC_MD5 access
#include "cocos/quick_libs/src/extra/platform/ios_mac/ReachabilityIOSMac.h"

#ifdef DEBUG
#import <sys/sysctl.h>
#import <mach/mach.h>
#endif


#define kKeychainBatcatStudioIdentifier          @"kKeychainBatcatStudioIdentifier"
#define kKeychainBatcatStudioKeyChainService     @"com.batcatstudio.keychain"


//we want to sync the openudid to NSUserDefaults
#define kSyncOpenUDIDToUserDefaults 1

void CopyText(std::string text)
{
    [UIPasteboard generalPasteboard].string = [NSString stringWithUTF8String:text.c_str()];
}


void DisableIdleTimer(bool disable)
{
    [UIApplication sharedApplication].idleTimerDisabled = disable;
}

void CloseKeyboard()
{
    if ([[[[UIApplication sharedApplication]keyWindow]rootViewController].view respondsToSelector:@selector(handleTouchesAfterKeyboardShow)])
    {
        [[[[UIApplication sharedApplication]keyWindow]rootViewController].view
            performSelector:@selector(handleTouchesAfterKeyboardShow)
                 withObject:nil];
    }
}

std::string GetOSVersion()
{
    return std::string([[NSString stringWithFormat:@"iOS %@",[UIDevice currentDevice].systemVersion] UTF8String]);
}
/***
 　  iphone 5,1 　　iphone5(移动,联通)
 　　iphone 5,2	　　iphone5(移动,电信,联通)
 　　iphone 4,1	　   iphone4S
 　　iphone 3,1	　   iphone4(移动,联通)
 　　iphone 3,2  　  iphone4(联通)
 　　iphone 3,3	　   iphone4(电信)
 　　iphone 2,1       iphone3GS
 　　iphone 1,2	　   iphone3G
 　　iphone 1,1	　   iphone
 　　ipad 1,1	　　　 ipad 1
 　　ipad 2,1	　　　 ipad 2(Wifi)
 　　ipad 2,2	　　　 ipad 2(GSM)
 　　ipad 2,3	　　　 ipad 2(CDMA)
 　　ipad 2,4	　　　 ipad 2(32nm)
 　　ipad 2,5	　　　 ipad mini(Wifi)
 　　ipad 2,6	　　　 ipad mini(GSM)
 　　ipad 2,7	　　　 ipad mini(CDMA)
 　　ipad 3,1	　　　 ipad 3(Wifi)
 　　ipad 3,2	　　　 ipad 3(CDMA)
 　　ipad 3,3	　　　 ipad 3(4G)
 　　ipad 3,4　　　  ipad 4(Wifi)
 　　ipad 3,5　　　  ipad 4(4G)
 　　ipad 3,6　　　  ipad 4(CDMA)
 　　ipod 5,1　　　  ipod touch 5
 　　ipod 4,1　　　  ipod touch 4
 　　ipod 3,1	　　　 ipod touch 3
 　　ipod 2,1	　　　 ipod touch 2
 　　ipod 1,1	　　　 ipod touch
 ***/
std::string GetDeviceModel()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    return std::string([[NSString stringWithCString:systemInfo.machine
                               encoding:NSUTF8StringEncoding]UTF8String]);
}
//log
void WriteLog_(std::string str)
{
    NSLog(@"%@",[NSString stringWithUTF8String:str.c_str()]);
}

std::string GetAppVersion()
{
    return std::string([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]UTF8String]);
}
std::string GetAppBundleVersion()
{
    return std::string([[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]UTF8String]);
}
std::string GetDeviceToken()
{
    AppController * appController = (AppController *)[[UIApplication sharedApplication]delegate];
    return std::string([[appController remoteDeviceToken] UTF8String]);
}


std::string GetDeviceLanguage()
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    return std::string([currentLanguage UTF8String]);
}

long long GetOSTime()
{
    double currentTime = CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970;
    return (long long)(currentTime * 1000);
}
float GetBatteryLevel()
{
    [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];  
    return [[UIDevice currentDevice] batteryLevel];  
}

std::string GetInternetConnectionStatus()
{
    
    NetworkStatus status = [[ReachabilityIOSMac reachabilityForInternetConnection] currentReachabilityStatus];
    
    if (status == NotReachable)
    {
        return std::string("NotReachable");
    }
    if (status == ReachableViaWiFi)
    {
        return std::string("ReachableViaWiFi");
    }
    CTTelephonyNetworkInfo *networkInfo = [[[CTTelephonyNetworkInfo alloc] init]autorelease];
    if([networkInfo respondsToSelector:@selector(currentRadioAccessTechnology)])
    {
        return std::string([networkInfo.currentRadioAccessTechnology UTF8String]);
    }
    else
    {
        return std::string("CTRadioAccessTechnologyCDMA1x");
    }
    return std::string("NotReachable");
}
#ifndef kSyncOpenUDIDToUserDefaults
static NSString * shared_openUDID = NULL;
#endif
std::string GetOpenUdid()
{
#ifndef kSyncOpenUDIDToUserDefaults
    if(shared_openUDID!=NULL)
    {
        return std::string([shared_openUDID UTF8String]);
    }
#else
    NSUserDefaults *appleDefaults = [NSUserDefaults standardUserDefaults];
    if ([appleDefaults stringForKey:kKeychainBatcatStudioIdentifier]) {
        return [[appleDefaults stringForKey:kKeychainBatcatStudioIdentifier]UTF8String];
    }
#endif
    NSError *error = nil;
    NSString *_openUDID = [UICKeyChainStore stringForKey:kKeychainBatcatStudioIdentifier service:kKeychainBatcatStudioKeyChainService error:&error];
    if (error) {
        NSLog(@"%@", error.localizedDescription);
    }
    if(!_openUDID){
        CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
        CFStringRef cfstring = CFUUIDCreateString(kCFAllocatorDefault, uuid);
        const char *cStr = CFStringGetCStringPtr(cfstring,CFStringGetFastestEncoding(cfstring));
        unsigned char result[16];
        CC_MD5( cStr, strlen(cStr), result );
        CFRelease(uuid);
        CFRelease(cfstring);
        
        _openUDID = [NSString stringWithFormat:
                     @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%08x",
                     result[0], result[1], result[2], result[3],
                     result[4], result[5], result[6], result[7],
                     result[8], result[9], result[10], result[11],
                     result[12], result[13], result[14], result[15],
                     (NSUInteger)(arc4random() % NSUIntegerMax)];

        
        UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:kKeychainBatcatStudioKeyChainService];
        NSError *error = nil;
        [store setString:_openUDID forKey:kKeychainBatcatStudioIdentifier error:&error];
        if (error) {
            NSLog(@"%@", error.localizedDescription);
        }
    }
    NSLog(@"GetOpenUdid:%@",_openUDID);
#ifndef kSyncOpenUDIDToUserDefaults
    shared_openUDID = [[NSString alloc]initWithString:_openUDID];
    return std::string([shared_openUDID UTF8String]);
#else
    [appleDefaults setObject:_openUDID forKey:kKeychainBatcatStudioIdentifier];
    [appleDefaults synchronize];
    return [_openUDID UTF8String];
#endif
}

void RegistereForRemoteNotifications()
{
    UIApplication *application = [UIApplication sharedApplication];
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication]registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
    }

}

void ClearOpenUdidData()
{
#ifdef DEBUG
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:kKeychainBatcatStudioKeyChainService];
    [store removeItemForKey:kKeychainBatcatStudioIdentifier];
#endif

}
const bool IsAppAdHocMode()
{
    bool isDebug = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"AppHoc"] boolValue];
    return isDebug;
}

bool IsLowMemoryDevice()
{
#ifdef DEBUG
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0 <= 512.0;
#else
    return false;
#endif
}

long GetAppMemoryUsage()
{
#ifdef DEBUG
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size / 1024.0 / 1024.0;
#else
    return 0;
#endif
}

bool IsGoogleStore()
{
    return false;
}
#endif