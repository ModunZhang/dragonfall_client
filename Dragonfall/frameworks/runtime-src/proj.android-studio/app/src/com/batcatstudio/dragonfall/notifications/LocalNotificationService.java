package com.batcatstudio.dragonfall.notifications;

import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;

import org.cocos2dx.lua.AppActivity;

import com.batcatstudio.dragonfall.utils.DebugUtil;
import com.xapcn.dragonfall.R;

import android.annotation.SuppressLint;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.os.IBinder;

public class LocalNotificationService extends Service {

    private static final String TAG = "LocalNotification";
    public static final String KEY_NOTIFICATION_CONTENTS = "NOTIFICATION_CONTENTS";
    public static final String KEY_NOTIFICATION_TIMES = "NOTIFICATION_TIMES";

    private NotificationManager notificationManager;

    private CharSequence notifyTitle;

    private Timer notifyTaskTimer;

    private long latestTime = 0;

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        super.onCreate();
        DebugUtil.LogDebug(TAG, "onCreate----------->");
        notificationManager = (NotificationManager) getSystemService(NOTIFICATION_SERVICE);
        notifyTitle = getText(R.string.app_name);
    }

    @Override
    public void onDestroy() {
        if (notifyTaskTimer != null) {
            notifyTaskTimer.cancel();
            notifyTaskTimer.purge();
            notifyTaskTimer = null;
        }
        super.onDestroy();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
    	DebugUtil.LogDebug(TAG, "onStartCommand----------->");
        if (!canStartNotification(intent, flags)) {

            stopSelf();
            return START_NOT_STICKY;
        }

        final String[] notificationContents = intent.getStringArrayExtra(KEY_NOTIFICATION_CONTENTS);
        long[] notificationTimes = intent.getLongArrayExtra(KEY_NOTIFICATION_TIMES);
        notifyTaskTimer = new Timer("LocalNotificationService Timer", true);
        for (int i = 0; i < notificationContents.length; i++) {
            long notifyTime = notificationTimes[i];
            if (latestTime < notifyTime) { // 记录最晚的通知的时间，用于关闭自己
                latestTime = notifyTime;
            }

            Date when = new Date(notifyTime);
            notifyTaskTimer.schedule(getTimerTask(getNotificationId(i), notificationContents[i], notifyTime), when);
        }

        return START_REDELIVER_INTENT;
    }
    private boolean canStartNotification(Intent intent, int flags) {
        boolean result = true;
        if (intent == null) {
            result = false;
        } else {
            if (intent.getStringArrayExtra(KEY_NOTIFICATION_CONTENTS) == null
                    || intent.getLongArrayExtra(KEY_NOTIFICATION_TIMES) == null) {
                result = false;
            }
        }
        return result;
    }
    private TimerTask getTimerTask(final int id, final String content, final long notifyTime) {
        return new TimerTask() {
            @Override
            public void run() {
                Notification notification = getNotification(content, notifyTime);
                if(null!=notification) notificationManager.notify(id, notification);
                if (notifyTime >= latestTime) { // 所有通知已发送完，关闭自己
                    LocalNotificationService.this.stopSelf();
                }
            }
        };
    }
    @SuppressLint("NewApi")
    private Notification getNotification(String content, long notifyTime) {
        try{
            Notification.Builder builder = new Notification.Builder(this)
                    .setContentTitle(notifyTitle)
                    .setContentText(content)
                    .setContentIntent(getPendingIntent())
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .setWhen(notifyTime);
            Notification notification = builder.getNotification();

            notification.defaults = Notification.DEFAULT_SOUND;
            notification.flags |= Notification.FLAG_AUTO_CANCEL;
            notification.flags |= Notification.FLAG_SHOW_LIGHTS;
            return notification;
        }
        catch(SecurityException e)
        {
            DebugUtil.LogException(TAG,e);
        }
        return null;
    }

    private PendingIntent getPendingIntent() {
        Intent intent = new Intent(this, AppActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
        return PendingIntent.getActivity(this, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT);
    }
    private int getNotificationId(int id) {
        return id + 100;
    }

}