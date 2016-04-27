package com.tencent.bugly.cocos;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

import com.tencent.bugly.crashreport.CrashReport.CrashHandleCallback;

import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.os.Process;
import android.text.TextUtils;
import android.util.Log;

public class Cocos2dxAgent {
	public static String sdkPackageName = "com.tencent.bugly";

	private static boolean debug = true;

	private static Handler handler = null;

	private static String app_version = null;
	private static String appChannel = null;
	private static long app_delay = 0L;
	private static native String getLuaStackString(int arg);
	
	private static CrashHandleCallback app_crashCallback = new CrashHandleCallback() {
		/**
		 * Crash处理
		 *
		 * @param crashType
		 *            错误类型：CRASHTYPE_JAVA，CRASHTYPE_NATIVE，CRASHTYPE_U3D
		 * @param errorType
		 *            错误的类型名
		 * @param errorMessage
		 *            错误的消息
		 * @param errorStack
		 *            错误的堆栈
		 * @return Map<String key , String value> 额外的自定义信息上报
		 */
		public synchronized Map<String, String> onCrashHandleStart(int crashType, String errorType, String errorMessage,
				String errorStack) {

			HashMap<String, String> data = new HashMap<String, String>();
			data.put("LuaStack",getLuaStackString(0));
			return data;
		}
	};

	private Cocos2dxAgent() {
		try {
			handler = new Handler(Looper.getMainLooper());
		} catch (Exception localException) {
			printLog(2, "[cocos2d-x] Get the main looper handler Failed.");
			localException.printStackTrace();
		}
	}

	public String getVersion() {
		return "1.2.0";
	}

	public static void setSDKPackagePrefixName(String packageName) {
		if (TextUtils.isEmpty(packageName)) {
			return;
		}

		sdkPackageName = packageName;
	}

	public static void initCrashReport(Context context, String appId, boolean isDebug) {
		initCrashReport(context, appId, isDebug, appChannel, app_version, null, app_delay);
	}

	private static void initCrashReport(Context paramContext, String paramString1, boolean paramBoolean,
			String paramString2, String paramString3, String paramString4, long paramLong) {
		if (paramContext == null) {
			printLog(3, "context is null. bugly initialize terminated.");
		}
		debug = paramBoolean;
		if (TextUtils.isEmpty(paramString1)) {
			printLog(2, "Please input appid when initCrashReport.");
			return;
		}
		if ((paramContext == null) || (TextUtils.isEmpty(paramString1))) {
			Log.w("Cocos2dxAgent", "Fail to init the crash report");
			return;
		}

		int i = 0;
		Object localObject = createUserStrategy(paramContext, paramString2, paramString3, paramLong);

		if (localObject != null) {
			Class localClass = null;
			try {
				localClass = Class.forName(getMethodString("crashreport.CrashReport$UserStrategy"));
			} catch (ClassNotFoundException localClassNotFoundException) {
				localClassNotFoundException.printStackTrace();
			} catch (Exception localException) {
				localException.printStackTrace();
			}

			if (localClass != null) {
				JavaRefHelper.invoke(getMethodString("crashreport.CrashReport"), "initCrashReport",
						new Object[] { paramContext, paramString1, Boolean.valueOf(paramBoolean), localObject },
						new Class[] { Context.class, String.class, Boolean.TYPE, localClass });

				i = 1;
			}
		}

		if (i == 0) {
			JavaRefHelper.invoke(getMethodString("crashreport.CrashReport"), "initCrashReport",
					new Object[] { paramContext, paramString1, Boolean.valueOf(paramBoolean) },
					new Class[] { Context.class, String.class, Boolean.TYPE });
		}

		if (!TextUtils.isEmpty(paramString4)) {
			JavaRefHelper.invoke(getMethodString("crashreport.CrashReport"), "setUserId", new Object[] { paramString4 },
					new Class[] { String.class });
		}
	}

	public static void setAppVersion(String version) {
		if (TextUtils.isEmpty(version)) {
			return;
		}

		app_version = version;
	}

	public static void setAppChannel(String channel) {
		if (TextUtils.isEmpty(channel)) {
			return;
		}

		appChannel = channel;
	}

	public static void setDelayTime(long delay) {
		if (delay <= 0L) {
			return;
		}
		app_delay = delay;
	}

