APP_STL := gnustl_static

APP_CPPFLAGS := -frtti -DCC_ENABLE_CHIPMUNK_INTEGRATION=1 -std=c++11 -fsigned-char
APP_LDFLAGS := -latomic

COCOSTUDIO_JSON_USE_CONFIG_PNG_FILE := 1
USE_ETC1_TEXTURE_WITH_ALPHA_DATA := 1
CC_USE_CCBUILDER := 0
CC_USE_3D := 0
CC_USE_SQLITE := 0
CC_USE_PHYSICS := 0
CC_USE_SIMULATOR := 0
CC_USE_CURL := 1
CC_USE_NETWORK_SOKET := 1
CC_USE_SPINE := 0
CC_USE_ETC1_ZLIB := 1
CC_USE_POMELO_C_LIB := 0
CC_USE_FACEBOOK := 1
CC_USE_SDK_PAYPAL := 1

ifeq ($(CC_USE_SDK_PAYPAL),1)
APP_CPPFLAGS += -DCC_USE_SDK_PAYPAL=1
else
APP_CPPFLAGS += -DCC_USE_SDK_PAYPAL=0
endif

ifeq ($(CC_USE_FACEBOOK),1)
APP_CPPFLAGS += -DCC_USE_FACEBOOK=1
else
APP_CPPFLAGS += -DCC_USE_FACEBOOK=0
endif

ifeq ($(CC_USE_POMELO_C_LIB),1)
APP_CPPFLAGS += -DCC_USE_POMELO_C_LIB=1
else
APP_CPPFLAGS += -DCC_USE_POMELO_C_LIB=0
endif

ifeq ($(CC_USE_ETC1_ZLIB),1)
APP_CPPFLAGS += -DCC_USE_ETC1_ZLIB=1
else
APP_CPPFLAGS += -DCC_USE_ETC1_ZLIB=0
endif

ifeq ($(CC_USE_NETWORK_SOKET),1)
APP_CPPFLAGS += -DCC_USE_NETWORK_SOKET=1
else
APP_CPPFLAGS += -DCC_USE_NETWORK_SOKET=0
endif

ifeq ($(CC_USE_CURL),1)
APP_CPPFLAGS += -DCC_USE_CURL=1
else
APP_CPPFLAGS += -DCC_USE_CURL=0
endif

ifeq ($(CC_USE_SIMULATOR),1)
APP_CPPFLAGS += -DCC_USE_SIMULATOR=1
else
APP_CPPFLAGS += -DCC_USE_SIMULATOR=0
endif

ifeq ($(CC_USE_CCBUILDER),1)
APP_CPPFLAGS += -DCC_USE_CCBUILDER=1
else
APP_CPPFLAGS += -DCC_USE_CCBUILDER=0
endif

ifeq ($(CC_USE_3D),1)
APP_CPPFLAGS += -DCC_USE_3D=1
else
APP_CPPFLAGS += -DCC_USE_3D=0
endif

ifeq ($(CC_USE_SQLITE),1)
APP_CPPFLAGS += -DCC_USE_SQLITE=1
else
APP_CPPFLAGS += -DCC_USE_SQLITE=0
endif

ifeq ($(CC_USE_PHYSICS),1)
APP_CPPFLAGS += -DCC_USE_PHYSICS=1
else
APP_CPPFLAGS += -DCC_USE_PHYSICS=0
endif

ifeq ($(COCOSTUDIO_JSON_USE_CONFIG_PNG_FILE),1)
APP_CPPFLAGS += -DCOCOSTUDIO_JSON_USE_CONFIG_PNG_FILE=1
else
APP_CPPFLAGS += -DCOCOSTUDIO_JSON_USE_CONFIG_PNG_FILE=0
endif

ifeq ($(USE_ETC1_TEXTURE_WITH_ALPHA_DATA),1)
APP_CPPFLAGS += -DUSE_ETC1_TEXTURE_WITH_ALPHA_DATA=1
else
APP_CPPFLAGS += -DUSE_ETC1_TEXTURE_WITH_ALPHA_DATA=0
endif

ifeq ($(CC_USE_SPINE),1)
APP_CPPFLAGS += -DCC_USE_SPINE=1
else
APP_CPPFLAGS += -DCC_USE_SPINE=0
endif

ifeq ($(NDK_DEBUG),1)
  APP_CPPFLAGS += -DCOCOS2D_DEBUG=1
  APP_OPTIM := debug
else
  APP_CPPFLAGS += -DNDEBUG
  APP_OPTIM := release
endif
