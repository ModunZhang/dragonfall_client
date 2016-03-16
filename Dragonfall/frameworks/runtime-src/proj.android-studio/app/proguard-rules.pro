# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in E:\developSoftware\Android\SDK/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}
# ----------------------------------------------
# Common config
# ----------------------------------------------
-keep class android.webkit.** {*;}
-dontwarn android.webkit.**

-keep class android.net.http.**{*;}
-dontwarn android.net.http.**
-keep class com.google.**{*;}
-dontwarn com.google.**

-keep class com.android.network.**{*;}
-dontwarn com.android.network.**

# ---------------- annotations -----------------
# keep annotations.
-keepattributes *Annotation*

# ---------------- serializable -----------------
-keep class * implements java.io.Serializable {
    <fields>;
}

# ---------------- enumeration -----------------
# For enumeration classes, see http://proguard.sourceforge.net/manual/examples.html#enumerations
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# ---------------- android -----------------
# android app.
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider
-keep public class * extends android.app.backup.BackupAgentHelper
-keep public class * extends android.preference.Preference

# We want to keep methods in Activity that could be used in the XML attribute onClick
-keepclassmembers class * extends android.app.Activity {
   public void *(android.view.View);
}

# android view.
-keepclasseswithmembers class * extends android.view.View {
    public <init>(android.content.Context);
    public <init>(android.content.Context, android.util.AttributeSet);
    public <init>(android.content.Context, android.util.AttributeSet, int);
}
-keepclassmembers public class * extends android.view.View {
   void set*(***);
   *** get*();
}
-keep public class * extends android.view.View$BaseSavedState{*;}

# android parcelable.
-keep class * implements android.os.Parcelable {
  public static final android.os.Parcelable$Creator *;
}

-keep public class com.nineoldandroids.**
-keep public class android.support.v4.**
-dontnote android.support.v4.**

-keepclasseswithmembernames class * {
    native <methods>;
}
# ----------------------------------------------
# Common config End
# ----------------------------------------------

#================cocos2dx========================
-keep class org.cocos2dx.utils.** {*;}
-keep class org.cocos2dx.lib.** {*;}
-keep class com.chukong.cocosplay.** {*;}

#================sdks========================
#talkingdata
#-libraryjars ./libs/Game_Analytics_SDK_Android_3.2.3.jar
-keep class com.talkingdata.** {*;}
-keep class com.tendcloud.** {*;}
-dontwarn com.tendcloud.**
-dontwarn com.talkingdata.**
-dontwarn com.gametalkingdata.**
-keep public class com.gametalkingdata.** {*;}
-keep public class com.tendcloud.tenddata.** {*;}
#facebook
-keepattributes Signature
-keep class com.facebook.android.*
-keep class android.webkit.WebViewClient
-keep class * extends android.webkit.WebViewClient
-keepclassmembers class * extends android.webkit.WebViewClient {
    <methods>;
}
#AppsFlyer
#-libraryjars ./libs/AF-Android-SDK-v3.3.0.jar
#================Project========================
-keep class com.batcatstudio.dragonfall.notifications.NotificationUtils {
	public static boolean addLocalPush(...);
	public static void cancelAllLocalPush(...);
	public static boolean cancelNotificationWithIdentity(...);
}

-keep class com.batcatstudio.dragonfall.sdk.MarketSDK {
	public static void initSDK();
	public static void onPlayerLogin(...);
	public static void onPlayerChargeRequst(...);
	public static void onPlayerChargeSuccess(...);
	public static void onPlayerBuyGameItems(...);
	public static void onPlayerUseGameItems(...);
	public static void onPlayerReward(...);
	public static void onPlayerEvent(...);
	public static void onPlayerLevelUp(...);
}

-keep class com.batcatstudio.dragonfall.utils.CommonUtils {
	public static java.lang.String getUDID();
    public static void RegistereForRemoteNotifications();
	public static void copyText(...);
	public static java.lang.String getAppVersion();
	public static java.lang.String getOSVersion();
	public static java.lang.String getDeviceModel();
	public static java.lang.String getAppBundleVersion();
	public static java.lang.String getDeviceLanguage();
	public static boolean sendMail(...);
	public static boolean canSendMail();
	public static void checkGameFirstInstall(...);
	public static void disableIdleTimer(...);
	public static float batteryLevel();
	public static java.lang.String getInternetConnectionStatus();
	public static java.lang.String getAppMinVersion();
	public static boolean isAppHocMode();
	public static boolean isLowMemoryDevice();
	public static java.lang.String GetDeviceToken();
}

-keep class com.batcatstudio.dragonfall.io.JniFileOperation {
	public static boolean createDir(...);
	public static boolean copyFileTo(...);
	public static boolean removeDir(...);
}
-keep class com.batcatstudio.dragonfall.google.billing.StoreKit {
	public static void requestProductData(...);
	public static void buy(...);
	public static void consumePurchase(...);
	public static void updateTransactionStates(...);
	public static boolean isGMSSupport();
	public static void getGMSSupport();
}
-keep class com.batcatstudio.dragonfall.sdk.FaceBookSDK {
	public static void Initialize();
    public static void Login();
    public static boolean IsAuthenticated();
    public static java.lang.String GetFBUserName();
    public static java.lang.String GetFBUserId();
    public static void AppInvite(...);
}
-keep class com.batcatstudio.dragonfall.sdk.PayPalSDK {
	public static void paypalBuy(...);
	public static boolean isPayPalSupport();
}

-keep class com.batcatstudio.dragonfall.sdk.GoogleSignSDK {
	public static void Login();
	public static boolean IsAuthenticated();
	public static java.lang.String GetGoogleUserName();
	public static java.lang.String GetGoogleId();
}

#================Google Billing========================
-keep class com.android.vending.billing.**

#================Google Play========================
-keep class com.google.android.gms.** {*;}
-dontwarn com.google.android.gms.**

-keep class * extends java.util.ListResourceBundle {
    protected Object[][] getContents();
}

-keep public class com.google.android.gms.common.internal.safeparcel.SafeParcelable {
    public static final *** NULL;
}

-keepnames @com.google.android.gms.common.annotation.KeepName class *
-keepclassmembernames class * {
    @com.google.android.gms.common.annotation.KeepName *;
}

-keepnames class * implements android.os.Parcelable {
    public static final ** CREATOR;
}
#================Paypal========================
#-libraryjars ./libs/PayPalAndroidSDK-2.13.1.jar
#-libraryjars ./libs/okhttp-3.0.1.jar
#-libraryjars ./libs/okio-1.6.0.jar
-dontwarn okhttp3.internal.**
-dontwarn okio.*
-keep class com.paypal.android.sdk.payments.* {*;}
-dontwarn com.paypal.android.sdk.payments.**
-dontwarn com.paypal.android.sdk.**