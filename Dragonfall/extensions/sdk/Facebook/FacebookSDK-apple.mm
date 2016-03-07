#include "FacebookSDK.h"
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS

#if CC_USE_FACEBOOK
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#endif

static FacebookSDK *s_FacebookSDK = NULL; // pointer to singleton

void FacebookSDK::Initialize(std::string appId /* = "" */)
{
}

FacebookSDK::~FacebookSDK()
{
    if (s_FacebookSDK != NULL)
    {
        delete s_FacebookSDK;
        s_FacebookSDK = NULL;
    }
}

FacebookSDK* FacebookSDK::GetInstance()
{
    if (s_FacebookSDK == NULL)
    {
        s_FacebookSDK = new FacebookSDK();
    }
    return s_FacebookSDK;
}
/*
 * 返回是否已经有取到过账号
 */
bool FacebookSDK::IsAuthenticated()
{
#if CC_USE_FACEBOOK
    FBSDKProfile* profile = [FBSDKProfile currentProfile];
    return profile != nil;
#endif  
    return false;
}

std::string FacebookSDK::GetFBUserName()
{
#if CC_USE_FACEBOOK
    FBSDKProfile* profile = [FBSDKProfile currentProfile];
    if(nil != profile)
    {
        return std::string([[profile name]UTF8String]);
    }
#endif
    return std::string("");
}

std::string FacebookSDK::GetFBUserId()
{
#if CC_USE_FACEBOOK
    FBSDKProfile* profile = [FBSDKProfile currentProfile];
    if(nil != profile)
    {
        return std::string([[profile userID]UTF8String]);
    }
#endif
    return std::string("");
}

void FacebookSDK::AppInvite(std::string title,std::string message)
{
    //TODO:iOS
}

/**
 *  登录facebook,每次调用都会弹出登录框,并请求新的的FBSDKAccessToken
 */
void FacebookSDK::Login()
{
#if CC_USE_FACEBOOK
    [FBSDKAccessToken setCurrentAccessToken:nil];//强制清空accessToken
    FBSDKLoginManager *login = [[[FBSDKLoginManager alloc] init]autorelease];
    login.loginBehavior = FBSDKLoginBehaviorWeb;
    [login logInWithReadPermissions:@[@"public_profile"]
                 fromViewController:nil
                            handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
    {
        if (error)
        {
            cocos2d::ValueMap tempMap;
            tempMap["event"] = "login_exception";
            CallLuaCallback(tempMap);
        } else if (result.isCancelled)
        {
            cocos2d::ValueMap tempMap;
            tempMap["event"] = "login_failed";
            CallLuaCallback(tempMap);
        }
        else
        {
            FBSDKProfile* profile = [FBSDKProfile currentProfile];
            if(profile &&[profile.userID isEqualToString:result.token.userID])
            {
                cocos2d::ValueMap tempMap;
                tempMap["userid"] = [[profile userID] UTF8String];
                tempMap["username"] = [[profile name] UTF8String];
                tempMap["event"] = "login_success";
                CallLuaCallback(tempMap);
            }
            else
            {
                //如果这里读取email字段的数据，有可能为空，需要进行判断
                FBSDKGraphRequest* Fbgr = [[[FBSDKGraphRequest alloc]initWithGraphPath:@"me" parameters:@{@"fields":@"id,name"}]autorelease];
                [Fbgr startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
                {
                     if (!error && [result isKindOfClass:[NSDictionary class]])
                     {
                         NSDictionary* data = (NSDictionary*)result;
                         cocos2d::ValueMap tempMap;
                         tempMap["userid"] = [[data objectForKey:@"id"]UTF8String];
                         tempMap["username"] = [[data objectForKey:@"name"]UTF8String];
                         tempMap["event"] = "login_success";
                         CallLuaCallback(tempMap);
                         FBSDKProfile* profile = [[FBSDKProfile alloc] initWithUserID:[data objectForKey:@"id"]
                                                                            firstName:@""
                                                                           middleName:@""
                                                                             lastName:@""
                                                                                 name:[data objectForKey:@"name"]
                                                                              linkURL:nil
                                                                          refreshDate:nil];
                         [FBSDKProfile setCurrentProfile:profile];
                         [profile release];
                     }
                     else
                     {
                         cocos2d::ValueMap tempMap;
                         tempMap["event"] = "login_exception";
                         CallLuaCallback(tempMap);
                     }
                }];
            }
        }
    }];
#endif
}
#endif