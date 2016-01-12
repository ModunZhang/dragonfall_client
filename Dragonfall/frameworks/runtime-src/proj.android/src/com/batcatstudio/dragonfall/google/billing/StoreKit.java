package com.batcatstudio.dragonfall.google.billing;

import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lua.AppActivity;

import com.batcatstudio.dragonfall.google.billing.data.Inventory;
import com.batcatstudio.dragonfall.google.billing.data.SkuDetails;
import com.batcatstudio.dragonfall.utils.CommonUtils;
import com.batcatstudio.dragonfall.utils.DebugUtil;

import android.content.Intent;

public class StoreKit {

	private static String GOOGLEPLAYSERVICEPACKAGENAME = "com.google.android.gms";

	private static final String TAG = "StoreKit";

	private static final boolean DEBUG = false;
	private static final long VERIFY_PURCHASE_DELAY = 60000;

	private static final int BASE_REQUEST_CODE = 5000;
	private static IabHelper mHelper = null;
	private static Inventory currentInv = null;
	private static int latestRequestCode = BASE_REQUEST_CODE;

	// native
	private static native void productDataReceived(String[] itemIds, String[] itemPrices);

	private static native void verifyGPV3Purchase(String orderId, String purchaseData, String signature);

	private static native void initJNI();

	private static native void onPurchaseFailed();
	
	public static void updateTransactionStates(final ArrayList<String> skuArray) {
		if (DEBUG) {
			DebugUtil.LogInfo(TAG, "updateTransactionStates: " + skuArray);
		}
		if(mHelper!=null && mHelper.iapSupported() &&  skuArray.size() > 0){
			AppActivity.getGameActivity().runOnUiThread(new Runnable() {
				@Override
				public void run() {
					mHelper.queryInventoryAsync(true, skuArray, mGotInventoryListener);
				}
			});
		}
		
	}
	
	public static void requestProductData(Set<String> itemSkuSet) {
		if (DEBUG) {
			DebugUtil.LogInfo(TAG, "requestProductData: " + itemSkuSet);
		}
		if (currentInv.getAllSkuSet().size() > 0) {
			String[] itemIds = new String[itemSkuSet.size()];
			String[] itemPrices = new String[itemSkuSet.size()];
			int i = 0;
			for (String sku : itemSkuSet) {
				if (currentInv.hasDetails(sku)) {
					SkuDetails details = currentInv.getSkuDetails(sku);
					itemIds[i] = sku;
					itemPrices[i++] = details.getPrice();
					if (DEBUG)
						DebugUtil.LogInfo(TAG, String.format("itemId: %s, itemPrice: %s", sku, details.getPrice()));
				} else {
					DebugUtil.LogErr(TAG, "requestProductData not exist, sku: " + sku);
				}
			}
			productDataReceived(itemIds, itemPrices);
		}
	}

	public static void buy(final String sku) {
		if (mHelper.iapSupported()) {
			AppActivity.getGameActivity().runOnUiThread(new Runnable() {
				@Override
				public void run() {
					try {
						mHelper.launchPurchaseFlow(AppActivity.getGameActivity(), sku, ++latestRequestCode,
								mPurchaseFinishedListener);
					} catch (Exception e) {
						DebugUtil.LogException(TAG, e);
						AppActivity.getGameActivity().runOnGLThread(new Runnable() {
							@Override
							public void run() {
								onPurchaseFailed();
							}
						});
					}
				}
			});
		}
	}

	private static IabHelper.OnIabPurchaseFinishedListener mPurchaseFinishedListener = new IabHelper.OnIabPurchaseFinishedListener() {
		public void onIabPurchaseFinished(IabResult result, final Purchase purchase) {
			if (DEBUG)
				DebugUtil.LogDebug(TAG, "Purchase finished: " + result + ", purchase: " + purchase);
			if (result.isFailure()) {
				DebugUtil.LogErr(TAG, String.format("Purchase failed, error info: %s", result.getMessage()));
				AppActivity.getGameActivity().runOnGLThread(new Runnable() {
					@Override
					public void run() {
						onPurchaseFailed();
					}
				});
				return;
			}
			if (!verifyDeveloperPayload(purchase)) {
				DebugUtil.LogErr(TAG, "Error purchasing: verifyDeveloperPayload failed.");
				return;
			}
			currentInv.addPurchase(purchase);

			AppActivity.getGameActivity().runOnUiThread(new Runnable() {
				@Override
				public void run() {
					AppActivity.getGameActivity()
							.showDialog(AppActivity.AppActivityDialog.DIALOG_PAYMENT_PURCHASED.ordinal());
				}
			});
			AppActivity.getGameActivity().runOnGLThread(new Runnable() {
				@Override
				public void run() {
					verifyGPV3Purchase(purchase.getOrderId(), purchase.getOriginalJson(),
							purchase.getSignature());
				}
			});
		}
	};

