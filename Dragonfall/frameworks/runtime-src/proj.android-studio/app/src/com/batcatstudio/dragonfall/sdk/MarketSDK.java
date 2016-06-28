package com.batcatstudio.dragonfall.sdk;

import java.util.HashMap;
import android.app.Activity;
import com.batcatstudio.dragonfall.utils.CommonUtils;
//#ifdef CC_USE_TALKING_DATA
//@import org.cocos2dx.lua.AppActivity;
//@
//@import com.appsflyer.AFInAppEventParameterName;
//@import com.appsflyer.AFInAppEventType;
//@import com.batcatstudio.dragonfall.utils.DebugUtil;
//@import com.tendcloud.tenddata.TDGAAccount;
//@import com.tendcloud.tenddata.TDGAItem;
//@import com.tendcloud.tenddata.TDGAVirtualCurrency;
//@import com.tendcloud.tenddata.TalkingDataGA;
//@
//#endif
//#ifdef CC_USE_APPSFLYER
//@import com.appsflyer.AppsFlyerLib;
//#endif
public class MarketSDK {
//#ifdef CC_USE_APPSFLYER
//@	private static String APPSFLYER_DEV_KEY = "ZP4ME9pKgfnjPDPobDyt"; //for aiyingyong
//#endif
//#ifdef CC_USE_TALKING_DATA
//@	private static String TD_APP_ID = "A96439345EE4F59AEF4CBF1DEFF21DEA"; // for aiyingyong
//@	private static String TD_CHANNEL_ID = "All";
//@	private static TDGAAccount tdga_account = null;
//#endif

	private static String TAG = "MarketSDK";
	public static void initSDK() {
		if(shouldCloseSDK()){
			return;
		}
//#ifdef CC_USE_TALKING_DATA
//@		TalkingDataGA.init(AppActivity.getGameActivity().getApplicationContext(), TD_APP_ID,
//@				TD_CHANNEL_ID);
//@		TalkingDataGA.setVerboseLogDisabled();
//#endif
//#ifdef CC_USE_APPSFLYER
//@		AppsFlyerLib.setAppsFlyerKey(APPSFLYER_DEV_KEY);
//@		AppsFlyerLib.sendTracking(AppActivity.getGameActivity().getApplicationContext());
//#endif
	}

	private static boolean shouldCloseSDK()
	{
		return CommonUtils.isAppHocMode();
	}

	public static void onPlayerLogin(String playerId, String playerName,
			String serverName) {
		if(shouldCloseSDK()){
			return;
		}
//#ifdef CC_USE_TALKING_DATA
//@		TDGAAccount account = TDGAAccount.setAccount(playerId);
//@		account.setAccountName(playerName);
//@		account.setAccountType(TDGAAccount.AccountType.REGISTERED);
//@		account.setGender(TDGAAccount.Gender.UNKNOW);
//@		account.setGameServer(serverName);
//@		tdga_account = account;
//#endif
	}

	public static void onPlayerChargeRequst(String orderID, String productId,
			double currencyAmount, double virtualCurrencyAmount,
			String currencyType) {
		if(shouldCloseSDK()){
			return;
		}
//#ifdef CC_USE_TALKING_DATA
//@		TDGAVirtualCurrency.onChargeRequest(orderID, productId, currencyAmount, currencyType, virtualCurrencyAmount, "Google");
//#endif
	}
	
	public static void onPlayerChargeSuccess(String orderID){
		if(shouldCloseSDK()){
			return;
		}
//#ifdef CC_USE_TALKING_DATA
//@		TDGAVirtualCurrency.onChargeSuccess(orderID);
//#endif
	}
	
	public static void onPlayerBuyGameItems(String itemID,int count,double itemPrice){
		if(shouldCloseSDK()){
			return;
		}
//#ifdef CC_USE_TALKING_DATA
//@		TDGAItem.onPurchase(itemID, count, itemPrice);
//#endif
	}

	public static void onPlayerUseGameItems(String itemID,int count) {
		if(shouldCloseSDK()){
			return;
		}
//#ifdef CC_USE_TALKING_DATA
//@		TDGAItem.onUse(itemID, count);
//#endif
	}

	public static void onPlayerReward(double count,String reason) {
		if(shouldCloseSDK()){
			return;
		}
//#ifdef CC_USE_TALKING_DATA
//@		TDGAVirtualCurrency.onReward(count, reason);
//#endif
	}

	//just send event to TalkingData
	public static void onPlayerEvent(String event_id,String args) {
		if(shouldCloseSDK()){
			return;
		}
//#ifdef CC_USE_TALKING_DATA
//@		HashMap<String,String>   hashmap = new HashMap<String,String>();
//@		hashmap.put("desc",args);
//@		TalkingDataGA.onEvent(event_id, hashmap);
//#endif
	}

	//just send event to AppsFlyer
	public static void onPlayerEventAF(String event_id,String args) {
		if(shouldCloseSDK()){
			return;
		}
		//#ifdef CC_USE_APPSFLYER
//@		HashMap<String,Object>  hashmap = new HashMap<String,Object>();
//@		hashmap.put(AFInAppEventParameterName.DESCRIPTION,args);
//@		AppsFlyerLib.trackEvent(AppActivity.getGameActivity(),event_id,hashmap);
		//#endif
	}

	public static void onPlayerLevelUp(int level) {
		if(shouldCloseSDK()){
			return;
		}
//#ifdef CC_USE_TALKING_DATA
//@		if (tdga_account!=null) {
//@			tdga_account.setLevel(level);
//@		}
//#endif
	}
	//life cycle
	public static void onResume(Activity activity) {
		if(shouldCloseSDK()){
			return;
		}
//#ifdef CC_USE_TALKING_DATA
//@		TalkingDataGA.onResume(activity);
//#endif
	}
	public static void onPause(Activity activity) {
		if(shouldCloseSDK()){
			return;
		}
//#ifdef CC_USE_TALKING_DATA
//@		TalkingDataGA.onPause(activity);
//#endif
	}
	
}