	private static Object createUserStrategy(Context paramContext, String paramString1, String paramString2,
			long paramLong) {
		if ((paramContext == null) || ((TextUtils.isEmpty(paramString1)) && (TextUtils.isEmpty(paramString2)))) {
			printLog(0, "hack:createUserStrategy1");
			return null;
		}

		Object localObject = JavaRefHelper.newInstance(getMethodString("crashreport.CrashReport$UserStrategy"),
				new Object[] { paramContext }, new Class[] { Context.class });

		if (localObject != null) {
			Class localClass = localObject.getClass();
			try {
				Method localMethod1 = localClass.getDeclaredMethod("setAppChannel", new Class[] { String.class });
				localMethod1.invoke(localObject, new Object[] { paramString1 });
				Method localMethod2 = localClass.getDeclaredMethod("setAppVersion", new Class[] { String.class });
				localMethod2.invoke(localObject, new Object[] { paramString2 });
				Method localMethod3 = localClass.getDeclaredMethod("setAppReportDelay", new Class[] { Long.TYPE });
				localMethod3.invoke(localObject, new Object[] { Long.valueOf(paramLong) });
				Method localMethod4 = localClass.getDeclaredMethod("setCrashHandleCallback",
						new Class[] { CrashHandleCallback.class });
				localMethod4.invoke(localObject, new Object[] { app_crashCallback });
				Log.w("Cocos2dxAgent","We add CrashHandleCallback for cocos at 1.2.0");
				return localObject;
			} catch (NoSuchMethodException localNoSuchMethodException) {
				localNoSuchMethodException.printStackTrace();
			} catch (IllegalAccessException localIllegalAccessException) {
				localIllegalAccessException.printStackTrace();
			} catch (IllegalArgumentException localIllegalArgumentException) {
				localIllegalArgumentException.printStackTrace();
			} catch (InvocationTargetException localInvocationTargetException) {
				localInvocationTargetException.printStackTrace();
			} catch (Exception localException) {
				localException.printStackTrace();
			}
		}
		return null;
	}

	public static void postException(int category, String type, String message, String stack, boolean autoExit) {
		try {
			if (stack.startsWith("stack traceback")) {
				stack = stack.substring(stack.indexOf("\n") + 1, stack.length()).trim();
			}

			int i = stack.indexOf("\n");
			if (i > 0) {
				stack = stack.substring(i + 1, stack.length());
			}

			i = stack.indexOf("\n");
			String str = stack;
			if (i > 0) {
				str = stack.substring(0, i);
			}

			int j = str.indexOf("]:");
			if ((type == null) || (type.length() == 0)) {
				if (j != -1) {
					type = str.substring(0, j + 1);
				} else {
					type = message;
				}
			}
		} catch (Throwable localThrowable1) {
			if ((type == null) || (type.length() == 0)) {
				type = message;
			}
		}

		JavaRefHelper.invoke(getMethodString("crashreport.inner.InnerAPI"), "postCocos2dxCrashAsync",
				new Object[] { Integer.valueOf(category), type, message, stack },
				new Class[] { Integer.TYPE, String.class, String.class, String.class });

		if (autoExit) {
			a(3000L);
		}
	}

	public static void printLog(String msg) {
		if (TextUtils.isEmpty(msg)) {
			return;
		}

		printLog(2, msg);
	}

	public static void printLog(int level, String msg) {
		if (TextUtils.isEmpty(msg)) {
			return;
		}

		if ((debug) && (level == 0)) {
			printLog("d", msg);
		}

		if (level == 1) {
			printLog("i", msg);
		}
		if (level == 2) {
			printLog("w", msg);
		}

		if (level >= 3) {
			printLog("e", msg);
		}
	}

	private static void printLog(String paramString1, String paramString2) {
		JavaRefHelper.invoke(getMethodString("crashreport.BuglyLog"), paramString1, new Object[] { "", paramString2 },
				new Class[] { String.class, String.class });
	}

	public static void setUserId(String userId) {
		if (TextUtils.isEmpty(userId)) {
			return;
		}

		JavaRefHelper.invoke(getMethodString("crashreport.CrashReport"), "setUserId", new Object[] { userId },
				new Class[] { String.class });
	}

	public static void setUserSceneTag(Context context, int sceneId) {
		if (context != null) {
			JavaRefHelper.invoke(getMethodString("crashreport.CrashReport"), "setUserSceneTag",
					new Object[] { context, Integer.valueOf(sceneId) }, new Class[] { Context.class, Integer.TYPE });
		}
	}

