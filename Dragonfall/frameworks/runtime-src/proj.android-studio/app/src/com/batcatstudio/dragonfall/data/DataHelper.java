package com.batcatstudio.dragonfall.data;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.zip.Adler32;
import java.util.zip.CRC32;
import java.util.zip.CheckedInputStream;
import java.util.zip.CheckedOutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lua.AppActivity;

import com.batcatstudio.dragonfall.utils.DebugUtil;
import com.xapcn.dragonfall.BuildConfig;

import android.annotation.SuppressLint;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.os.Environment;
import android.os.StatFs;
@SuppressWarnings("deprecation")
public class DataHelper {


	private static String TAG = "DataHelper";
	private static boolean DEBUG = false;
	private static final boolean NEED_CHECKSUM = true;
	public static String KEY_APP_VERSION_CODE = "KEY_APP_VERSION_CODE";
	public static String KEY_HAS_INSTALL_GAME = "KEY_HAS_INSTALL_GAME";
	public static String KEY_HAS_INSTALL_SDCARD = "KEY_HAS_INSTALL_SDCARD";
	private static String ZIP_FILE_NAME = "dragonfall.zip";
	private static final boolean USE_CRC32 = false;
	
	public static String PATH_BUNDLE_SUFFIX = "/batcatstudio/"+BuildConfig.GAME_ID+"/bundle";
	public static String PATH_DOCUMENTS_SUFFIX = "/batcatstudio/"+BuildConfig.GAME_ID+"/documents";
	
	private static String PREFERENCES_NAME = "com.batcatstudio.game.preferences." + BuildConfig.GAME_ID;
	
	public static final long ZIP_RESOURCE_SIZE = 74526711;

	private static int appVersionCode = -1;

	private static SharedPreferences preferences;
	
	private static Editor editor;
	
	public static void initHelper() {
		preferences = AppActivity.getGameActivity().getSharedPreferences(PREFERENCES_NAME, Context.MODE_PRIVATE);
		editor = preferences.edit();
		
		PackageManager pm = AppActivity.getGameActivity().getPackageManager();
		PackageInfo pi;
		try {
			pi = pm.getPackageInfo(AppActivity.getGameActivity().getPackageName(), 0);
			appVersionCode = pi.versionCode;
		} catch (NameNotFoundException e) {
			DebugUtil.LogException(TAG, e);
		}
	}
	
	public static SharedPreferences getSharedPreferences() {
		return preferences;
	}
	
	public static void unzipGameResource(final boolean installToSDCard) {
		saveBooleanValue(KEY_HAS_INSTALL_GAME, false);
		final String rootPath = getUnZipRootPath(installToSDCard);
		new Thread() {
			@SuppressWarnings("static-access")
			@Override
			public void run() {
				try {
					if(DEBUG){
						DebugUtil.LogDebug(TAG, "uzipGameData--->"+rootPath);
					}
				
					AppActivity.getGameActivity().gameHandler.sendEmptyMessage(AppActivity.AppActivityMessage.LOADING_UNZIP_SHOW.ordinal());
					deleteExistingAssetFile(installToSDCard,true);
					unzipAssetFile(AppActivity.getGameActivity(), ZIP_FILE_NAME, rootPath,
							true);
				} catch (Exception e) {
					DebugUtil.LogException(TAG, e);
					AppActivity.getGameActivity().runOnUiThread(new Runnable() {
						@Override
						public void run() {
							AppActivity.getGameActivity().showDialog(AppActivity.AppActivityDialog.DIALOG_UNZIP_FAILED.ordinal());
						}
					});
					return;
				}

				saveBooleanValue(KEY_HAS_INSTALL_GAME, true);
				saveBooleanValue(KEY_HAS_INSTALL_SDCARD, installToSDCard);
				saveIntValue(KEY_APP_VERSION_CODE, appVersionCode);
				AppActivity.getGameActivity().gameHandler.sendEmptyMessage(AppActivity.AppActivityMessage.LOADING_UNZIP_SUCCESS.ordinal());
			}
		}.start();
	}
	
	public static void deleteExistingAssetFile(boolean isSDCard,boolean needEraseSaveData) {
		String root = getUnZipRootPath(isSDCard);
		try {
			deleteFileRecursively(root + PATH_BUNDLE_SUFFIX);
			if (needEraseSaveData) {
				deleteFileRecursively(root + PATH_DOCUMENTS_SUFFIX);
			}
		} catch (Exception e) {
			DebugUtil.LogException(TAG, e);
		}
	}