	/** Verifies the developer payload of a purchase. */
	private static boolean verifyDeveloperPayload(Purchase p) {
		return true;
	}

	private static long currentDelay = 0l;

	public static void consumePurchase(final String orderId) {
		if (orderId.length() != 0 && currentInv.hasPurchase(orderId)) {
			if (DEBUG) {
				DebugUtil.LogDebug(TAG, "consumePurchase: " + currentInv.getPurchase(orderId));
			}
			try {
				AppActivity.gameHandler.postDelayed(new Runnable() {
					@Override
					public void run() {
						mHelper.consumeAsync(currentInv.getPurchase(orderId), mConsumeFinishedListener);
					}
				}, currentDelay);
				currentDelay += 100;
			} catch (Exception e) {
				DebugUtil.LogException(TAG, e);
			}
		}
	}

	private static IabHelper.OnConsumeFinishedListener mConsumeFinishedListener = new IabHelper.OnConsumeFinishedListener() {
		public void onConsumeFinished(Purchase purchase, IabResult result) {
			if (DEBUG)
				DebugUtil.LogDebug(TAG, "Consumption finished. Purchase: " + purchase + ", result: " + result);
			if (result.isSuccess()) {
				if (DEBUG) {
					DebugUtil.LogDebug(TAG, "Consumption successful. Provisioning.");
				}
				currentInv.erasePurchase(purchase.getOrderId());

			} else {
				if (DEBUG) {
					DebugUtil.LogErr(TAG, "Consumption faild. Error info: " + result.getMessage());
				}
			}
		}
	};

	// can buy ?
	public static boolean isGMSSupport() {
		//google play service and  billing v3  
		return mHelper.iapSupported();
	}

	public static void getGMSSupport() {
		CommonUtils.openAppInGooglePlayMarket(GOOGLEPLAYSERVICEPACKAGENAME);
	}

	public static void init() {
		initJNI();
		mHelper = new IabHelper(AppActivity.getGameActivity());
		currentInv = new Inventory();

		mHelper.startSetup(new IabHelper.OnIabSetupFinishedListener() {
			public void onIabSetupFinished(IabResult result) {
				if (!result.isSuccess()) {
					if (DEBUG) {
						DebugUtil.LogErr(TAG, "Problem setting up in-app billing: " + result);
					}
					return;
				}
			}
		});
	}

	private static IabHelper.QueryInventoryFinishedListener mGotInventoryListener = new IabHelper.QueryInventoryFinishedListener() {
		public void onQueryInventoryFinished(IabResult result, final Inventory inventory) {
			if (result.isFailure()) {
				if (DEBUG)
					DebugUtil.LogErr(TAG, "Failed to query inventory: " + result);
				return;
			}
			if (DEBUG)
				DebugUtil.LogDebug(TAG, "Query inventory was successful.");
			currentInv = inventory;

			final List<Purchase> unverifiedPurchases = inventory.getAllPurchases();
			if (DEBUG)
				DebugUtil.LogDebug(TAG, "before unverifiedPurchases.size() > 0");
			if (unverifiedPurchases.size() > 0) {
				if (DEBUG) {
					DebugUtil.LogInfo(TAG, "Got unverified purchases: " + unverifiedPurchases);
				}
				AppActivity.gameHandler.postDelayed(new Runnable() {
					@Override
					public void run() {
						for (final Purchase purchase : unverifiedPurchases) {
							if (verifyDeveloperPayload(purchase)) {
								Cocos2dxHelper.runOnGLThread(new Runnable() {
									@Override
									public void run() {
										if (DEBUG)
											DebugUtil.LogDebug(TAG, "before verifyGPV3Purchase");
										if (DEBUG)
											DebugUtil.LogDebug(TAG, purchase.getOrderId());
										if (DEBUG)
											DebugUtil.LogDebug(TAG, purchase.getOriginalJson());
										if (DEBUG)
											DebugUtil.LogDebug(TAG, URLEncoder.encode(purchase.getSignature()));
										verifyGPV3Purchase(purchase.getOrderId(), purchase.getOriginalJson(),
												purchase.getSignature());
									}
								});
							}
						}
					}
				}, VERIFY_PURCHASE_DELAY);
			}
		}
	};

	public static boolean handleActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode > BASE_REQUEST_CODE) {
			mHelper.handleActivityResult(requestCode, resultCode, data);
			return true;
		}
		return false;
	}

	public static void purge() {
		if (mHelper != null)
			mHelper.dispose();
		mHelper = null;
		currentInv = null;
		mPurchaseFinishedListener = null;
		mGotInventoryListener = null;
		mConsumeFinishedListener = null;
	}
}
