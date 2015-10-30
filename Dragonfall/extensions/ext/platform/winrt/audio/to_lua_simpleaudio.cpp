#include "to_lua_simpleaudio.h"
#if CC_TARGET_PLATFORM == CC_PLATFORM_WINRT
#include "CCLuaValue.h"
#include "CCLuaStack.h"
#include "CCLuaEngine.h"
#include "tolua_fix.h"
#include "WinRTHelper.h"
#include "cocos2d.h"
#include "SimpleAudio.h"
#include "LuaBasicConversions.h"
#define USE_EXT_AUDIO 1 //switch use extension audio function

using namespace cocos2d;

void OnExtAudioPlayDone()
{
	auto stack = cocos2d::LuaEngine::getInstance()->getLuaStack();
	stack->executeGlobalFunction("__G_APP_BACKGROUND_MUSIC_COMPLETION");
}

static int tolua_simpleaudio_playBackGroundMusic(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isstring(tolua_S, 1, 0, &tolua_err) ||
		!tolua_isboolean(tolua_S, 2, 0, &tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		std::string path = tolua_tocppstring(tolua_S, 1, 0);
		bool loop = tolua_toboolean(tolua_S, 2, 0);
#if USE_EXT_AUDIO
		AudioExtension::SimpleAudio::Instance->playBackGroundMusic(WinRTHelper::PlatformStringFromString(path), loop);
#endif 
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(tolua_S, "#ferror in function 'tolua_simpleaudio_playBackGroundMusic'.", &tolua_err);
	return 0;
#endif
	return 0;
}

static int tolua_simpleaudio_stopBackGroundMusic(lua_State *tolua_S)
{
#if USE_EXT_AUDIO
	AudioExtension::SimpleAudio::Instance->stopBackGroundMusic();
#endif // USE_EXT_AUDIO
	return 0;
}

static int tolua_simpleaudio_setmusicVolume(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isnumber(tolua_S, 1, 0, &tolua_err)
		)
		goto tolua_lerror;
	else
#endif
	{
		int volume = tolua_tonumber(tolua_S, 1, 0);
		volume = volume > 1 ? 1.0 : volume;
		volume = volume < 0 ? 0 : volume;
#if USE_EXT_AUDIO
		AudioExtension::SimpleAudio::Instance->setVolume(volume);
#endif // USE_EXT_AUDIO
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(tolua_S, "#ferror in function 'tolua_simpleaudio_setmusicVolume'.", &tolua_err);
	return 0;
#endif
	return 0;
}

static int tolua_simpleaudio_playEffect(lua_State *tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (!tolua_isstring(tolua_S, 1, 0, &tolua_err))
		goto tolua_lerror;
	else
#endif
	{
		std::string path = tolua_tocppstring(tolua_S, 1, 0);
#if USE_EXT_AUDIO
		AudioExtension::SimpleAudio::Instance->playEffect(WinRTHelper::PlatformStringFromString(path));
#endif // USE_EXT_AUDIO
		return 0;
	}
#ifndef TOLUA_RELEASE
tolua_lerror :
	tolua_error(tolua_S, "#ferror in function 'tolua_simpleaudio_setmusicVolume'.", &tolua_err);
	return 0;
#endif
	return 0;
}


static int tolua_simpleaudio_stopAllEffects(lua_State *tolua_S)
{
#if USE_EXT_AUDIO
	AudioExtension::SimpleAudio::Instance->stopAllEffects();
#endif // 0
	return 0;
}

static int tolua_simpleaudio_pauseBackgroundMusic(lua_State *tolua_S)
{
#if USE_EXT_AUDIO
	AudioExtension::SimpleAudio::Instance->pauseBackgroundMusic();
#endif // USE_EXT_AUDIO
	return 0;
}

static int tolua_simpleaudio_resumeBackgroundMusic(lua_State *tolua_S)
{
#if USE_EXT_AUDIO
	AudioExtension::SimpleAudio::Instance->resumeBackgroundMusic();
#endif // 0
	return 0;
}

static int tolua_simpleaudio_pauseAllEffects(lua_State *tolua_S)
{
#if USE_EXT_AUDIO
	AudioExtension::SimpleAudio::Instance->pauseAllEffects();
#endif // USE_EXT_AUDIO
	return 0;
}


static int tolua_simpleaudio_resumeAllEffectss(lua_State *tolua_S)
{
#if USE_EXT_AUDIO
	AudioExtension::SimpleAudio::Instance->resumeAllEffects();
#endif // USE_EXT_AUDIO
	return 0;
}

static int tolua_simpleaudio_getVolume(lua_State *tolua_S)
{
#if USE_EXT_AUDIO
	float val = AudioExtension::SimpleAudio::Instance->getVolume();
	tolua_pushnumber(tolua_S, val);
	return 1;
#else
	return 0;
#endif // USE_EXT_AUDIO
}

static int tolua_simpleaudio_isMusicPlaying(lua_State *tolua_S)
{
#if USE_EXT_AUDIO
	bool val = AudioExtension::SimpleAudio::Instance->isMusicPlaying();
	tolua_pushboolean(tolua_S, val);
	return 1;
#else
	return 0;
#endif // USE_EXT_AUDIO
}

void tolua_ext_module_audio(lua_State* tolua_S)
{
	tolua_module(tolua_S, EXT_MODULE_NAME, 0);
	tolua_beginmodule(tolua_S, EXT_MODULE_NAME);
	tolua_function(tolua_S, "playMusic", tolua_simpleaudio_playBackGroundMusic);
	tolua_function(tolua_S, "stopMusic", tolua_simpleaudio_stopBackGroundMusic);
	tolua_function(tolua_S, "setMusicVolume", tolua_simpleaudio_setmusicVolume);
	tolua_function(tolua_S, "playEffect", tolua_simpleaudio_playEffect);
	tolua_function(tolua_S, "stopAllEffects", tolua_simpleaudio_stopAllEffects);
	tolua_function(tolua_S, "pauseMusic", tolua_simpleaudio_pauseBackgroundMusic);
	tolua_function(tolua_S, "resumeMusic", tolua_simpleaudio_resumeBackgroundMusic);
	tolua_function(tolua_S, "pauseAllSounds", tolua_simpleaudio_pauseAllEffects);
	tolua_function(tolua_S, "resumeAllSounds", tolua_simpleaudio_resumeAllEffectss);
	tolua_function(tolua_S, "getMusicVolume", tolua_simpleaudio_getVolume);
	tolua_function(tolua_S, "isMusicPlaying", tolua_simpleaudio_isMusicPlaying);
	tolua_endmodule(tolua_S);
}
#endif // CC_TARGET_PLATFORM == CC_PLATFORM_WINRT
