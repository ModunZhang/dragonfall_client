package com.batcatstudio.dragonfall.sdk;

import com.batcatstudio.dragonfall.utils.DebugUtil;
import org.cocos2dx.lua.AppActivity;
import android.app.Activity;
import android.content.Intent;

//#ifdef CC_USE_FACEBOOK
import java.util.Arrays;
import com.facebook.AccessToken;
import com.facebook.CallbackManager;
import com.facebook.FacebookCallback;
import com.facebook.FacebookException;
import com.facebook.FacebookSdk;
import com.facebook.Profile;
import com.facebook.ProfileTracker;
import com.facebook.login.LoginBehavior;
import com.facebook.login.LoginManager;
import com.facebook.login.LoginResult;
import com.facebook.share.model.GameRequestContent;
import com.facebook.share.widget.GameRequestDialog;
//#endif


public class FaceBookSDK {
	//native
	private static native void initJNI();
	private static native void FaceBookEvent(String eventName,String fbUserName,String fbUserId);
	private static String TAG = "FaceBookSDK";
//#ifdef CC_USE_FACEBOOK
	private static CallbackManager callbackManager = null;
	private static ProfileTracker profileTracker;
	private static GameRequestDialog gameRequestDialog;
//#endif
	//method
	public static void init()
	{
		//#ifdef CC_USE_FACEBOOK
		initJNI();
		//#endif
	}


	public static void Initialize()
	{
//#ifdef CC_USE_FACEBOOK
	AppActivity.getGameActivity().runOnUiThread(new Runnable() {
		@Override
		public void run() {
			InitializeAction();
		}
	});
//#endif
	}


	public static void InitializeAction()
	{
//#ifdef CC_USE_FACEBOOK
		FacebookSdk.sdkInitialize(AppActivity.getGameActivity().getApplicationContext());
        DebugUtil.LogInfo(TAG,"Profile:"+Profile.getCurrentProfile());
        DebugUtil.LogInfo(TAG,"AccessToken:"+AccessToken.getCurrentAccessToken());
        callbackManager = CallbackManager.Factory.create();
        profileTracker = new ProfileTracker() {
            @Override
            protected void onCurrentProfileChanged(Profile oldProfile, Profile currentProfile) {
            	DebugUtil.LogInfo(TAG,"onCurrentProfileChanged:"+Profile.getCurrentProfile());
            	CallLuaCallBack("login_success",currentProfile.getName(),currentProfile.getId());
            }
        };
        LoginManager.getInstance().setLoginBehavior(LoginBehavior.SUPPRESS_SSO);
        LoginManager.getInstance().registerCallback(callbackManager,
                new FacebookCallback<LoginResult>() {
                    @Override
                    public void onSuccess(LoginResult loginResult) {
                    	DebugUtil.LogInfo(TAG,"onSuccess:"+loginResult);
                    	if(AccessToken.getCurrentAccessToken()!=null)
                    	{
                    		if(Profile.getCurrentProfile()!=null)
                    		{
                    			DebugUtil.LogDebug(TAG,"login again!");
                    			Profile currentProfile = Profile.getCurrentProfile();
                    			CallLuaCallBack("login_success",currentProfile.getName(),currentProfile.getId());
                    		}
                    	}else
                    	{
                    		DebugUtil.LogDebug(TAG,"login first!");
                    		Profile.fetchProfileForCurrentAccessToken();
                    	}
                    }
                    @Override
                    public void onCancel() {
                        AccessToken.setCurrentAccessToken(null);
                        CallLuaCallBack("login_exception","","");
                    }

                    @Override
                    public void onError(FacebookException exception) {
                    	AccessToken.setCurrentAccessToken(null);
                    	CallLuaCallBack("login_exception","","");
                    }
        });
        gameRequestDialog = new GameRequestDialog(AppActivity.getGameActivity());
        gameRequestDialog.registerCallback(
                callbackManager,
                new FacebookCallback<GameRequestDialog.Result>() {
                    @Override
                    public void onCancel() {
                    	DebugUtil.LogDebug(TAG, "Canceled");
                    }
                    @Override
                    public void onError(FacebookException error) {
                    	DebugUtil.LogDebug(TAG, String.format("Error: %s", error.toString()));
                    }

                    @Override
                    public void onSuccess(GameRequestDialog.Result result) {
                    	DebugUtil.LogDebug(TAG, "Success!");
                    }
                });
        // Ensure that our profile is up to date
        if(AccessToken.getCurrentAccessToken()!=null)
        {
        	if(AccessToken.getCurrentAccessToken().isExpired()){
        		AccessToken.setCurrentAccessToken(null);
        	}else {
        		Profile.fetchProfileForCurrentAccessToken();
        	}
        }
 //#endif
	}
	
