package com.batcatstudio.dragonfall.sdk;

import org.cocos2dx.lua.AppActivity;
//#ifdef CC_USE_FACEBOOK
import com.facebook.Request;
import com.facebook.Response;
import com.facebook.Session;
import com.facebook.SessionState;
import com.facebook.model.GraphUser;
//#endif
import com.batcatstudio.dragonfall.data.DataHelper;
import com.batcatstudio.dragonfall.utils.DebugUtil;
import android.app.Activity;
import android.content.Intent;

public class FaceBookSDK {
	//native
	private static native void initJNI();
	private static native void FaceBookEvent(String eventName,String fbUserName,String fbUserId);
	private static String TAG = "FaceBookSDK";
	private static String FB_USER_ID_KEY = "FBUser_Id";
	private static String FB_USER_NAME_KEY = "FBUser_Name";
	//method
	public static void init()
	{
		initJNI();
	}
	
	public static void Initialize()
	{
		DebugUtil.LogInfo(TAG, "FaceBook Not need Initialize on Android");
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
	
	private static void SaveUserProfile(String fbUid,String fbUname)
	{
		DataHelper.saveStringValue(FB_USER_ID_KEY, fbUid);
		DataHelper.saveStringValue(FB_USER_NAME_KEY, fbUname);
	}
	
	private static void LoginAction()
	{
		//#ifdef CC_USE_FACEBOOK
		Session.openActiveSession(AppActivity.getGameActivity(), true, new Session.StatusCallback() {
			
			@Override
			public void call(Session session, SessionState state, Exception exception) {
				if(state.isOpened())
				{
					 Request getMeRequest = Request.newMeRequest(session, new Request.GraphUserCallback() {
						
						@Override
						public void onCompleted(GraphUser user, Response response) {
							if(null != user)
							{
								
								SaveUserProfile(user.getId(),user.getName());
								CallLuaCallBack("login_success",user.getName(),user.getId());
							}
							else
							{
								CallLuaCallBack("login_exception","","");
							}
						}
					});
					getMeRequest.executeAsync();
				}
			}
		});
		//#endif
	}
	
	public static void Login()
	{
		
		AppActivity.getGameActivity().runOnUiThread(new Runnable() {
			@Override
			public void run() {
				LoginAction();
			}
		});
	}
	
	public static boolean IsAuthenticated()
	{
		return DataHelper.readStringValue(FB_USER_ID_KEY) != "";
	}
	
	public static String GetFBUserName()
	{
		return DataHelper.readStringValue(FB_USER_NAME_KEY);
	}
	
	public static String GetFBUserId()
	{
		return DataHelper.readStringValue(FB_USER_ID_KEY);
	}
	
	public static void onActivityResult(Activity activity,int requestCode, int resultCode, Intent data)
	{
		DebugUtil.LogDebug(TAG, "onActivityResult");
		//#ifdef CC_USE_FACEBOOK
		Session activeSession = Session.getActiveSession();
		if(null != activeSession)
		{
			activeSession.onActivityResult(activity, requestCode, resultCode,data);
			if(!activeSession.isOpened())
			{
				CallLuaCallBack("login_exception","","");
			}
		}
		//#endif
	}
}
	