	private static void deleteFileRecursively(String path) throws IOException {
		File f = new File(path);
		if (f.exists()) {
			if (f.isDirectory()) {
				File[] childFiles = f.listFiles();
				if (childFiles.length == 0) {
					if(DEBUG){
						DebugUtil.LogDebug(TAG, "delete directory: " + f.getPath());
					}
					final File to = new File(f.getAbsolutePath() + System.currentTimeMillis());  
					f.renameTo(to);  
					to.delete();  
				} else {
					for (int i = 0; i < childFiles.length; i++) {
						deleteFileRecursively(childFiles[i].getAbsolutePath());
					}
					if(DEBUG){
						DebugUtil.LogDebug(TAG, "delete directory: " + f.getPath());
					}
					final File to = new File(f.getAbsolutePath() + System.currentTimeMillis());  
					f.renameTo(to);  
					to.delete();  
				}
			} else {
					if(DEBUG){
						DebugUtil.LogDebug(TAG, "delete file: " + f.getPath());
					}
					final File to = new File(f.getAbsolutePath() + System.currentTimeMillis());  
					f.renameTo(to);  
					to.delete();  
			}
		} else {
			if(DEBUG){
				DebugUtil.LogDebug(TAG, "delete file does not exist: " + path);
			}
		}
	}
	
	/**
	 * unzip the zip file of assets to Folder
	 * 
	 * @param context
	 *            
	 * @param assetName
	 *            
	 * @param outputDirectory
	 *            
	 * @param isReWrite
	 *            
	 * @throws IOException
	 */
	@SuppressWarnings("static-access")
	public static void unzipAssetFile(Context context, String assetName, String outputDirectory, boolean isReWrite) throws IOException {
		File file = new File(outputDirectory);
		if (!file.exists()) {
			file.mkdirs();
		}

		InputStream inputStream = context.getAssets().open(assetName);
		if (NEED_CHECKSUM) {
			inputStream = new CheckedInputStream(inputStream, USE_CRC32 ? new CRC32() : new Adler32());
		}
		inputStream = new BufferedInputStream(inputStream);
		ZipInputStream zipInputStream = new ZipInputStream(inputStream);

		ZipEntry zipEntry = null;
		byte[] buffer = new byte[1024 * 20];
		int count = 0;
		int lastSetPercent = 0;
		float totalWriteCount = 0;
		while ((zipEntry = zipInputStream.getNextEntry()) != null) {
			// Folder
			if (zipEntry.isDirectory()) {
				file = new File(outputDirectory + File.separator + zipEntry.getName());
				// file is not exist or need rewrite
				if (isReWrite || !file.exists()) {
					file.mkdir();
				}
			} else {
				// file
				file = new File(outputDirectory + File.separator + zipEntry.getName());
				// file is not exist or need rewrite
				if (isReWrite || !file.exists()) {
					file.createNewFile();
					OutputStream outputStream = new FileOutputStream(file);
					if (NEED_CHECKSUM) {
						outputStream = new CheckedOutputStream(outputStream, USE_CRC32 ? new CRC32() : new Adler32());
					}
					outputStream = new BufferedOutputStream(outputStream);

					while ((count = zipInputStream.read(buffer)) > 0) {
						outputStream.write(buffer, 0, count);
						totalWriteCount += count;
						int currentPercent = (int) (totalWriteCount * 100 / ZIP_RESOURCE_SIZE);
						if (lastSetPercent != currentPercent) {
							AppActivity.getGameActivity().gameHandler.sendMessage(AppActivity.getGameActivity().gameHandler.obtainMessage(AppActivity.AppActivityMessage.LOADING_UNZIP_SET_PROGRESS.ordinal(), currentPercent, 0));
							lastSetPercent = currentPercent;
						}
					}
					outputStream.close();
				}
			}
		}
		zipInputStream.close();
	}


	public static boolean isExternalStorageMounted() {
		String state = Environment.getExternalStorageState();
		if(DEBUG){
			DebugUtil.LogDebug(TAG, "ExternalStorageState: " + state);
		}
		return state.compareTo(Environment.MEDIA_MOUNTED) == 0;
	}

	public static boolean isExternalStorageSpaceEnough() {
		long availableSize = getSDCardSize()[1];
		long needSize = ZIP_RESOURCE_SIZE;
		if(DEBUG){
			DebugUtil.LogVerbose(TAG, String.format("Available size: %d, need size: %d", availableSize, needSize));
		}
		return availableSize >= needSize;
	}

	public static boolean isInternalSpaceEnough() {
		long availableSize = getInternalSize()[1];
		long needSize = ZIP_RESOURCE_SIZE;
		if(DEBUG){
			DebugUtil.LogVerbose(TAG, String.format("Available size: %d, need size: %d", availableSize, needSize));
		}
		return availableSize >= needSize;
	}