	private static void CallLuaCallBack(final String eventName,final String fbUserName,final String fbUserId)
	{
		AppActivity.getGameActivity().runOnGLThread(new Runnable() {
			@Override
			public void run() {
				FaceBookEvent(eventName,fbUserName,fbUserId);
			}
		});
	}

	private static void LoginAction()
	{
		//#ifdef CC_USE_FACEBOOK
		if(!isSDKInitialized()){
			CallLuaCallBack("login_exception","","");
			return;
		}
		LoginManager.getInstance().logInWithReadPermissions(AppActivity.getGameActivity(), Arrays.asList("public_profile"));
		//#endif
	}
	
	public static void Login()
	{
//#ifdef CC_USE_FACEBOOK
		if(!isSDKInitialized()){
			CallLuaCallBack("login_exception","","");
			return;
		}
		AccessToken.setCurrentAccessToken(null);
		AppActivity.getGameActivity().runOnUiThread(new Runnable() {
			@Override
			public void run() {
				LoginAction();
			}
		});
//#endif
	}
	
	public static boolean IsAuthenticated()
	{
//#ifdef CC_USE_FACEBOOK
		return isSDKInitialized()&&Profile.getCurrentProfile()!=null;
//#else
//@		return false;
//#endif
	}
	
	public static String GetFBUserName()
	{
//#ifdef CC_USE_FACEBOOK
		if(Profile.getCurrentProfile()!=null){
			return Profile.getCurrentProfile().getName();
		}
//#endif
		return "";
	}
	
	public static String GetFBUserId()
	{
//#ifdef CC_USE_FACEBOOK
		if(Profile.getCurrentProfile()!=null){
			return Profile.getCurrentProfile().getId();
		}
//#endif
		return "";
	}
	
	public static void onActivityResult(Activity activity,int requestCode, int resultCode, Intent data)
	{
		DebugUtil.LogDebug(TAG, "onActivityResult");
		//#ifdef CC_USE_FACEBOOK
		if(callbackManager != null)
		{
			callbackManager.onActivityResult(requestCode, resultCode, data);
		}
		//#endif
	}
	
	public static void AppInvite(final String title,final String message)
	{
		//#ifdef CC_USE_FACEBOOK
		if(!IsAuthenticated()){
			DebugUtil.LogErr(TAG, "FacebookSDK was not Initialized or Authenticated");
			return;
		}
		AppActivity.getGameActivity().runOnUiThread(new Runnable() {
			@Override
			public void run() {
				GameRequestContent newGameRequestContent = new GameRequestContent.Builder()
		                .setMessage(message)
		                .setTitle(title)
		                .build();
		        gameRequestDialog.show(AppActivity.getGameActivity(), newGameRequestContent);
			}
		});
		//#endif
	}
	
	public static void onDestroy()
	{
		//#ifdef CC_USE_FACEBOOK
		if(profileTracker!=null)
		{
			profileTracker.stopTracking();
		}
		//#endif
	}

	private static  boolean isSDKInitialized()
	{
		//#ifdef CC_USE_FACEBOOK
		return FacebookSdk.isInitialized();
		//#else
//@		return false;
		//#endif
	}
}
	
