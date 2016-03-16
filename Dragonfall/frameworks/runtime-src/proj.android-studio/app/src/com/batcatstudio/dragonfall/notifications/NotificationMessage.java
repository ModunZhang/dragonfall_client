package com.batcatstudio.dragonfall.notifications;
/**
 * Created by dannyhe on 7/27/15.
 */
public class NotificationMessage {
    private String alertBody;
    private long fireTime;
    private String msgType;

    public NotificationMessage(String alertBody, long fireTime, String msgType) {
        this.alertBody = alertBody;
        this.fireTime = fireTime;
        this.msgType = msgType;
    }

    public NotificationMessage(String alertBody, long fireTime) {
        this.alertBody = alertBody;
        this.fireTime = fireTime;
        this.msgType = "none";
    }

    public String getAlertBody() {
        return alertBody;
    }

    public long getFireTime() {
        return fireTime;
    }

    public String getMsgType() {
        return msgType;
    }
}
