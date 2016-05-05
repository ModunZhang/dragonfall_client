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
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.provider.Settings;
import android.view.KeyEvent;

import com.batcatstudio.dragonfall.data.DataHelper;
import com.batcatstudio.dragonfall.google.billing.StoreKit;
import com.batcatstudio.dragonfall.google.gcm.GCMIntentService;
import com.batcatstudio.dragonfall.notifications.NotificationUtils;
import com.batcatstudio.dragonfall.sdk.MarketSDK;
import com.batcatstudio.dragonfall.sdk.PayPalSDK;
import com.batcatstudio.dragonfall.utils.CommonUtils;
import com.batcatstudio.dragonfall.utils.LaunchHelper;
import com.xapcn.dragonfall.R;

import org.cocos2dx.lib.Cocos2dxActivity;

import java.util.ArrayList;
//#ifdef CC_USE_FACEBOOK
import com.batcatstudio.dragonfall.sdk.FaceBookSDK;
//#endif
//#ifdef CC_USE_GOOGLE_LOGIN
import com.batcatstudio.dragonfall.sdk.GoogleSignSDK;
//#endif

public class AppActivity extends Cocos2dxActivity
{

    static String hostIPAdress = "0.0.0.0";
//#ifdef CC_USE_GOOGLE_LOGIN
    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        outState.putBoolean(GoogleSignSDK.KEY_IS_RESOLVING, GoogleSignSDK.getInstance().isResolving());
		outState.putBoolean(GoogleSignSDK.KEY_SHOULD_RESOLVE, GoogleSignSDK.getInstance().isShouldResolve());
    }
//#endif

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        gameActivity = this;

        if(nativeIsLandScape()) {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE);
        } else {
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT);
        }
		//we want to use the Material theme above android 5.0
		if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP){
			setTheme(R.style.NewGameTheme);
		}
        /** Init Java Native **/
//#ifdef CC_USE_GOOGLE_LOGIN        
        GoogleSignSDK.getInstance().Initialize(savedInstanceState);
//#endif
        CommonUtils.getInstance();
		MarketSDK.initSDK();
		StoreKit.init();
		PayPalSDK.getInstance().init(this);
//#ifdef CC_USE_FACEBOOK
		FaceBookSDK.init();
//#endif
		DataHelper.initHelper();
    }
    
    @SuppressWarnings("unchecked")
	private boolean isNetworkConnected() {
            ConnectivityManager cm = (ConnectivityManager) getSystemService(Context.CONNECTIVITY_SERVICE);  
            if (cm != null) {  
                NetworkInfo networkInfo = cm.getActiveNetworkInfo();  
            @SuppressWarnings("rawtypes")
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
		fullBackground = false;
		super.onResume();
		MarketSDK.onResume(this);
		NotificationUtils.stopLocalPushService();
	}

	@Override
	protected void onPause() {
		MarketSDK.onPause(this);
		super.onPause();
	}

	@Override
	protected void onStart() {
		super.onStart();
//#ifdef CC_USE_GOOGLE_LOGIN
		GoogleSignSDK.getInstance().onActivityStart(this);
//#endif
	}
	@Override
	protected void onStop() {
		fullBackground = true;
//#ifdef CC_USE_GOOGLE_LOGIN
		GoogleSignSDK.getInstance().onActivityStop(this);
//#endif
		NotificationUtils.startLocalPushService();

		super.onStop();
		
	}
	@Override
	protected void onRestart() {
		super.onRestart();
	}
	@Override
	protected void onDestroy() {
		releaseData();
		super.onDestroy();
		//如果Activity被摧毁,杀掉游戏进程,被重新创建时游戏会重启
		CommonUtils.killProcess();
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		if(StoreKit.handleActivityResult(requestCode, resultCode, data)) {
			super.onActivityResult(requestCode, resultCode, data);
		}
//#ifdef CC_USE_GOOGLE_LOGIN
		GoogleSignSDK.getInstance().onActivityResult(requestCode, resultCode, data);
//#endif
		PayPalSDK.getInstance().onActivityResult(requestCode, resultCode, data);
//#ifdef CC_USE_FACEBOOK
		FaceBookSDK.onActivityResult(this, requestCode, resultCode, data);
//#endif
	}


	private void releaseData(){
		StoreKit.purge();
		PayPalSDK.getInstance().destroy(this);
//#ifdef CC_USE_FACEBOOK
		FaceBookSDK.onDestroy();
//#endif
		gameHandler = null;
		gameActivity = null;
		System.gc();
	}
	/************************Dialog************************/
    
    public enum AppActivityDialog {
		//GCM
		DIALOG_GCM_ERROR_ACCOUNT_MISSING,// There is no Google account on the phone, ask the user to open the account manager and add a Google account
		DIALOG_GCM_ERROR_AUTHENTICATION_FAILED,// Bad Google Account password. ask user to enter his/her Google Account password, and let the user retry manually later.
		//IAP
		DIALOG_PAYMENT_PURCHASED,//Iap success
		//Unzip Resources
		DIALOG_UNZIP_SPACE_NOT_ENOUGH,//not enough space to unzip the game resources
		DIALOG_UNZIP_FAILED,
		DAILOG_EXIT_GAME,
	}
	
	public enum AppActivityMessage {
		LOADING_UNZIP_SHOW,//the loading of unzip resources 
		LOADING_UNZIP_SET_PROGRESS,
		LOADING_UNZIP_SUCCESS,
		LOADING_DELETE_SHOW,
		LOADING_DELETE_SUCCESS,

	}
	

	public static AppActivity gameActivity = null;
	
	public static AppActivity getGameActivity() {
		return gameActivity;
	}
	
	private boolean gameLaunched = false;

	public  boolean isFullBackground() {
		return fullBackground;
	}

	public static boolean fullBackground = false;
	
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
					LaunchHelper.runNativeLuaEngine();
					break;
				case LOADING_DELETE_SHOW:
					gameActivity.showDeleteLoadingDialog();
					break;
				case LOADING_DELETE_SUCCESS:
					gameActivity.dismissLoadingDialog();
					LaunchHelper.runNativeLuaEngine();
					break;
				default:
					break;
				}
			super.handleMessage(msg);
		}
	};
	
	/************************Dialog************************/
	@SuppressWarnings("deprecation")
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

	private void showDeleteLoadingDialog() {
		loadingDialog = new ProgressDialog(this);
		loadingDialog.setProgressStyle(ProgressDialog.STYLE_SPINNER);
		loadingDialog.setTitle(R.string.dialog_title_delete_file);
		loadingDialog.setMessage(getString(R.string.dialog_msg_delete_file));
		loadingDialog.setCancelable(false);
		loadingDialog.show();
	}

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
    
	@SuppressWarnings("deprecation")
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

}
