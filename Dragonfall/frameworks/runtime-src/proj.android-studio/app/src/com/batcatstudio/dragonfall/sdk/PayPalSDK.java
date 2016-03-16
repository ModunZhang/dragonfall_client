package com.batcatstudio.dragonfall.sdk;
import org.cocos2dx.lua.AppActivity;

//#ifdef CC_USE_SDK_PAYPAL
//@import java.math.BigDecimal;
//@import org.cocos2dx.lua.AppActivity;
//@import org.json.JSONException;
//@import com.batcatstudio.dragonfall.utils.DebugUtil;
//@import com.paypal.android.sdk.payments.PayPalConfiguration;
//@import com.paypal.android.sdk.payments.PayPalPayment;
//@import com.paypal.android.sdk.payments.PayPalService;
//@import com.paypal.android.sdk.payments.PaymentActivity;
//@import com.paypal.android.sdk.payments.PaymentConfirmation;
//#endif
import android.app.Activity;
import android.content.Intent;

public class PayPalSDK {

	private static PayPalSDK m_instance = null;
	private static String PayPalSDK_Client_Id = "AZ_L7mxLskaM0ogbrhTxI4hNe-U0_nLiy2Ximw9Om-nMB0NiykQerxDAANisTxuRH-PItePDf9OmQm3Q";
	private static int PayPalSDK_BASE_REQUEST_CODE = 20000;
	private static int lastRequestCode = PayPalSDK_BASE_REQUEST_CODE;
	private static String TAG = "PayPalSDK";
	
	private static native void onPayPalDone(String payment);
	private static native void onPayPalFailed();
	
//#ifdef CC_USE_SDK_PAYPAL
//@	private static PayPalConfiguration config = null;
//#endif
	
	public void init(Activity activity) {
//#ifdef CC_USE_SDK_PAYPAL
//@		config = new PayPalConfiguration();
//@		// Start with mock environment. When ready, switch to sandbox (ENVIRONMENT_SANDBOX) or live (ENVIRONMENT_PRODUCTION)
//@		config.environment(PayPalConfiguration.ENVIRONMENT_SANDBOX);
//@		config.clientId(PayPalSDK_Client_Id);
//@		Intent intent = new Intent(activity, PayPalService.class);
//@
//@		intent.putExtra(PayPalService.EXTRA_PAYPAL_CONFIGURATION, config);
//@
//@		activity.startService(intent);
//#endif
	}

	public void destroy(Activity activity) {
//#ifdef CC_USE_SDK_PAYPAL
//@		activity.stopService(new Intent(activity, PayPalService.class));
//#endif
	}

	public void buy(String itemKey, double itemPrice) {
//#ifdef CC_USE_SDK_PAYPAL
//@		PayPalPayment payment = new PayPalPayment(new BigDecimal(itemPrice), "USD", itemKey,
//@				PayPalPayment.PAYMENT_INTENT_SALE);
//@
//@		Activity gameActivity = AppActivity.getGameActivity();
//@		Intent intent = new Intent(gameActivity, PaymentActivity.class);
//@
//@		// send the same configuration for restart resiliency
//@		intent.putExtra(PayPalService.EXTRA_PAYPAL_CONFIGURATION, config);
//@
//@		intent.putExtra(PaymentActivity.EXTRA_PAYMENT, payment);
//@
//@		gameActivity.startActivityForResult(intent, ++lastRequestCode);
//#endif
	}

	public static PayPalSDK getInstance() {
		if (m_instance == null) {
			m_instance = new PayPalSDK();
		}
		return m_instance;
	}

	public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
//#ifdef CC_USE_SDK_PAYPAL
//@		if(requestCode > PayPalSDK_BASE_REQUEST_CODE) {
//@			if (resultCode == Activity.RESULT_OK) {
//@		        PaymentConfirmation confirm = data.getParcelableExtra(PaymentActivity.EXTRA_RESULT_CONFIRMATION);
//@		        if (confirm != null) {
//@		            try {
//@		            	DebugUtil.LogDebug(TAG,confirm.toJSONObject().toString(4));
//@		                // send 'confirm' to your server for verification.
//@		                // see https://developer.paypal.com/webapps/developer/docs/integration/mobile/verify-mobile-payment/
//@		                // for more details.
//@		            	onPayPalDone(confirm.toJSONObject().toString());
//@		            } catch (JSONException e) {
//@		            	onPayPalFailed();
//@		                DebugUtil.LogException(TAG, e);
//@		            }
//@		        }
//@		    }
//@		    else if (resultCode == Activity.RESULT_CANCELED) {
//@		    	DebugUtil.LogDebug(TAG, "The user canceled.");
//@		    	onPayPalFailed();
//@		    }
//@		    else if (resultCode == PaymentActivity.RESULT_EXTRAS_INVALID) {
//@		    	onPayPalFailed();
//@		    	DebugUtil.LogErr(TAG, "An invalid Payment or PayPalConfiguration was submitted. Please see the docs.");
//@		    }
//@			return true;
//@		}
//#endif
		return false;
	}
	
	public static  boolean isPayPalSupport(){
//#ifdef CC_USE_SDK_PAYPAL
//@		return true;
//#else
		return false;
//#endif
	}
	
	/******************************************Native******************************************/
	public static void paypalBuy(final String itemKey, final double itemPrice){
//#ifdef CC_USE_SDK_PAYPAL
//@		AppActivity.getGameActivity().runOnUiThread(new Runnable() {
//@			@Override
//@			public void run() {
//@				getInstance().buy(itemKey, itemPrice);
//@			}
//@		});
//#endif
	}
	
}
