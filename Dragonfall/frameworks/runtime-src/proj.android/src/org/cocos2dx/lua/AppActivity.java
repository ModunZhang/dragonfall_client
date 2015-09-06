/****************************************************************************
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2011      Zynga Inc.
Copyright (c) 2013-2014 Chukong Technologies Inc.
 
http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package org.cocos2dx.lua;

import java.util.ArrayList;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lib.Cocos2dxLuaJavaBridge;

import com.batcatstudio.dragonfall.R;
import com.batcatstudio.dragonfall.data.DataHelper;
import com.batcatstudio.dragonfall.google.billing.StoreKit;
import com.batcatstudio.dragonfall.google.gcm.GCMIntentService;
import com.batcatstudio.dragonfall.google.gcm.GCMUtils;
import com.batcatstudio.dragonfall.notifications.NotificationUtils;
import com.batcatstudio.dragonfall.sdk.MarketSDK;
import com.batcatstudio.dragonfall.utils.CommonUtils;
import com.batcatstudio.dragonfall.utils.LaunchHelper;

import android.app.AlertDialog;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.Settings;
import android.view.KeyEvent;
import android.view.WindowManager;


public class AppActivity extends Cocos2dxActivity{

    static String hostIPAdress = "0.0.0.0";
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        gameActivity = this;
        
        if(nativeIsLandScape()) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
        } else {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT);
        }
        
        //2.Set the format of window
        
        // Check the wifi is opened when the native is debug.
        if(nativeIsDebug())
        {
            getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON, WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            if(!isNetworkConnected())
            {
                AlertDialog.Builder builder=new AlertDialog.Builder(this);
                builder.setTitle("Warning");
                builder.setMessage("Please open WIFI for debuging...");
                builder.setPositiveButton("OK",new DialogInterface.OnClickListener() {
                    
                    @Override
                    public void onClick(DialogInterface dialog, int which) {
                        startActivity(new Intent(Settings.ACTION_WIFI_SETTINGS));
                        finish();
                        System.exit(0);
                    }
                });

                builder.setNegativeButton("Cancel", null);
                builder.setCancelable(true);
                builder.show();
            }
            hostIPAdress = getHostIpAddress();
        }
        /** Init Java **/
        CommonUtils.getInstance();
		MarketSDK.initSDK();
		GCMUtils.registerGCMService(this);
		StoreKit.init();
		DataHelper.initHelper();
    }
    private boolean isNetworkConnected() {
            ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);  
            if (cm != null) {  
                NetworkInfo networkInfo = cm.getActiveNetworkInfo();  
            ArrayList networkTypes = new ArrayList();
            networkTypes.add(ConnectivityManager.TYPE_WIFI);
            try {
                networkTypes.add(ConnectivityManager.class.getDeclaredField("TYPE_ETHERNET").getInt(null));
            } catch (NoSuchFieldException nsfe) {
            }
            catch (IllegalAccessException iae) {
                throw new RuntimeException(iae);
            }
            if (networkInfo != null && networkTypes.contains(networkInfo.getType())) {
                    return true;  
                }  
            }  
            return false;  
        } 
     
    public String getHostIpAddress() {
        WifiManager wifiMgr = (WifiManager) getSystemService(WIFI_SERVICE);
        WifiInfo wifiInfo = wifiMgr.getConnectionInfo();
        int ip = wifiInfo.getIpAddress();
        return ((ip & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF) + "." + ((ip >>>= 8) & 0xFF));
    }
    
    public static String getLocalIpAddress() {
        return hostIPAdress;
    }
    
    private static native boolean nativeIsLandScape();
    private static native boolean nativeIsDebug();
    
    /************************Extension Android************************/
    
    @Override
	protected void onResume() {
		super.onResume();
		MarketSDK.onResume(this);
		NotificationUtils.stopLocalPushService();
		onEnterForeground();
	}

	@Override
	protected void onPause() {
		super.onPause();
		MarketSDK.onPause(this);
	}

	@Override
	protected void onStop() {
		NotificationUtils.startLocalPushService();
		onEnterBackground();
		super.onStop();
	}
	@Override
	protected void onRestart() {
		super.onRestart();
	}
	@Override
	protected void onDestroy() {
		StoreKit.purge();
		super.onDestroy();
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if(StoreKit.handleActivityResult(requestCode, resultCode, data)) {
			super.onActivityResult(requestCode, resultCode, data);
		}
	}
	/************************Dialog************************/
    
    public enum AppActivityDialog {
		//GCM
		DIALOG_GCM_ERROR_ACCOUNT_MISSING,//没有绑定账号
		DIALOG_GCM_ERROR_AUTHENTICATION_FAILED,//账号验证失败
		//IAP
		DIALOG_PAYMENT_PURCHASED,//购买成功
		//Unzip Resources
		DIALOG_UNZIP_SPACE_NOT_ENOUGH,//解压空间不足
		DIALOG_UNZIP_FAILED,
		DAILOG_EXIT_GAME,
	}
	
	public enum AppActivityMessage {
		LOADING_UNZIP_SHOW,//解压loading
		LOADING_UNZIP_SET_PROGRESS,
		LOADING_UNZIP_SUCCESS,
	}
	

	public static AppActivity gameActivity = null;
	
	public static AppActivity getGameActivity() {
		return gameActivity;
	}
	
	private boolean gameLaunched = false;
	
	public boolean isEnterBackground = false;
	
	private ProgressDialog loadingDialog = null;
	
	public static Handler gameHandler = new Handler() {
		@Override
		public void handleMessage(Message msg) {
			AppActivityMessage msg_type = AppActivityMessage.values()[msg.what];
			switch (msg_type) {
			case LOADING_UNZIP_SHOW:
				gameActivity.showLoadingDialog();
				break;
			case LOADING_UNZIP_SET_PROGRESS:
				gameActivity.setLoadingDialogProgress(msg.arg1);
				break;
			case LOADING_UNZIP_SUCCESS:
				gameActivity.dismissLoadingDialog();
				System.gc();
				LaunchHelper.initNativeLuaEngine();
				break;
			default:
				break;
			}
			super.handleMessage(msg);
		}
	};
	
	/************************Dialog************************/
	@Override
	protected Dialog onCreateDialog(int id, Bundle args) {
		AppActivityDialog dialogEnum = AppActivityDialog.values()[id];
		switch (dialogEnum) {
		case DIALOG_PAYMENT_PURCHASED:
			return new AlertDialog.Builder(this).setMessage(R.string.dialog_msg_payment_purchased).setPositiveButton(R.string.ok, null)
					.setCancelable(false).create();
		case DIALOG_GCM_ERROR_ACCOUNT_MISSING:
			return createGoogleGCMErrorDialog(AppActivityDialog.DIALOG_GCM_ERROR_ACCOUNT_MISSING.ordinal(), R.string.dialog_msg_gcm_error_account_missing);
		case DIALOG_GCM_ERROR_AUTHENTICATION_FAILED:
			return createGoogleGCMErrorDialog(AppActivityDialog.DIALOG_GCM_ERROR_AUTHENTICATION_FAILED.ordinal(), R.string.dialog_msg_gcm_error_authentication_failed);
		case DIALOG_UNZIP_SPACE_NOT_ENOUGH:
			dismissLoadingDialog();
			return createUnzipFailedDialog(R.string.dialog_msg_sd_space_not_enough);
		case DIALOG_UNZIP_FAILED:
			dismissLoadingDialog();
			return createUnzipFailedDialog(R.string.dialog_msg_unzip_failed);
		case DAILOG_EXIT_GAME:
			return new AlertDialog.Builder(this).setMessage(R.string.exit_game_title)
					.setPositiveButton(R.string.yes, getFinishGameBtnListener()).setNegativeButton(R.string.no, null).create();
		default:
			return super.onCreateDialog(id, args);
		}
	}
	
	private AlertDialog createGoogleGCMErrorDialog(final int tag, int msgId) {
		return new AlertDialog.Builder(this).setTitle(R.string.dialog_title_gcm_error).setMessage(msgId)
				.setPositiveButton(R.string.ok, getGCMPositiveBtnListener(tag))
				.setNegativeButton(R.string.remind_me_later, getGCMNegativeBtnListener()).setCancelable(false).create();
	}
	
	private DialogInterface.OnClickListener getGCMPositiveBtnListener(final int tag) {
		return new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				Intent intent = null;
				AppActivityDialog dialogEnum = AppActivityDialog.values()[tag];
				switch (dialogEnum) {
				case DIALOG_GCM_ERROR_ACCOUNT_MISSING:
					intent = new Intent(Settings.ACTION_ADD_ACCOUNT);
					break;
				case DIALOG_GCM_ERROR_AUTHENTICATION_FAILED:
					intent = new Intent(Settings.ACTION_SYNC_SETTINGS);
					break;
				default:
					intent = new Intent(Settings.ACTION_SETTINGS);
					break;
				}
				AppActivity.this.startActivity(intent);
			}
		};
	}

	private DialogInterface.OnClickListener getGCMNegativeBtnListener() {
		return new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				GCMIntentService.isAlertMute = true;
			}
		};
	}
	
	//loading

	private void showLoadingDialog() {
		loadingDialog = new ProgressDialog(this);
		loadingDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
		loadingDialog.setTitle(R.string.dialog_title_unzipping_file);
		setLoadingDialogProgress(0);
		loadingDialog.setCancelable(false);
		loadingDialog.show();
	}

	private void setLoadingDialogProgress(int percent) {
		if (loadingDialog != null) {
			loadingDialog.setMessage(String.format(getString(R.string.dialog_msg_unzipping_file), percent));
		}
	}

	private void dismissLoadingDialog() {
		if (loadingDialog != null) {
			loadingDialog.dismiss();
			loadingDialog = null;
		}
	}
	
	private AlertDialog createUnzipFailedDialog(int msgId) {
		return new AlertDialog.Builder(this).setTitle(R.string.sorry).setIcon(android.R.drawable.stat_notify_sdcard_usb).setMessage(msgId)
				.setPositiveButton(R.string.ok, getFinishGameBtnListener()).setCancelable(false).create();
	}
	
	private DialogInterface.OnClickListener getFinishGameBtnListener() {
		return new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				AppActivity.this.finish();
				System.exit(0);
			}
		};
	}
	
	/************************Back Button************************/
    
	@Override  
	public boolean dispatchKeyEvent(KeyEvent event) {  
	  if (event.getKeyCode() == KeyEvent.KEYCODE_BACK) {  
	    if (event.getAction() == KeyEvent.ACTION_DOWN && event.getRepeatCount() == 0) {  
	    	if(isGameLaunched())
	    	{
	    		showDialog(AppActivityDialog.DAILOG_EXIT_GAME.ordinal());
	    	}
	    }  
	    return true;  
	  }  
	  return super.dispatchKeyEvent(event);  
	} 
	
	/************************Methods************************/

	public boolean isGameLaunched() {
		return gameLaunched;
	}

	public void setGameLaunched(boolean gameLaunched) {
		this.gameLaunched = gameLaunched;
	}
	
	private void onEnterForeground() {
		if(!isEnterBackground){
			return;
		}
		isEnterBackground = false;
		if(isGameLaunched()){
			Runnable callLua = new Runnable() {
				@Override
				public void run() {
					 if(isGameLaunched()) {
					 	 Cocos2dxHelper.runOnGLThread(new Runnable() {
					 		@Override
					 		public void run() {
					 			Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("AndroidGlobalCallback","onEnterForeground");
					 		}
					 	});
					  }
				}
			};
			gameHandler.postDelayed(callLua, 500);
		}
	}

	private void onEnterBackground() {
		if(isEnterBackground){
			return;
		}
		isEnterBackground = true;
		if(isGameLaunched()){
			Runnable callLua = new Runnable() {
				@Override
				public void run() {
					if(isGameLaunched()) {
						 	Cocos2dxHelper.runOnGLThread(new Runnable() {
						 		@Override
						 		public void run() {
						 			Cocos2dxLuaJavaBridge.callLuaGlobalFunctionWithString("AndroidGlobalCallback","onEnterBackground");
						 		}
						 	});
					}
				}
			};
			gameHandler.postDelayed(callLua, 500);
		}
	}
}
