package com.batcatstudio.dragonfall.google.gcm;

import com.batcatstudio.dragonfall.utils.DebugUtil;
import com.google.android.gcm.GCMRegistrar;

import android.content.Context;
import android.os.AsyncTask;

public class GCMUtils {
	private static final String TAG = "GCMUtils";
	private static final boolean DEBUG = true;
	private static final boolean DEBUG_CHECK_MANIFEST = true;
	public static final String SENDER_ID = "841456299792";
	

	public static String getRegisterId() {
		if(mContext!=null) {
			return GCMRegistrar.getRegistrationId(mContext);
		}
		return "";
	}

	private static AsyncTask<Void, Void, Void> mRegisterTask = null;
	private static Context mContext = null;

	public static void registerGCMService(final Context context) {
		mContext = context;
		try {
			// Make sure the device has the proper dependencies.
			GCMRegistrar.checkDevice(context);
			// Make sure the manifest was properly set - comment out this line
			if (DEBUG_CHECK_MANIFEST) {
				GCMRegistrar.checkManifest(context);
			}

			final String regId = GCMRegistrar.getRegistrationId(context);
			if (regId.equals("")) {
				if (DEBUG) {
					DebugUtil.LogDebug(TAG, "GCM Service not registered, start to register");
				}
				// Automatically registers application on startup.
				GCMRegistrar.register(context, SENDER_ID);
			} else {
				if (DEBUG) {
					DebugUtil.LogDebug(TAG, "GCM Service already registered, registerId: " + regId);
				}
				// Device is already registered on GCM, check server.
				if (GCMRegistrar.isRegisteredOnServer(context)) {
					if (DEBUG) {
						DebugUtil.LogDebug(TAG, "GCM Service has saved on our server");
					}
					// Skips registration.
				} else {
					if (DEBUG) {
						DebugUtil.LogDebug(TAG, "GCM Service hasn't saved on our server, start to register on our server");
					}
					// Try to register again, but not in the UI thread.
					// It's also necessary to cancel the thread onDestroy(),
					// hence the use of AsyncTask instead of a raw thread.
					mRegisterTask = new AsyncTask<Void, Void, Void>() {
						@Override
						protected Void doInBackground(Void... params) {
							boolean registered = register(context, regId);
							// At this point all attempts to register with the app
							// server failed, so we need to unregister the device
							// from GCM - the app will try to register again when
							// it is restarted. Note that GCM will send an
							// unregistered callback upon completion, but
							// GCMIntentService.onUnregistered() will ignore it.
							if (!registered) {
								GCMRegistrar.unregister(context);
							}
							return null;
						}

						@Override
						protected void onPostExecute(Void result) {
							mRegisterTask = null;
						}

					};
					mRegisterTask.execute(null, null, null);
				}
			}

		} catch (Exception e) {
			DebugUtil.LogException(TAG, e);
		}
	}

	/**
	 * Register this account/device pair within the server.
	 * 
	 * @return whether the registration succeeded or not.
	 */
	public static boolean register(final Context context, final String regId) {
		GCMRegistrar.setRegisteredOnServer(context, true);
		return true;
	}

	/**
	 * Unregister this account/device pair within the server.
	 */
	public static void unregister(final Context context, final String regId) {
		GCMRegistrar.setRegisteredOnServer(context, false);
	}

	public static void purge() {
		if (mRegisterTask != null) {
			mRegisterTask.cancel(true);
			mRegisterTask = null;
		}
		GCMRegistrar.onDestroy(mContext);
		mContext = null;
	}

}
