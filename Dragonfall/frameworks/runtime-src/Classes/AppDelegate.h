#ifndef __APP_DELEGATE_H__
#define __APP_DELEGATE_H__

#include "cocos2d.h"

/**
@brief    The cocos2d Application.

The reason for implement as private inheritance is to hide some interface call by Director.
*/
class  AppDelegate : private cocos2d::Application
{
public:
    AppDelegate();
    virtual ~AppDelegate();

    virtual void initGLContextAttrs();

    /**
    @brief    Implement Director and Scene init code here.
    @return true    Initialize success, app continue.
    @return false   Initialize failed, app terminate.
    */
    virtual bool applicationDidFinishLaunching();

    /**
    @brief  The function be called when the application enter background
    @param  the pointer of the application
    */
    virtual void applicationDidEnterBackground();

    /**
    @brief  The function be called when the application enter foreground
    @param  the pointer of the application
    */
    virtual void applicationWillEnterForeground();
};
#if CC_TARGET_PLATFORM == CC_PLATFORM_WINRT || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
class AppDelegateExtern : public cocos2d::Ref
{
public:
    AppDelegateExtern(){};
    ~AppDelegateExtern(){};
    void restartGame(float dt);
    static void initLuaEngine();
    static void loadConfigFile();
    static bool checkPath();
	static std::string getAppVersion();
    static bool isNotUpdate();
    static void extendApplication();
    static std::string getGameZipcrc32(const char *filePath);
};
#endif

#endif  // __APP_DELEGATE_H__

