package com.batcatstudio.dragonfall.utils;

import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lua.AppActivity;

import com.batcatstudio.dragonfall.data.DataHelper;

public class LaunchHelper {
	
	private static String TAG = "LaunchHelper";
	private static native void nativeInitLuaEngine(String path); 
	
	//检查是否首次安装
	public static void checkGameFirstInstall(){
		AppActivity.getGameActivity().setKeepScreenOn(true);
		if(DataHelper.isAppVersionExpired() || !DataHelper.hasInstallUnzip()) { //需要解压
			DebugUtil.LogDebug(TAG, "unzip resources");
			int flag = getInstallFlag();
			if(flag < 0) {
				//error
				DebugUtil.LogDebug(TAG, "check space error");
				AppActivity.getGameActivity().runOnUiThread(new Runnable() {
					@Override
					public void run() {
						AppActivity.getGameActivity().showDialog(AppActivity.AppActivityDialog.DIALOG_UNZIP_SPACE_NOT_ENOUGH.ordinal());
					}
				});
				
			}else {
				DataHelper.unzipGameResource(flag == 0);
			}
		}else {
			DebugUtil.LogDebug(TAG, "launch game");
			initNativeLuaEngine();
		}
	}
	
	// -1 - >none ,0 -> sdcard ,1 ->mobile
	private static int getInstallFlag() {
		int intallFlag = -1; 
		if(!DataHelper.isExternalStorageMounted() || !DataHelper.isExternalStorageSpaceEnough()) {
			if(DataHelper.isInternalSpaceEnough()) {
				intallFlag = 1;
			}
		}else {
			intallFlag = 0;
		}
		return intallFlag;
	}
	
	//启动游戏lua part
	public static void initNativeLuaEngine() {
		DataHelper.preInitActivityData();
		DebugUtil.LogDebug(TAG, "-- game bundle path:"+Cocos2dxHelper.getCocos2dxBundlePath());
		Cocos2dxHelper.runOnGLThread(new Runnable() {	
			@Override
			public void run() {
				nativeInitLuaEngine(Cocos2dxHelper.getCocos2dxBundlePath());
			}
		});
		AppActivity.getGameActivity().setGameLaunched(true); 
		AppActivity.getGameActivity().setKeepScreenOn(false);
	}
	
	public static boolean isGameLaunched() {
		return AppActivity.getGameActivity().isGameLaunched();
	}
	
}
