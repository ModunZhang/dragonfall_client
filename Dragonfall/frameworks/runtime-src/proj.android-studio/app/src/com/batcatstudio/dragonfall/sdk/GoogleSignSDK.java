package com.batcatstudio.dragonfall.sdk;
//#ifdef CC_USE_GOOGLE_LOGIN
import org.cocos2dx.lua.AppActivity;
import com.batcatstudio.dragonfall.utils.DebugUtil;
import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GoogleApiAvailability;
import com.google.android.gms.common.Scopes;
import com.google.android.gms.common.api.GoogleApiClient;
import com.google.android.gms.common.api.GoogleApiClient.ConnectionCallbacks;
import com.google.android.gms.common.api.GoogleApiClient.OnConnectionFailedListener;
import com.google.android.gms.common.api.Scope;
import com.google.android.gms.plus.Plus;
import com.google.android.gms.plus.model.people.Person;

import android.app.Activity;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentSender;
import android.os.Bundle;
//#endif
public class GoogleSignSDK 
//#ifdef CC_USE_GOOGLE_LOGIN
implements ConnectionCallbacks, OnConnectionFailedListener 
//#endif
{
//#ifdef CC_USE_GOOGLE_LOGIN
	private static GoogleSignSDK m_instance = null;
	private static String TAG = "GoogleSignSDK";

	/* RequestCode for resolutions involving sign-in */
	private static final int RC_SIGN_IN = 1313;

	/* Keys for persisting instance variables in savedInstanceState */
	public  static final String KEY_IS_RESOLVING = "is_resolving";
	public  static final String KEY_SHOULD_RESOLVE = "should_resolve";

	/* Client for accessing Google APIs */
	private GoogleApiClient mGoogleApiClient;

	/* Is there a ConnectionResult resolution in progress? */
	private boolean mIsResolving = false;

	/* Should we automatically resolve ConnectionResults when possible? */
	private boolean mShouldResolve = false;
	
	private Person mLoginedPersion = null;

	// methods for Lua
	public static void Login(){
		AppActivity.getGameActivity().runOnUiThread(new Runnable() {
			@Override
			public void run() {
				getInstance().beginGoogleLogin();
			}
		});
	}
	
	public static boolean IsAuthenticated(){
		return getInstance().getLoginPersion() != null;
	}
	
	public static String GetGoogleUserName(){
		if(IsAuthenticated()){
			return getInstance().getLoginPersion().getDisplayName();
		}
		return "";
	}
	
	public static String GetGoogleId(){
		if(IsAuthenticated()){
			return getInstance().getLoginPersion().getId();
		}
		return "";
	}
	
	// native methods
	private static native void GoogleSignEvent(String eventName,String userName,String id);
	// methods for AppActivity

	public Person getLoginPersion(){
		return mLoginedPersion;
	}
	
	public boolean isResolving() {
		return mIsResolving;
	}
	
	public boolean isShouldResolve(){
		return mShouldResolve;
	}
	
	public static GoogleSignSDK getInstance() {
		if (null == m_instance) {
			m_instance = new GoogleSignSDK();
		}
		return m_instance;
	}

	public void Initialize(Bundle savedInstanceState) {
		if (savedInstanceState != null) {
			mIsResolving = savedInstanceState.getBoolean(KEY_IS_RESOLVING);
			mShouldResolve = savedInstanceState.getBoolean(KEY_SHOULD_RESOLVE);
		}
		mGoogleApiClient = new GoogleApiClient.Builder(AppActivity.getGameActivity()).addConnectionCallbacks(this)
				.addOnConnectionFailedListener(this).addApi(Plus.API).addScope(new Scope(Scopes.PROFILE))
				.addScope(new Scope(Scopes.EMAIL)).build();
	}

	private static void CallLuaCallBack(final String eventName,final String userName,final String id)
	{
		AppActivity.getGameActivity().runOnGLThread(new Runnable() {
			@Override
			public void run() {
				GoogleSignEvent(eventName, userName, id);
			}
		});
	}
	
	
	public void onActivityStart(Activity activity) {
		mGoogleApiClient.connect();
	}

	public void onActivityStop(Activity activity) {
		mGoogleApiClient.disconnect();
	}

	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode == RC_SIGN_IN) {
			// If the error resolution was not successful we should not resolve
			// further.
			if (resultCode != AppActivity.RESULT_OK) {
				mShouldResolve = false;
				CallLuaCallBack("login_exception","","");
				DebugUtil.LogErr("GoogleSign", "fuck RC_SIGN_IN resultCode != RESULT_OK");
			}

			mIsResolving = false;
			mGoogleApiClient.connect();
		}
	}

	// Google methods
	@Override
	public void onConnectionFailed(ConnectionResult connectionResult) {
		if (!mIsResolving && mShouldResolve) {
			if (connectionResult.hasResolution()) {
				try {
					connectionResult.startResolutionForResult(AppActivity.getGameActivity(), RC_SIGN_IN);
					mIsResolving = true;
				} catch (IntentSender.SendIntentException e) {
					DebugUtil.LogErr(TAG, "fuck hasResolution");
					CallLuaCallBack("login_exception","","");
					mIsResolving = false;
					mGoogleApiClient.connect();
				}
			} else {
				DebugUtil.LogErr(TAG, "fuck !connectionResult.hasResolution()");
				CallLuaCallBack("login_exception","","");
				showErrorDialog(connectionResult);
			}
		}

	}

	@Override
	public void onConnected(Bundle arg0) {
		DebugUtil.LogDebug(TAG, "onConnected");
		mShouldResolve = false;
		getGoogleAccountInfo();
	}

	@Override
	public void onConnectionSuspended(int arg0) {
		// fuck
		DebugUtil.LogErr(TAG, "fuck onConnectionSuspended");
		CallLuaCallBack("login_exception","","");
	}

	private void beginGoogleLogin() {
		// User clicked the sign-in button, so begin the sign-in process and
		// automatically
		// attempt to resolve any errors that occur.
		// we want to remove old account

		if (mGoogleApiClient.isConnected()) {
			mLoginedPersion = null;
			Plus.AccountApi.clearDefaultAccount(mGoogleApiClient);
			Plus.AccountApi.revokeAccessAndDisconnect(mGoogleApiClient);
			mGoogleApiClient.disconnect();
		}
		mShouldResolve = true;
		mGoogleApiClient.connect();
		DebugUtil.LogDebug("GoogleSign", "begin connect");
	}

	private void getGoogleAccountInfo() {
		Person currentPerson = Plus.PeopleApi.getCurrentPerson(mGoogleApiClient);
		if (currentPerson != null) {
			// Show signed-in user's name
			String id = currentPerson.getId();
			DebugUtil.LogDebug(TAG, "Id:" + id);
			mLoginedPersion = currentPerson;
			CallLuaCallBack("login_success",currentPerson.getDisplayName(),currentPerson.getId());
		} else {
			// If getCurrentPerson returns null there is generally some error
			// with the
			// configuration of the application (invalid Client ID, Plus API not
			// enabled, etc).
			DebugUtil.LogErr(TAG, "fuck Client ID");
			CallLuaCallBack("login_exception","","");
		}
	}

	private void showErrorDialog(ConnectionResult connectionResult) {
		GoogleApiAvailability apiAvailability = GoogleApiAvailability.getInstance();
		int resultCode = apiAvailability.isGooglePlayServicesAvailable(AppActivity.getGameActivity());

		if (resultCode != ConnectionResult.SUCCESS) {
			if (apiAvailability.isUserResolvableError(resultCode)) {
				apiAvailability.getErrorDialog(AppActivity.getGameActivity(), resultCode, RC_SIGN_IN,
						new DialogInterface.OnCancelListener() {
							@Override
							public void onCancel(DialogInterface dialog) {
								mShouldResolve = false;
							}
						}).show();
			} else {
				mShouldResolve = false;
			}
		}
	}
//#endif
}
