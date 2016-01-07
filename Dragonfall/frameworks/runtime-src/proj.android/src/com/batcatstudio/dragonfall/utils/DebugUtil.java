package com.batcatstudio.dragonfall.utils;
import android.util.Log;

public class DebugUtil {
	private static final boolean isLogErrorOn = true;
	private static final boolean isLogExceptionOn = true;
//#ifdef _DEBUG
	private static final boolean isLogDebugOn = true;
//#else
//@	private static final boolean isLogDebugOn = false;
//#endif
	public static void LogErr(String TAG, String msg) {
		if (isLogErrorOn)
			Log.e(TAG, msg);
	}

	public static void LogException(String TAG, Exception e) {
		if (isLogExceptionOn) {
			Log.e(TAG, Log.getStackTraceString(e));
		}
	}

	public static void LogVerbose(String TAG, String msg) {
		if (isLogDebugOn)
			Log.v(TAG, msg);
	}
	
	public static void LogInfo(String TAG, String msg) {
		if (isLogDebugOn)
			Log.i(TAG, msg);
	}

	public static void LogDebug(String TAG, String msg) {
		if (isLogDebugOn)
			Log.d(TAG, msg);
	}

	public static void LogWarn(String TAG, String msg) {
		if (isLogDebugOn)
			Log.w(TAG, msg);
	}

}
