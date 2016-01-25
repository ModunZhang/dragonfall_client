package com.batcatstudio.dragonfall.google.gcm;

import org.cocos2dx.lua.AppActivity;

import com.batcatstudio.dragonfall.notifications.NotificationUtils;
import com.batcatstudio.dragonfall.utils.DebugUtil;
import com.google.android.gcm.GCMBaseIntentService;
import com.google.android.gcm.GCMConstants;
import com.google.android.gcm.GCMRegistrar;

import android.content.Context;
import android.content.Intent;
@SuppressWarnings("deprecation")
public class GCMIntentService extends GCMBaseIntentService {
	private static final String TAG = "GCMIntentService";
	private static final boolean DEBUG = true;
	public static boolean isAlertMute = false;

	public GCMIntentService() {
		super(GCMUtils.SENDER_ID);
	}

	@Override
	protected void onRegistered(Context context, String registrationId) {
		if (DEBUG) {
			DebugUtil.LogInfo(TAG, "Device registered: regId = " + registrationId);
		}
		// Successfully registered on google server, now need to register on our own server
		GCMUtils.register(context, registrationId);
	}

	@Override
	protected void onUnregistered(Context context, String registrationId) {
		if (DEBUG) {
			DebugUtil.LogInfo(TAG, "onUnregistered: Device unregistered");
		}
		if (GCMRegistrar.isRegisteredOnServer(context)) {
			GCMUtils.unregister(context, registrationId);
		} else {
			// This callback results from the call to unregister made on
			// GCMUtils when the registration to the server failed.
			if (DEBUG) {
				DebugUtil.LogInfo(TAG, "Ignoring unregister callback");
			}
		}
	}

	@Override
	protected void onMessage(Context context, Intent intent) {
		String msg = intent.getStringExtra("message");
		if (DEBUG) {
			DebugUtil.LogDebug(TAG, "onMessage---->"+msg);
		}
		
		NotificationUtils.generalGCMNotification(this, msg);
		
	}

	@Override
	protected void onDeletedMessages(Context context, int total) {
		if (DEBUG) {
			DebugUtil.LogInfo(TAG, "Received deleted messages notification, deleted count: " + total);
		}
	}

	@Override
	public void onError(Context context, String errorId) {
		if (DEBUG) {
			DebugUtil.LogErr(TAG, "Received error: " + errorId);
		}
		if (isAlertMute) {
			return;
		}

		// Ask user to change account config to enable remote push
		if (GCMConstants.ERROR_ACCOUNT_MISSING.equals(errorId)) {
			// There is no Google account on the phone, ask the user to open the account manager and add a Google account
			AppActivity.getGameActivity().runOnUiThread(new Runnable() {
				
				@Override
				public void run() {
					AppActivity.getGameActivity().showDialog(AppActivity.AppActivityDialog.DIALOG_GCM_ERROR_ACCOUNT_MISSING.ordinal());
				}
			});

		} else if (GCMConstants.ERROR_AUTHENTICATION_FAILED.equals(errorId)) {
			// Bad Google Account password. ask user to enter his/her Google Account password, and let the user retry manually later.
				AppActivity.getGameActivity().runOnUiThread(new Runnable() {
				@Override
				public void run() {
					AppActivity.getGameActivity().showDialog(AppActivity.AppActivityDialog.DIALOG_GCM_ERROR_AUTHENTICATION_FAILED.ordinal());
				}
			});
		}

	}

	@Override
	protected boolean onRecoverableError(Context context, String errorId) {
		if (DEBUG) {
			DebugUtil.LogInfo(TAG, "Received recoverable error: " + errorId);
		}
		return super.onRecoverableError(context, errorId);
	}

}
