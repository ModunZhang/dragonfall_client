package com.batcatstudio.dragonfall.utils;

import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.UUID;

import org.cocos2dx.lua.AppActivity;

import com.xapcn.dragonfall.R;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Build;
import android.provider.Settings;
import android.telephony.TelephonyManager;

public class DeviceInfo {

	private static String TAG = "DeviceInfo";

	private String androidId = "";
	private String deviceId = "";
	private String udid = "";
	private String osVersion = "";
	private String deviceModel = "";
	// bundle infomation
	private String appVersion = "";
	private int appBundleVersion = 0;

	private String appName = "";
	private String bundleId = "";

	private String appMinVersion = "";
	private boolean isAppHocMode = false;

	public DeviceInfo() {
		deviceId = initDeviceID();
		udid = initUDID();
		osVersion = String.format("Android %s", Build.VERSION.RELEASE);
		deviceModel = String.format("%s_%s_%s", Build.BRAND, Build.MODEL, Build.PRODUCT);
		initPackageInfomation();
		DebugUtil.LogDebug(TAG, "DeviceInfo init:deviceId:" + deviceId + ",udid:" + udid);
	}

	private void initPackageInfomation() {
		appName = AppActivity.getGameActivity().getString(R.string.app_name);
		bundleId = AppActivity.getGameActivity().getPackageName();
		PackageManager pm = AppActivity.getGameActivity().getPackageManager();
		PackageInfo pi;
		try {
			pi = pm.getPackageInfo(bundleId, 0);
			appVersion = pi.versionName;
			appBundleVersion = pi.versionCode;
		} catch (NameNotFoundException e) {
			DebugUtil.LogException(TAG, e);
		}
		ApplicationInfo ai;
		try {
			ai = pm.getApplicationInfo(bundleId, PackageManager.GET_META_DATA);
			appMinVersion = ai.metaData.getString("AppMinVersion");
			isAppHocMode = ai.metaData.getBoolean("AppHoc", false);
		} catch (Exception e) {
			DebugUtil.LogException(TAG, e);
		}
	}

	// private
	private String initUDID() {
		androidId = Settings.Secure.getString(AppActivity.getGameActivity().getContentResolver(),
				Settings.Secure.ANDROID_ID);
		androidId = androidId == null ? "" : androidId;
		return new UUID(androidId.hashCode(), deviceId.hashCode()).toString();
	}

	private String initDeviceID() {
		TelephonyManager tm = (TelephonyManager) AppActivity.getGameActivity()
				.getSystemService(Context.TELEPHONY_SERVICE);
		String deviceId = tm.getDeviceId();
		return deviceId == null ? "" : deviceId;
	}

	public String getUdid() {
		DebugUtil.LogDebug(TAG, "DeviceInfo getUdid:" + udid);
		return udid;
	}

	public String getOsVersion() {
		return osVersion;
	}

	public String getAppVersion() {
		return appVersion;
	}

	public int getAppBundleVersion() {
		return appBundleVersion;
	}

	public String getAppName() {
		return appName;
	}

	public String getBundleId() {
		return bundleId;
	}

	public String getDeviceModel() {
		return deviceModel;
	}

	public String getAppMinVersion() {
		return appMinVersion;
	}

	public boolean isAppHocMode() {
		DebugUtil.LogDebug(TAG, "DeviceInfo isAppHocMode:" + isAppHocMode);
		return isAppHocMode;
	}

	private static long getTotalMem() {
		long mTotal;
		String path = "/proc/meminfo";
		String content = null;
		BufferedReader br = null;
		try {
			br = new BufferedReader(new FileReader(path), 8);
			String line;
			if ((line = br.readLine()) != null) {
				content = line;
			}
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} finally {
			if (br != null) {
				try {
					br.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
		// beginIndex
		int begin = content.indexOf(':');
		// endIndex
		int end = content.indexOf('k');
		// 截取字符串信息

		content = content.substring(begin + 1, end).trim();
		mTotal = Integer.parseInt(content);
		DebugUtil.LogDebug(TAG, "getTotalMem:"+mTotal);
		return mTotal;
	}

	public boolean isLowMemoryDevice() {
		return getTotalMem()/1024 < 1024;
	}
}
