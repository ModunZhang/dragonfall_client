package com.batcatstudio.dragonfall.sdk;
import org.cocos2dx.lua.AppActivity;

//#ifdef CC_USE_SDK_PAYPAL
//@import java.io.File;
//@import java.io.FileInputStream;
//@import java.io.FileNotFoundException;
//@import java.io.FileOutputStream;
//@import java.io.IOException;
//@import java.math.BigDecimal;
//@import java.util.HashMap;
//@import java.util.Iterator;
//@import java.util.Map;
//@import org.json.JSONException;
//@import org.json.JSONObject;
//@
//@import com.batcatstudio.dragonfall.data.DataHelper;
//@import com.batcatstudio.dragonfall.utils.DebugUtil;
//@import com.batcatstudio.dragonfall.utils.DesUtils;
//@import com.paypal.android.sdk.payments.PayPalConfiguration;
//@import com.paypal.android.sdk.payments.PayPalPayment;
//@import com.paypal.android.sdk.payments.PayPalService;
//@import com.paypal.android.sdk.payments.PaymentActivity;
//@import com.paypal.android.sdk.payments.PaymentConfirmation;
//@import com.xapcn.dragonfall.BuildConfig;
//#endif
import android.app.Activity;
import android.content.Intent;
import android.util.Base64;

/**
 * PayPalSDK Android
 */
