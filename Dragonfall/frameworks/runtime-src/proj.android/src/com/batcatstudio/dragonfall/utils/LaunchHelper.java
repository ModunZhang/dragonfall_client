package com.batcatstudio.dragonfall.utils;

import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lua.AppActivity;

import com.batcatstudio.dragonfall.data.DataHelper;
@SuppressWarnings("deprecation")
public class LaunchHelper {
	
	private static String TAG = "LaunchHelper";
	private static native void nativeInitLuaEngine(String path); 
	//define the location of resources to extra.
	private enum UnzipLocation { None, ExternalStorage, InternalSpace }
	//check the device if player install the game at fist time
	public static void checkGameFirstInstall(){
		AppActivity.getGameActivity().setKeepScreenOn(true);
		if(DataHelper.isAppVersionExpired() || !DataHelper.hasInstallUnzip()) { //需要解压
			DebugUtil.LogDebug(TAG, "checkGameFirstInstall:need unzip dragonfall.zip");
			UnzipLocation location = getUnzipLocation();
			if(location == UnzipLocation.None) {
				AppActivity.getGameActivity().runOnUiThread(new Runnable() {
					@Override
					public void run() {
						AppActivity.getGameActivity().showDialog(AppActivity.AppActivityDialog.DIALOG_UNZIP_SPACE_NOT_ENOUGH.ordinal());
					}
				});
				
			}else {
				DataHelper.unzipGameResource(location == UnzipLocation.ExternalStorage);
			}
		}else {
			initNativeLuaEngine();
		}
	}
	
	private static UnzipLocation getUnzipLocation() {
		UnzipLocation location = UnzipLocation.None; 
		if(!DataHelper.isExternalStorageMounted() || !DataHelper.isExternalStorageSpaceEnough()) {
			if(DataHelper.isInternalSpaceEnough()) {
				location = UnzipLocation.InternalSpace;
			}
		}else {
			location = UnzipLocation.ExternalStorage;
		}
		return location;
	}
	
	//启动游戏lua part
	public static void initNativeLuaEngine() {
		DataHelper.preInitActivityData();
		DebugUtil.LogDebug(TAG, "Game Bundle Path:"+Cocos2dxHelper.getCocos2dxBundlePath());
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