	public static void putUserData(Context context, String key, String value) {
		if ((TextUtils.isEmpty(key)) || (TextUtils.isEmpty(value))) {
			return;
		}
		if (context != null) {
			JavaRefHelper.invoke(getMethodString("crashreport.CrashReport"), "putUserData",
					new Object[] { context, key, value }, new Class[] { Context.class, String.class, String.class });
		}
	}

	public static void removeUserData(Context context, String key) {
		if (TextUtils.isEmpty(key)) {
			return;
		}
		if (context != null) {
			JavaRefHelper.invoke(getMethodString("crashreport.CrashReport"), "removeUserData",
					new Object[] { context, key }, new Class[] { Context.class, String.class });
		}
	}

	public static void setLog(int level, String tag, String logData) {
		if (TextUtils.isEmpty(logData)) {
			return;
		}
		String str = null;
		switch (level) {
		case 0:
			str = "v";
			break;
		case 1:
			str = "d";
			break;
		case 2:
			str = "i";
			break;
		case 3:
			str = "w";
			break;
		case 4:
			str = "e";
		}

		if (str != null) {
			if (TextUtils.isEmpty(tag)) {
				tag = "";
			}
			JavaRefHelper.invoke(getMethodString("crashreport.BuglyLog"), str, new Object[] { tag, logData },
					new Class[] { String.class, String.class });
		}
	}

	private static void a(long paramLong) {
		paramLong = Math.max(0L, paramLong);

		if (handler != null) {
			handler.postDelayed(new Runnable() {
				public void run() {
				}
			}, paramLong);

		} else {

			try {

				Thread.sleep(paramLong);

				exitApplication();
			} catch (InterruptedException localInterruptedException) {
				localInterruptedException.printStackTrace();
			}
		}
	}

	public static void exitApplication() {
		int i = Process.myPid();

		printLog(2, String.format("Exit application by kill process[%d]", new Object[] { Integer.valueOf(i) }));

		Process.killProcess(i);
	}

	private static String getMethodString(String paramString) {
		StringBuilder localStringBuilder = new StringBuilder();
		if (sdkPackageName == null) {
			sdkPackageName = "com.tencent.bugly";
		}
		localStringBuilder.append(sdkPackageName);
		localStringBuilder.append(".");
		localStringBuilder.append(paramString);
		return localStringBuilder.toString();
	}

	private static class JavaRefHelper {
		public static Object invoke(String paramString1, String paramString2, Object[] paramArrayOfObject,
				Class<?>... paramVarArgs) {
			try {
				Class localClass = Class.forName(paramString1);
				Method localMethod = localClass.getDeclaredMethod(paramString2, paramVarArgs);
				localMethod.setAccessible(true);
				return localMethod.invoke(null, paramArrayOfObject);
			} catch (ClassNotFoundException localClassNotFoundException) {
				localClassNotFoundException.printStackTrace();
			} catch (NoSuchMethodException localNoSuchMethodException) {
				localNoSuchMethodException.printStackTrace();
			} catch (InvocationTargetException localInvocationTargetException) {
				localInvocationTargetException.printStackTrace();
			} catch (IllegalAccessException localIllegalAccessException) {
				localIllegalAccessException.printStackTrace();
			} catch (Exception localException) {
				localException.printStackTrace();
			}
			return null;
		}

		public static Object newInstance(String paramString, Object[] paramArrayOfObject, Class<?>... paramVarArgs) {
			try {
				Class localClass = Class.forName(paramString);
				if (paramArrayOfObject == null) {
					return localClass.newInstance();
				}
				Constructor localConstructor = localClass.getConstructor(paramVarArgs);
				return localConstructor.newInstance(paramArrayOfObject);
			} catch (ClassNotFoundException localClassNotFoundException) {
				localClassNotFoundException.printStackTrace();
			} catch (NoSuchMethodException localNoSuchMethodException) {
				localNoSuchMethodException.printStackTrace();
			} catch (InstantiationException localInstantiationException) {
				localInstantiationException.printStackTrace();
			} catch (IllegalAccessException localIllegalAccessException) {
				localIllegalAccessException.printStackTrace();
			} catch (InvocationTargetException localInvocationTargetException) {
				localInvocationTargetException.printStackTrace();
			} catch (Exception localException) {
				localException.printStackTrace();
			}

			return null;
		}
	}
}
