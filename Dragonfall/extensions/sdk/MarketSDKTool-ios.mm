//
//  MarketSDKTool.m
//  kod
//
//  Created by DannyHe on 3/13/15.
//
//

#include "MarketSDKTool.h"
#include "CommonUtils.h"
//force unuse appsflyer on iOS Simulator
#if TARGET_IPHONE_SIMULATOR
#if CC_USE_APPSFLYER
#undef CC_USE_APPSFLYER
#endif
#endif

#include "tolua_fix.h"
#if CC_USE_TAKING_DATA
#import "TalkingDataGA.h"
#endif
#if CC_USE_APPSFLYER
#include "AppsFlyerTracker.h"
#endif


#define TD_APP_ID @"A96439345EE4F59AEF4CBF1DEFF21DEA"
#define TD_CHANNEL_ID @"All"
#define APPSFLYER_DEV_KEY @"ZP4ME9pKgfnjPDPobDyt" //xapcn
#define APPSFLYER_DEV_APP_ID @""

static MarketSDKTool *s_MarketSDKTool = NULL; // pointer to singleton
#ifdef CC_USE_TAKING_DATA
static TDGAAccount *tdga_account = NULL;
#endif
MarketSDKTool * MarketSDKTool::getInstance()
{
    if(!s_MarketSDKTool)
    {
        s_MarketSDKTool = new MarketSDKTool();
    }
    return s_MarketSDKTool;
}

void MarketSDKTool::destroyInstance()
{
     if(s_MarketSDKTool)
     {
         delete s_MarketSDKTool;
         s_MarketSDKTool = NULL;
     }
}

bool MarketSDKTool::shouldCloseSDK()
{
    return IsAppAdHocMode();
}

void MarketSDKTool::initSDK()
{
    if(shouldCloseSDK())return;
#ifdef CC_USE_TAKING_DATA
    [TalkingDataGA onStart:TD_APP_ID withChannelId:TD_CHANNEL_ID];
    [TalkingDataGA setVerboseLogDisabled];
#endif
#if CC_USE_APPSFLYER
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = APPSFLYER_DEV_KEY;
    [AppsFlyerTracker sharedTracker].appleAppID = @"REPLACE THIS WITH YOUR App_ID";
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
#endif
}


void MarketSDKTool::onPlayerLogin(const char *playerId,const char*playerName,const char*serverName)
{
    if(shouldCloseSDK())return;
#ifdef CC_USE_TAKING_DATA
    TDGAAccount *account = [TDGAAccount setAccount:[NSString stringWithUTF8String:playerId]];
    [account setAccountName:[NSString stringWithUTF8String:playerName]];
    [account setAccountType:kAccountRegistered];
    [account setGender:kGenderUnknown];
    [account setGameServer:[NSString stringWithUTF8String:serverName]];
    tdga_account = account;
#endif
}

void MarketSDKTool::onPlayerChargeRequst(const char *orderID, const char *productId, double currencyAmount, double virtualCurrencyAmount,const char *currencyType)
{
    if(shouldCloseSDK())return;
#ifdef CC_USE_TAKING_DATA
    [TDGAVirtualCurrency onChargeRequst:[NSString stringWithUTF8String:orderID]
                                  iapId:[NSString stringWithUTF8String:productId]
                         currencyAmount:currencyAmount currencyType:[NSString stringWithUTF8String:currencyType]
                  virtualCurrencyAmount:virtualCurrencyAmount
                            paymentType:@"Apple"];
#endif
}

void MarketSDKTool::onPlayerChargeSuccess(const char *orderID)
{
     if(shouldCloseSDK())return;
#ifdef CC_USE_TAKING_DATA
     [TDGAVirtualCurrency onChargeSuccess:[NSString stringWithUTF8String:orderID]];
#endif
}

void MarketSDKTool::onPlayerBuyGameItems(const char *itemID, int count, double itemPrice)
{
    if(shouldCloseSDK())return;
#ifdef CC_USE_TAKING_DATA
    [TDGAItem onPurchase:[NSString stringWithUTF8String:itemID] itemNumber:count priceInVirtualCurrency:itemPrice];
#endif
}

void MarketSDKTool::onPlayerUseGameItems(const char *itemID,int count)
{
    if(shouldCloseSDK())return;
#ifdef CC_USE_TAKING_DATA
    [TDGAItem onUse:[NSString stringWithUTF8String:itemID] itemNumber:count];
#endif
}

void MarketSDKTool::onPlayerReward(double cont,const char* reason)
{
    if(shouldCloseSDK())return;
#ifdef CC_USE_TAKING_DATA
    [TDGAVirtualCurrency onReward:cont reason:[NSString stringWithUTF8String:reason]];
#endif
}

void MarketSDKTool::onPlayerEvent(const char *event_id,const char*arg)
{
    if(shouldCloseSDK())return;
#ifdef CC_USE_TAKING_DATA
    [TalkingDataGA onEvent:[NSString stringWithUTF8String:event_id] eventData:@{@"desc":[NSString stringWithUTF8String:arg]}];
#endif
}
void MarketSDKTool::onPlayerEventAF(const char *event_id,const char*arg)
{
    if(shouldCloseSDK())return;
#if CC_USE_APPSFLYER
    NSString *data = [NSString stringWithUTF8String:arg];
    [[AppsFlyerTracker sharedTracker]trackEvent:[NSString stringWithUTF8String:event_id] withValues:@{AFEventParamDescription:data}];
#endif
}

void MarketSDKTool::onPlayerLevelUp(int level)
{
    if(shouldCloseSDK())return;
#ifdef CC_USE_TAKING_DATA
    if (tdga_account) {
        [tdga_account setLevel:level];
    }
#endif
}