	public static long[] getSDCardSize() {
		long[] sdCardInfo = new long[] { 0, 0 };
		if (isExternalStorageMounted()) {
			File sdcardDir = Environment.getExternalStorageDirectory();
			StatFs sf = new StatFs(sdcardDir.getPath());
			long bSize = sf.getBlockSize();
			long bCount = sf.getBlockCount();
			long availBlocks = sf.getAvailableBlocks();

			sdCardInfo[0] = bSize * bCount; //total size 
			sdCardInfo[1] = bSize * availBlocks;// available size
			if(DEBUG){
				DebugUtil.LogVerbose(TAG, String.format("ExternalStorage total_size: %d format: %s, availabe_size: %d format: %s",
							sdCardInfo[0], formatSize(sdCardInfo[0]), sdCardInfo[1], formatSize(sdCardInfo[1])));
			}
			
		}

		return sdCardInfo;
	}

	public static long[] getInternalSize() {
		long[] internalInfo = new long[] { 0, 0 };
			File internalDir = Environment.getDataDirectory();
			StatFs sf = new StatFs(internalDir.getPath());
			long bSize = sf.getBlockSize();
			long bCount = sf.getBlockCount();
			long availBlocks = sf.getAvailableBlocks();

			internalInfo[0] = bSize * bCount;//total size 
			internalInfo[1] = bSize * availBlocks;// available size
			if(DEBUG){
				DebugUtil.LogVerbose(TAG, String.format("internalInfo total_size: %d format: %s, availabe_size: %d format: %s",
							internalInfo[0], formatSize(internalInfo[0]), internalInfo[1], formatSize(internalInfo[1])));
			}
			

		return internalInfo;
	}

	public static String formatSize(long number) {
		return formatSize(number, false);
	}

	@SuppressLint("DefaultLocale")
	public static String formatSize(long number, boolean shorter) {
		float result = number;
		String suffix = "B";
		if (result > 900) {
			suffix = "KB";
			result = result / 1024;
		}
		if (result > 900) {
			suffix = "MB";
			result = result / 1024;
		}
		if (result > 900) {
			suffix = "GB";
			result = result / 1024;
		}
		if (result > 900) {
			suffix = "TB";
			result = result / 1024;
		}
		if (result > 900) {
			suffix = "PB";
			result = result / 1024;
		}

		String value = null;
		if (result < 1) {
			value = String.format("%.2f", result);
		} else if (result < 10) {
			if (shorter) {
				value = String.format("%.1f", result);
			} else {
				value = String.format("%.2f", result);
			}
		} else if (result < 100) {
			if (shorter) {
				value = String.format("%.0f", result);
			} else {
				value = String.format("%.2f", result);
			}
		} else {
			value = String.format("%.0f", result);
		}

		return value + suffix;
	}
	
	public static boolean isAppVersionExpired() {
		if (getSharedPreferences().getInt(KEY_APP_VERSION_CODE, -1) < appVersionCode) {
			return true;
		} else {
			return false;
		}
	}
	
	public static void saveBooleanValue(String key, boolean value) {
		editor.putBoolean(key, value);
		editor.commit();
	}

	public static void saveIntValue(String key, int value) {
		editor.putInt(key, value);
		editor.commit();
	}
	
	public static void saveStringValue(String key,String value) {
		editor.putString(key, value);
		editor.commit();
	}
	
	public static String readStringValue(String key) {
		return getSharedPreferences().getString(key, "");
	}
	
	public static String getUnZipRootPath(boolean isSDCard) {
		return isSDCard?Environment.getExternalStorageDirectory().getAbsolutePath():AppActivity.getGameActivity().getFilesDir().getAbsolutePath();
	}
	
	public static boolean hasInstallUnzip() {
		return getSharedPreferences().getBoolean(KEY_HAS_INSTALL_GAME, false);
	}
	
	public static boolean hasInstallToSdcard() {
		return getSharedPreferences().getBoolean(KEY_HAS_INSTALL_SDCARD, false);
	}
	
	public static void preInitActivityData() {
		boolean isInstallInSdCard = getSharedPreferences().getBoolean(KEY_HAS_INSTALL_SDCARD, false);
		Cocos2dxHelper.setCocos2dxBundlePath(getUnZipRootPath(isInstallInSdCard) + PATH_BUNDLE_SUFFIX);
		Cocos2dxHelper.setCocos2dxWritablePath(getUnZipRootPath(isInstallInSdCard) + PATH_DOCUMENTS_SUFFIX);
	}
	
}