public class PayPalSDK {
	private static PayPalSDK m_instance = null;
	private static String PayPalSDK_Client_Id = "AZ_L7mxLskaM0ogbrhTxI4hNe-U0_nLiy2Ximw9Om-nMB0NiykQerxDAANisTxuRH-PItePDf9OmQm3Q";
	private static int PayPalSDK_BASE_REQUEST_CODE = 20000;
	private static int lastRequestCode = PayPalSDK_BASE_REQUEST_CODE;
	private static String TAG = "PayPalSDK";
	private static String RAWFILE_NAME = "/data.bin";
	private static native void onPayPalDone(String paymentId,String payment);
	private static native void onPayPalFailed();
	private static native String getPaypalSeedCode();


//#ifdef CC_USE_SDK_PAYPAL
//@	protected JSONObject m_PaypalPayments = null;
//@	private DesUtils desUtils = null;
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
//@		desUtils = new DesUtils(getPaypalSeedCode());
//@		m_PaypalPayments = initPayments();
//#endif
	}

	public void destroy(Activity activity) {
//#ifdef CC_USE_SDK_PAYPAL
//@		activity.stopService(new Intent(activity, PayPalService.class));
//#endif
	}

	public void buy(String name,String itemKey, double itemPrice) {
//#ifdef CC_USE_SDK_PAYPAL
//@		PayPalPayment payment = new PayPalPayment(new BigDecimal(itemPrice), "USD", name,
//@				PayPalPayment.PAYMENT_INTENT_SALE);
//@		payment.custom(itemKey);
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
//@
//@		                // send 'confirm' to your server for verification.
//@		                // see https://developer.paypal.com/webapps/developer/docs/integration/mobile/verify-mobile-payment/
//@		                // for more details.
//@						JSONObject obj = confirm.toJSONObject();
//@						String id = obj.getJSONObject("response").getString("id");
//@						JSONObject payments = getInstance().m_PaypalPayments;
//@						payments.put(id,obj);
//@						getInstance().saveCurrentPayments();
//@						DebugUtil.LogDebug(TAG, obj.toString(4));
//@						onPayPalDone(id,obj.toString());
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
	//#ifdef CC_USE_SDK_PAYPAL
//@	//初始化以前的payments
//@	private JSONObject initPayments(){
//@		String filePath = checkDataFile();
//@		File file = new File(filePath);
//@		try {
//@			FileInputStream is = new FileInputStream(file);;
//@			int size = is.available();
//@			byte[] buffer = new byte[size];
//@
//@			is.read(buffer);
//@			is.close();
//@
//@			String jsonstr = new String(Base64.decode(buffer, Base64.DEFAULT));
//@			jsonstr = desUtils.decrypt(jsonstr);
//@			if(jsonstr==null || jsonstr.length() ==0) {
//@				return  new JSONObject();
//@			}
//@			else
//@			{
//@				JSONObject jsonObject = new JSONObject(jsonstr);
//@				DebugUtil.LogDebug(TAG,"initPayments----"+jsonObject.toString(4));
//@				return jsonObject;
//@			}
//@
//@		} catch (Exception e) {
//@			DebugUtil.LogException(TAG,e);
//@			return  new JSONObject(); //如果解密失败,生成新的数据对象
//@		}
//@	}
//@
//@	//保存信息到本地文件
//@	private void savePayments(String content){
//@		try {
//@			String finalData = desUtils.encrypt(content);
//@			finalData = Base64.encodeToString(finalData.getBytes(), Base64.DEFAULT);
//@			String filePath = checkDataFile();
//@			FileOutputStream fileos = null;
//@			try{
//@				fileos = new FileOutputStream(filePath);
//@				byte [] bytes = finalData.getBytes();
//@				fileos.write(bytes);
//@				fileos.close();
//@			}catch(FileNotFoundException e){
//@				DebugUtil.LogException(TAG, e);
//@			} catch (IOException e) {
//@				DebugUtil.LogException(TAG, e);
//@			}
//@		} catch (Exception e) {
//@			DebugUtil.LogException(TAG, e);
//@		}
//@
//@	}
//@
//@	//检测手机中是否存在数据文件,始终返回文件路径(内存卡/手机)
//@	private String checkDataFile(){
//@		//注意:如果手机没有内存卡,数据文件在游戏卸载的时候会被系统删除！
//@		String outputDirectory = DataHelper.getUnZipRootPath(DataHelper.isExternalStorageMounted()) + "/batcatstudio/" + BuildConfig.GAME_ID;
//@		try{
//@			File file = new File(outputDirectory);
//@			if (!file.exists()) {
//@				file.mkdirs();
//@			}
//@			String rawFilePath = outputDirectory  +  RAWFILE_NAME;
//@			File rawFile = new File(rawFilePath);
//@			if(!rawFile.exists()){
//@				DebugUtil.LogErr(TAG,"create new payapl config "+rawFilePath);
//@				rawFile.createNewFile();
//@			}
//@			return rawFilePath;
//@		}catch (Exception e){
//@			DebugUtil.LogException(TAG,e);
//@		}
//@		return "";
//@	}
//@	//保存当前内存中的订单数据
//@	private void saveCurrentPayments(){
//@		savePayments(m_PaypalPayments.toString());
//@	}
	//#endif
	/******************************************Methods For Lua******************************************/

	//是否支持Paypal支付
	public static  boolean isPayPalSupport(){
//#ifdef CC_USE_SDK_PAYPAL
//@		return true;
//#else
		return false;
//#endif
	}


	//执行Paypal购买
	public static void paypalBuy(final String name,final String itemKey, final double itemPrice){
//#ifdef CC_USE_SDK_PAYPAL
//@		AppActivity.getGameActivity().runOnUiThread(new Runnable() {
//@			@Override
//@			public void run() {
//@				getInstance().buy(name,itemKey, itemPrice);
//@			}
//@		});
//#endif
	}

	//获取所有未验证的订单信息
	public static void updatePaypalPayments(){
//#ifdef CC_USE_SDK_PAYPAL
//@		JSONObject payments = getInstance().m_PaypalPayments;
//@		if(payments==null){
//@			return;
//@		}
//@		Iterator<String> keys = payments.keys();
//@		Map<String, String> map = new HashMap<String, String>();
//@		while (keys.hasNext()){
//@			String key = keys.next();
//@			map.put(key,payments.optJSONObject(key).toString());
//@		}
//@		Iterator<Map.Entry<String, String>> entries = map.entrySet().iterator();
//@		while (entries.hasNext()) {
//@			Map.Entry<String, String> entry = entries.next();
//@			onPayPalDone(entry.getKey(),entry.getValue());
//@		}
//#endif
	}

	//关闭某一笔订单
	public static void consumePaypalPayment(String itemKey){
//#ifdef CC_USE_SDK_PAYPAL
//@		JSONObject payments = getInstance().m_PaypalPayments;
//@		if(payments==null){
//@			return;
//@		}
//@		JSONObject payemnt = payments.optJSONObject(itemKey);
//@		if (payemnt!=null){
//@			payments.remove(itemKey);
//@			getInstance().saveCurrentPayments();
//@		}
//#endif
	}
}
