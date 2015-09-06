LOCAL_PATH := $(call my-dir)
 
include $(CLEAR_VARS)

LOCAL_MODULE := cocos2dlua_shared

LOCAL_MODULE_FILENAME := libcocos2dlua

LOCAL_SRC_FILES := \
../../Classes/AppDelegate.cpp \
../../Classes/ide-support/SimpleConfigParser.cpp \
hellolua/main.cpp \
../../../../extensions/ext/LuaExtension.cpp \
../../../../extensions/ext/crc/crc32.c \
../../../../extensions/ext/sysmail/ext_sysmail.cpp \
../../../../extensions/ext/sysmail/Sysmail.cpp \
../../../../extensions/ext/LocalNotification/ext_local_push.cpp \
../../../../extensions/ext/LocalNotification/LocalNotification.cpp \
../../../../extensions/sdk/libpomelo/CCPomelo.cpp \
../../../../extensions/sdk/MarketSDKTool-android.cpp \

MY_FILES_PATH  :=  $(LOCAL_PATH)/../../../../extensions/ext/jni

MY_FILES_SUFFIX := %.cpp 

My_All_Files := $(foreach src_path,$(MY_FILES_PATH), $(shell find "$(src_path)" -type f) ) 
My_All_Files := $(My_All_Files:$(MY_CPP_PATH)/./%=$(MY_CPP_PATH)%)
MY_SRC_LIST  := $(filter $(MY_FILES_SUFFIX),$(My_All_Files)) 
MY_SRC_LIST  := $(MY_SRC_LIST:$(LOCAL_PATH)/%=%)
LOCAL_SRC_FILES += $(MY_SRC_LIST)

$(warning $(MY_SRC_LIST))

LOCAL_C_INCLUDES := \
$(LOCAL_PATH)/../../Classes/protobuf-lite \
$(LOCAL_PATH)/../../Classes/runtime \
$(LOCAL_PATH)/../../Classes \
$(LOCAL_PATH)/../../../cocos2d-x/external \
$(LOCAL_PATH)/../../../cocos2d-x/tools/simulator/libsimulator/lib \
$(LOCAL_PATH)/../../../../extensions/ext \
$(LOCAL_PATH)/../../../../extensions/sdk \
$(LOCAL_PATH)/../../../../extensions/ext/jni \
$(LOCAL_PATH)/../../../../extensions/sdk/libpomelo \
$(LOCAL_PATH)/../../../../extensions/ext/sysmail \
$(LOCAL_PATH)/../../../../extensions/ext/LocalNotification \

# _COCOS_HEADER_ANDROID_BEGIN
# _COCOS_HEADER_ANDROID_END

LOCAL_STATIC_LIBRARIES := cocos2d_lua_static
LOCAL_STATIC_LIBRARIES += cocos2d_simulator_static
LOCAL_STATIC_LIBRARIES += pomelo_static

# _COCOS_LIB_ANDROID_BEGIN
LOCAL_STATIC_LIBRARIES += quick_libs_static
# _COCOS_LIB_ANDROID_END

include $(BUILD_SHARED_LIBRARY)

$(call import-module,libpomelo)
$(call import-module,scripting/lua-bindings/proj.android)
$(call import-module,tools/simulator/libsimulator/proj.android)

# _COCOS_LIB_IMPORT_ANDROID_BEGIN
$(call import-module,proj.android)
# _COCOS_LIB_IMPORT_ANDROID_END
