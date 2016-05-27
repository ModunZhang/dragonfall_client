LOCAL_PATH := $(call my-dir)
 
include $(CLEAR_VARS)

PATH_SUFF := ../

LOCAL_MODULE := cocos2dlua_shared

LOCAL_MODULE_FILENAME := libcocos2dlua

LOCAL_SRC_FILES := \
$(PATH_SUFF)../../Classes/AppDelegate.cpp \
$(PATH_SUFF)../../Classes/ide-support/SimpleConfigParser.cpp \
hellolua/main.cpp \
$(PATH_SUFF)../../../../extensions/ext/common/CommonUtils-android.cpp \
$(PATH_SUFF)../../../../extensions/ext/LuaExtension.cpp \
$(PATH_SUFF)../../../../extensions/ext/crc/crc32.c \
$(PATH_SUFF)../../../../extensions/ext/sysmail/Sysmail-android.cpp \
$(PATH_SUFF)../../../../extensions/ext/sysmail/tolua_sysmail.cpp \
$(PATH_SUFF)../../../../extensions/ext/notification/tolua_local_push.cpp \
$(PATH_SUFF)../../../../extensions/ext/io/FileOperation.cpp \
$(PATH_SUFF)../../../../extensions/ext/notification/LocalNotification-android.cpp \
$(PATH_SUFF)../../../../extensions/sdk/MarketSDKTool-android.cpp \
$(PATH_SUFF)../../../../extensions/ext/platform/android/jni_StoreKit.cpp

ifeq ($(CC_USE_SDK_PAYPAL),1)
LOCAL_SRC_FILES += $(PATH_SUFF)../../../../extensions/sdk/PayPal/PayPalSDK-android.cpp
endif

ifeq ($(CC_USE_FACEBOOK),1)
LOCAL_SRC_FILES += $(PATH_SUFF)../../../../extensions/sdk/Facebook/FacebookSDK-android.cpp \
$(PATH_SUFF)../../../../extensions/sdk/Facebook/tolua_fb_sdk.cpp
endif

ifeq ($(CC_USE_POMELO_C_LIB),1)
LOCAL_SRC_FILES += $(PATH_SUFF)../../../../extensions/sdk/libpomelo/CCPomelo.cpp
endif

ifeq ($(CC_USE_GOOGLE_LOGIN),1)
LOCAL_SRC_FILES += $(PATH_SUFF)../../../../extensions/sdk/GoogleSign/GoogleSignSDK-android.cpp
endif

#MY_FILES_PATH  :=  $(LOCAL_PATH)/../../../../extensions/ext/platform/android

#MY_FILES_SUFFIX := %.cpp 

#My_All_Files := $(foreach src_path,$(MY_FILES_PATH), $(shell find "$(src_path)" -type f) ) 
#My_All_Files := $(My_All_Files:$(MY_CPP_PATH)/./%=$(MY_CPP_PATH)%)
#MY_SRC_LIST  := $(filter $(MY_FILES_SUFFIX),$(My_All_Files)) 
#MY_SRC_LIST  := $(MY_SRC_LIST:$(LOCAL_PATH)/%=%)
#LOCAL_SRC_FILES += $(MY_SRC_LIST)

$(warning APP_CPPFLAGS:$(APP_CPPFLAGS))
LOCAL_C_INCLUDES := \
$(LOCAL_PATH)/$(PATH_SUFF)../../Classes/protobuf-lite \
$(LOCAL_PATH)/$(PATH_SUFF)../../Classes/runtime \
$(LOCAL_PATH)/$(PATH_SUFF)../../Classes \
$(LOCAL_PATH)/$(PATH_SUFF)../../../cocos2d-x/external \
$(LOCAL_PATH)/$(PATH_SUFF)../../../cocos2d-x/tools/simulator/libsimulator/lib \
$(LOCAL_PATH)/$(PATH_SUFF)../../../../extensions/ext \
$(LOCAL_PATH)/$(PATH_SUFF)../../../../extensions/sdk \
$(LOCAL_PATH)/$(PATH_SUFF)../../../../extensions/sdk/GoogleSign \
$(LOCAL_PATH)/$(PATH_SUFF)../../../../extensions/sdk/Facebook \
$(LOCAL_PATH)/$(PATH_SUFF)../../../../extensions/sdk/PayPal \
$(LOCAL_PATH)/$(PATH_SUFF)../../../../extensions/ext/platform/android \
$(LOCAL_PATH)/$(PATH_SUFF)../../../../extensions/ext/common \
$(LOCAL_PATH)/$(PATH_SUFF)../../../../extensions/ext/io \
$(LOCAL_PATH)/$(PATH_SUFF)../../../../extensions/ext/sysmail \
$(LOCAL_PATH)/$(PATH_SUFF)../../../../extensions/ext/notification

ifeq ($(CC_USE_POMELO_C_LIB),1)
LOCAL_C_INCLUDES += $(LOCAL_PATH)/$(PATH_SUFF)../../../../extensions/sdk/libpomelo
endif

# _COCOS_HEADER_ANDROID_BEGIN
# _COCOS_HEADER_ANDROID_END

LOCAL_STATIC_LIBRARIES := cocos2d_lua_static

ifeq ($(CC_USE_SIMULATOR),1)
LOCAL_STATIC_LIBRARIES += cocos2d_simulator_static
endif

ifeq ($(CC_USE_POMELO_C_LIB),1)
LOCAL_STATIC_LIBRARIES += pomelo_static
endif

# _COCOS_LIB_ANDROID_BEGIN
LOCAL_STATIC_LIBRARIES += quick_libs_static
# _COCOS_LIB_ANDROID_END

# Bugly
LOCAL_STATIC_LIBRARIES += bugly_crashreport_cocos_static

include $(BUILD_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := Bugly
LOCAL_SRC_FILES := prebuilt/$(TARGET_ARCH_ABI)/libBugly.so
include $(PREBUILT_SHARED_LIBRARY)


ifeq ($(CC_USE_POMELO_C_LIB),1)
$(call import-module,libpomelo)
endif

$(call import-module,scripting/lua-bindings/proj.android)
ifeq ($(CC_USE_SIMULATOR),1)
$(call import-module,tools/simulator/libsimulator/proj.android)
endif
# _COCOS_LIB_IMPORT_ANDROID_BEGIN
$(call import-module,proj.android)
# _COCOS_LIB_IMPORT_ANDROID_END
# Bugly
$(call import-module,external/bugly)
