package com.batcatstudio.dragonfall.io;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import org.cocos2dx.lua.AppActivity;

import android.content.res.AssetManager;

import com.batcatstudio.dragonfall.utils.DebugUtil;

public class JniFileOperation {
	private static String TAG = "JniFileOperation";

	public static boolean createDir(String path) {
		File file = new File(path);
		if (!file.exists()) {
			try {
				file.mkdirs();
			} catch (Exception e) {
				return false;
			}
		}
		return true;
	}

	private static boolean p_copyFileTo(File srcFile, File destFile)
			throws IOException {

		if (srcFile.isDirectory() || destFile.isDirectory())

			return false;// 判断是否是文件

		FileInputStream fis = new FileInputStream(srcFile);

		FileOutputStream fos = new FileOutputStream(destFile);

		int readLen = 0;

		byte[] buf = new byte[1024];

		while ((readLen = fis.read(buf)) != -1) {

			fos.write(buf, 0, readLen);

		}

		fos.flush();

		fos.close();

		fis.close();

		return true;

	}

	private static boolean delDir(File dir) {

		if (dir == null || !dir.exists() || dir.isFile()) {

			return false;

		}

		for (File file : dir.listFiles()) {

			if (file.isFile()) {

				file.delete();

			} else if (file.isDirectory()) {

				delDir(file);// 递归

			}

		}

		dir.delete();

		return true;

	}

	private static boolean copyAssetsFile(String from, String to)
			 {
		from = removeAssetsPrefix(from);
		InputStream myInput;
		OutputStream myOutput;
		AssetManager mAssetManager;
		try {
			myOutput = new FileOutputStream(to);
			mAssetManager = AppActivity.getGameActivity().getAssets();
			myInput = mAssetManager.open(from);
			byte[] buffer = new byte[1024];
			int length = myInput.read(buffer);
			while (length > 0) {
				myOutput.write(buffer, 0, length);
				length = myInput.read(buffer);
			}
			myOutput.flush();
			myInput.close();
			myOutput.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		}
		return true;
	}

	public static boolean copyFileTo(String from, String to) {
		

		if (from.contains("assets/")) {
			
			return copyAssetsFile(from,to);
		} else {
			File from_file = new File(from);
			File to_file = new File(to);
			try {
				if(!from_file.exists())
				{
					DebugUtil.LogWarn(TAG, "file not exist:"+from);
					return false;
				}
				return p_copyFileTo(from_file, to_file);
			} catch (IOException e) {
				DebugUtil.LogException(TAG, e);
				e.printStackTrace();
			}
		}
		return false;

	}

	private static String removeAssetsPrefix(String src) {
		return src.replace("assets/", "");
	}

	public static boolean removeDir(String path) {
		File dir = new File(path);
		return delDir(dir);
	}

}