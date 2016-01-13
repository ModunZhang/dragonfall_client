package com.batcatstudio.dragonfall.sdk;

import java.util.HashMap;

import org.cocos2dx.lua.AppActivity;

import android.app.Activity;

import com.tendcloud.tenddata.TDGAAccount;
import com.tendcloud.tenddata.TDGAItem;
import com.tendcloud.tenddata.TDGAVirtualCurrency;
import com.tendcloud.tenddata.TalkingDataGA;

public class MarketSDK {

	private static String TD_APP_ID = "13842425C091E33B40189A1C9BB6B433"; // test
	private static String TD_CHANNEL_ID = "All";
	private static TDGAAccount tdga_account = null;
	
	public static void initSDK() {
		TalkingDataGA.init(AppActivity.getGameActivity().getApplicationContext(), TD_APP_ID,
				TD_CHANNEL_ID);
//#ifndef COCOS_DEBUG
//@		TalkingDataGA.setVerboseLogDisabled();
//#endif
	}

	public static void onPlayerLogin(String playerId, String playerName,
			String serverName) {
		
		TDGAAccount account = TDGAAccount.setAccount(playerId);
		account.setAccountName(playerName);
		account.setAccountType(TDGAAccount.AccountType.REGISTERED);
		account.setGender(TDGAAccount.Gender.UNKNOW);
		account.setGameServer(serverName);
		tdga_account = account;
	}

	public static void onPlayerChargeRequst(String orderID, String productId,
			double currencyAmount, double virtualCurrencyAmount,
			String currencyType) {
		TDGAVirtualCurrency.onChargeRequest(orderID, productId, currencyAmount, currencyType, virtualCurrencyAmount, "Google");
	}
	
	public static void onPlayerChargeSuccess(String orderID){
		TDGAVirtualCurrency.onChargeSuccess(orderID);
	}
	
	public static void onPlayerBuyGameItems(String itemID,int count,double itemPrice){
		TDGAItem.onPurchase(itemID,count,itemPrice);
	}

	public static void onPlayerUseGameItems(String itemID,int count) {
		TDGAItem.onUse(itemID, count);
	}

	public static void onPlayerReward(double count,String reason) {
		TDGAVirtualCurrency.onReward(count,reason);
	}

	public static void onPlayerEvent(String event_id,String args) {
		HashMap<String,String>   hashmap = new HashMap<String,String>();   
		hashmap.put("desc",args);
		TalkingDataGA.onEvent(event_id,hashmap);
	}

	public static void onPlayerLevelUp(int level) {
		if (tdga_account!=null) {
			tdga_account.setLevel(level);
		}
	}
	//life cycle
	public static void onResume(Activity activity) {
		TalkingDataGA.onResume(activity);
	}
	public static void onPause(Activity activity) {
		TalkingDataGA.onPause(activity);
	}
	
}
