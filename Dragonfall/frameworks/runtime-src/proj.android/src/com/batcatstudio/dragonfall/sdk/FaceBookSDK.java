package com.batcatstudio.dragonfall.sdk;

public class FaceBookSDK {

	//native
	private static native void initJNI();

	//method
	public static void init()
	{
		initJNI();
	}
}
	