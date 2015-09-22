LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE := cocos_network_static

LOCAL_MODULE_FILENAME := libnetwork

LOCAL_SRC_FILES := 
ifeq ($(CC_USE_NETWORK_SOKET),1)
LOCAL_SRC_FILES += \
SocketIO.cpp \
WebSocket.cpp 
endif

ifeq ($(CC_USE_CURL),1)
LOCAL_SRC_FILES += HttpClient-android.cpp
endif

LOCAL_EXPORT_C_INCLUDES :=

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../external/curl/include/android \
                    $(LOCAL_PATH)/../../external/websockets/include/android

LOCAL_STATIC_LIBRARIES := cocos2dx_internal_static
ifeq ($(CC_USE_CURL),1)
LOCAL_STATIC_LIBRARIES += cocos_curl_static
endif
#test it? dannyhe
ifeq ($(CC_USE_NETWORK_SOKET),1)
LOCAL_STATIC_LIBRARIES += libwebsockets_static
endif
include $(BUILD_STATIC_LIBRARY)
