package com.batcatstudio.dragonfall.utils;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager.NameNotFoundException;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;

import com.batcatstudio.dragonfall.google.gcm.GCMUtils;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.xapcn.dragonfall.R;

import org.cocos2dx.lua.AppActivity;
import org.cocos2dx.utils.PSNetwork;

import java.util.Locale;

public class CommonUtils {
	private static String TAG = "CommonUtils";
	private static CommonUtils m_instance = null;
	private DeviceInfo deviceInfo = null;

	public ClipboardManager clipManager;

	public ClipboardManager getClipManager() {
		return clipManager;
	}

	public DeviceInfo getDeviceInfo() {
		return deviceInfo;
	}

	public CommonUtils() {
		deviceInfo = new DeviceInfo();
		try {
			clipManager = (ClipboardManager) AppActivity.getGameActivity().getSystemService(Context.CLIPBOARD_SERVICE);
		} catch (Exception e) {
			DebugUtil.LogException(TAG, e);
		}
	}

	public static CommonUtils getInstance() {
		if (m_instance == null) {
			m_instance = new CommonUtils();
		}
		return m_instance;
	}

	// jni method
	public static String getUDID() {
		String udid = getInstance().getDeviceInfo().getUdid();
		return udid;
	}

	public static void copyText(String str) {
		try {
			getInstance().getClipManager().setPrimaryClip(ClipData.newPlainText(null, str));  
		} catch (Exception e) {
			DebugUtil.LogException(TAG, e);
		}

	}

	public static String getAppVersion() {
		return getInstance().getDeviceInfo().getAppVersion();
	}

	public static String getOSVersion() {
		return getInstance().getDeviceInfo().getOsVersion();
	}

	public static String getDeviceModel() {
		return getInstance().getDeviceInfo().getDeviceModel();
	}

	public static String getAppBundleVersion() {
		int versionCode = getInstance().getDeviceInfo().getAppBundleVersion();
		return String.valueOf(versionCode);
	}

	public static String getDeviceLanguage() {
		return Locale.getDefault().toString();
	}

	public static boolean sendMail(String receiver, String subject, String content) {
		Intent intent = new Intent(Intent.ACTION_SEND);
		intent.setType("plain/text");
		intent.putExtra(Intent.EXTRA_EMAIL, new String[] { receiver });
		intent.putExtra(Intent.EXTRA_SUBJECT, subject);
		intent.putExtra(Intent.EXTRA_TEXT, content);
		AppActivity.getGameActivity().startActivity(
				Intent.createChooser(intent, AppActivity.getGameActivity().getString(R.string.send_mail_tip)));
		return true;
	}

	public static boolean canSendMail() {
		return true;
	}

	// Check hasInstallPackage
	public static boolean hasInstallPackage(String packageName) {
		PackageInfo packageInfo;
		try {
			packageInfo = AppActivity.getGameActivity().getPackageManager().getPackageInfo(packageName, 0);
		} catch (NameNotFoundException e) {
			packageInfo = null;
		}
		if (packageInfo == null) {
			return false;
		} else {
			return true;
		}
	}
	public static void openAppInGooglePlayMarket(String packageName)
	{
		Uri uri = Uri.parse("market://details?id=" + packageName);  
        Intent it = new Intent(Intent.ACTION_VIEW, uri);   
        AppActivity.getGameActivity().startActivity(it);
	}
	
	public static void checkGameFirstInstall() {
		LaunchHelper.checkGameFirstInstall();
	}
	
	public static void disableIdleTimer(boolean disable) {
		AppActivity.getGameActivity().setKeepScreenOn(disable);
	}

	public static float batteryLevel(){
		
		Intent batteryIntent = AppActivity.getGameActivity().getApplicationContext().registerReceiver(null,
                    new IntentFilter(Intent.ACTION_BATTERY_CHANGED));
		int rawlevel = batteryIntent.getIntExtra("level", -1);
		float scale = batteryIntent.getIntExtra("scale", -1);
		float level = -1;
		if (rawlevel >= 0 && scale > 0) {
    		level = rawlevel / scale;
		}
		return level;
	}

	public static String getInternetConnectionStatus(){
		int status = PSNetwork.getInternetConnectionStatus();
		if(status == 0) {
			return "NotReachable";
		}
		if(status == 1) {
			return "ReachableViaWiFi";
		}
		ConnectivityManager mConnManager =  (ConnectivityManager) AppActivity.getGameActivity()
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo info = mConnManager.getActiveNetworkInfo();
		String strOfStatus = info.getSubtypeName();
		if(strOfStatus!=null){
			return strOfStatus;
		}
		return "NotReachable";
	}
	
	public static String getAppMinVersion() {
		return getInstance().getDeviceInfo().getAppMinVersion();
	}
	public static boolean isAppHocMode() {
		return getInstance().getDeviceInfo().isAppHocMode();
	}

	public static String GetDeviceToken() {
		return GCMUtils.getRegisterId();
	}
	
	public static boolean isLowMemoryDevice() {
		return getInstance().getDeviceInfo().isLowMemoryDevice();
	}

	public static boolean isGameLaunched(){
		return AppActivity.getGameActivity().isGameLaunched();
	}
	
	public static void RegistereForRemoteNotifications() {
		getInstance().RegisterGCMServiceIf();
	}
	
	// we want to register the GCM service if the device support
    private void RegisterGCMServiceIf()
    {
    	if(isGooglePlayServiceAvailable())
    	{
    		GCMUtils.registerGCMService(AppActivity.getGameActivity());
    	}
    }
	public static boolean isGooglePlayServiceAvailable () {
		int status = GooglePlayServicesUtil.isGooglePlayServicesAvailable(AppActivity.getGameActivity());
		if (status == ConnectionResult.SUCCESS) {
			return true;
		} else {
			return false;
		}
	}
}
