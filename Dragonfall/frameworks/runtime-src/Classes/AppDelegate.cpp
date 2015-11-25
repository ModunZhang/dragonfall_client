#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#include "lua_module_register.h"
#include "LuaExtension.h"
#include "2d/CCFontFNT.h"
#include "2d/CCFontAtlasCache.h"
//json
#include "../cocos2d-x/external/json/document.h"
#include "../cocos2d-x/external/json/rapidjson.h"

//extension header
#include "CommonUtils.h"
#include "FileOperation.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WINRT)
#include "WinRTHelper.h"
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#define LOG_TAG ("AppDelegate.cpp")
#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__))
#define LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__))
#endif

using namespace CocosDenshion;

USING_NS_CC;
using namespace std;
static  std::vector<std::string> default_file_util_search_pahts;
AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
}

//if you want a different context,just modify the value of glContextAttrs
//it will takes effect on all platforms
void AppDelegate::initGLContextAttrs()
{
    //set OpenGL context attributions,now can only set six attributions:
    //red,green,blue,alpha,depth,stencil
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8};

    GLView::setGLContextAttrs(glContextAttrs);
}

// If you want to use packages manager to install more packages, 
// don't modify or remove this function
static int register_all_packages()
{
    extern void package_quick_register();
	package_quick_register();
	return 0; //flag for packages manager
}

bool AppDelegate::applicationDidFinishLaunching()
{
    // set default FPS
    Director::getInstance()->setAnimationInterval(1.0 / 60.0f);

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_WINRT)
    AppDelegateExtern::initLuaEngine();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    AndroidCheckFistInstall();
#else
	//normal execute lua file
	auto engine = LuaEngine::getInstance();
	ScriptEngineManager::getInstance()->setScriptEngine(engine);
	lua_State* L = engine->getLuaStack()->getLuaState();
	lua_module_register(L);
	tolua_cc_lua_extension(L);
	register_all_packages();
	
	LuaStack* stack = engine->getLuaStack();
	stack->setXXTEAKeyAndSign("2dxLua", strlen("2dxLua"), "XXTEA", strlen("XXTEA"));
	    
	if (engine->executeScriptFile("scripts/main.lua"))
	{
	    return false;
	}

#endif
    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();
    Director::getInstance()->pause();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    SimpleAudioEngine::getInstance()->resumeAllEffects();
#elif (CC_TARGET_PLATFORM != CC_PLATFORM_WINRT)
    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
    SimpleAudioEngine::getInstance()->pauseAllEffects();
#endif
	Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("APP_ENTER_BACKGROUND_EVENT");
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->resume();
    Director::getInstance()->startAnimation();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    SimpleAudioEngine::getInstance()->pauseAllEffects();
#elif (CC_TARGET_PLATFORM != CC_PLATFORM_WINRT)
    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
    SimpleAudioEngine::getInstance()->resumeAllEffects();
#endif

	Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("APP_ENTER_FOREGROUND_EVENT");
}


//MARK:Extern
#if CC_TARGET_PLATFORM == CC_PLATFORM_WINRT || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
void AppDelegateExtern::restartGame(float dt)
{
    initLuaEngine();
}


void AppDelegateExtern::extendApplication()
{
    //register custom function
    lua_State* tolua_S = LuaEngine::getInstance()->getLuaStack()->getLuaState();
    tolua_cc_pomelo_open(tolua_S);
    tolua_cc_lua_extension(tolua_S);
}

void AppDelegateExtern::purgeAllCachedData()
{
	FontFNT::purgeCachedData();
	FontAtlasCache::purgeCachedData();
	SpriteFrameCache::getInstance()->removeSpriteFrames();
	TextureCache::getInstance()->removeAllTextures();
	FileUtils::getInstance()->purgeCachedEntries();
	//maybe we need free audio resources
}

void AppDelegateExtern::initLuaEngine()
{
    Director::getInstance()->stopAnimation();
    Director::getInstance()->pause();
	purgeAllCachedData();
    FileUtils::getInstance()->setSearchPaths(default_file_util_search_pahts); //还原搜索路径
    ScriptEngineManager::getInstance()->removeScriptEngine();
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    extendApplication();
    
    // register lua module
    lua_State* L = engine->getLuaStack()->getLuaState();
    lua_module_register(L);
    register_all_packages();
    
    LuaStack* stack = engine->getLuaStack();
    stack->setXXTEAKeyAndSign("Cbcm78HuH60MCfA7", strlen("Cbcm78HuH60MCfA7"), "XXTEA", strlen("XXTEA"));
    
    string path = FileUtils::getInstance()->fullPathForFilename("scripts/game.zip");//in bundle
    bool use_bundle_zip = true;
    loadConfigFile();
    use_bundle_zip = checkPath();
    stack->reload("config");
    Director::getInstance()->resume();
    Director::getInstance()->startAnimation();
    if (use_bundle_zip)
    {
        stack->loadChunksFromZIP(path.c_str());
    }
    else
    {
        //in document
        path = FileUtils::getInstance()->fullPathForFilename("scripts/game.zip");
        stack->loadChunksFromZIP(path.c_str());
    }
    stack->executeString("require 'main'");
}

void AppDelegateExtern::loadConfigFile()
{
    LuaStack* stack = LuaEngine::getInstance()->getLuaStack();
    stack->executeChunkFromZip("scripts/game.zip", "config");
    stack->executeString("require 'config'");
}

std::string AppDelegateExtern::getAppVersion()
{
	std::string ipaVersion = GetAppVersion();
	return ipaVersion;
}


bool AppDelegateExtern::isNotUpdate()
{
    lua_State* tolua_S = LuaEngine::getInstance()->getLuaStack()->getLuaState();
    lua_getglobal(tolua_S, "CONFIG_IS_NOT_UPDATE");
    if(lua_isboolean(tolua_S, -1) && lua_toboolean(tolua_S, -1))
    {
        return true;
    }
    return false;
}

string AppDelegateExtern::getGameZipcrc32(const char *filePath)
{
    FileUtils *fileUtils = FileUtils::getInstance();
    if (fileUtils->isFileExist(filePath))
    {
        string json_contents = fileUtils->getStringFromFile(filePath);
        if (json_contents.length()>0)
        {
            rapidjson::Document d;
            d.Parse<0>(json_contents.c_str());
            if (d.HasParseError())
            {
                CCLOG("GetParseError %s %s\n",filePath,d.GetParseError());
                return filePath;
            }
            else
            {
                if(d.HasMember("files"))
                {
                    const rapidjson::Value &files=d["files"];
                    rapidjson::Value::ConstMemberIterator it = files.MemberonBegin();
                    
                    for (; it !=files.MemberonEnd(); ++it)
                    {
                        string name = it->name.GetString();
                        size_t pos = name.rfind("game.zip");
                        if (pos != std::string::npos)
                        {
                            const rapidjson::Value & tagData = it->value;
                            if(tagData.HasMember("crc32"))
                            {
                                string crc32 = tagData["crc32"].GetString();
                                return crc32;
                            }
                        }
                        
                    }
                }
            }
        }
        
    }
    return filePath;
}

bool AppDelegateExtern::checkPath()
{
    bool need_Load_zip_from_bundle = false;
    FileUtils* fileUtils = FileUtils::getInstance();
	std::string appVersion = getAppVersion();
    string writePath = fileUtils->getWritablePath();
    
    string updatePath = writePath + "update/";
    string appPath = updatePath + appVersion + "/";
    
    if(!fileUtils->isDirectoryExist(appPath)){
        if(fileUtils->isDirectoryExist(updatePath)){
			FileOperation::removeDirectory(updatePath);
        }
		FileOperation::createDirectory(updatePath);
		FileOperation::createDirectory(appPath);
    }
    string resPath = appPath + "res/";
    string scriptsPath = appPath + "scripts/";
    if (!fileUtils->isDirectoryExist(resPath)) {
		FileOperation::createDirectory(resPath);
    }
    if (!fileUtils->isDirectoryExist(scriptsPath)) {
		FileOperation::createDirectory(scriptsPath);
    }
    string from = FileUtils::getInstance()->fullPathForFilename("res/fileList.json");
    string to = appPath + "res/fileList.json";
    if (!FileUtils::getInstance()->isFileExist(to)) {
		FileOperation::copyFile(from, to);
    }
    
    string doucument_zip_path = scriptsPath + "game.zip";
    if (!fileUtils->isFileExist(doucument_zip_path))
    {
        need_Load_zip_from_bundle = true;
        //还原版本信息重新执行自动更新
        if (FileUtils::getInstance()->isFileExist(from)) {
			FileOperation::copyFile(from, to);
        }
    }
    else
    {
        //验证zip完整性
        //获取game.zip crc32 fileList
        unsigned long crc32 = getFileCrc32(doucument_zip_path.c_str());
        string crc32_in_config = getGameZipcrc32(to.c_str());
        char crc32_val[32];
        sprintf(crc32_val, "%08lx", crc32);
        if (strcmp(crc32_val, crc32_in_config.c_str()) != 0)
        {
            need_Load_zip_from_bundle = true;
            //还原版本信息重新执行自动更新
            if (FileUtils::getInstance()->isFileExist(from)) {
				FileOperation::copyFile(from, to);
            }
        }
        else
        {
            need_Load_zip_from_bundle = false;
        }
        
    }
    std::vector<std::string> paths = fileUtils->getSearchPaths();
    if (isNotUpdate())
    {
        paths.insert(paths.begin(), "res/images");
        paths.insert(paths.begin(), "res/");
        fileUtils->setSearchPaths(paths);
        need_Load_zip_from_bundle = true; //如果关闭自动更新 强制使用bundle里的包
    }
    else
    {
        paths.insert(paths.begin(), "res/images/");
        paths.insert(paths.begin(), "res/");
        paths.insert(paths.begin(), (resPath + "images/").c_str());
        paths.insert(paths.begin(), resPath.c_str());
        paths.insert(paths.begin(), appPath.c_str());
        fileUtils->setSearchPaths(paths);
    }
    
    //update lua path
    //in documents
    
    LuaStack* pStack = LuaEngine::getInstance()->getLuaStack();
    size_t pos;
    while ((pos = scriptsPath.find_first_of("\\")) != std::string::npos)
    {
        scriptsPath.replace(pos, 1, "/");
    }
    size_t p = scriptsPath.find_last_of("/\\");
    if (p != scriptsPath.npos)
    {
        const string dir = scriptsPath.substr(0, p);
        pStack->addSearchPath(dir.c_str());
        
        p = dir.find_last_of("/\\");
        if (p != dir.npos)
        {
            pStack->addSearchPath(dir.substr(0, p).c_str());
        }
    }
    return need_Load_zip_from_bundle;
}
#endif
/************************************************************************/
/* Android                                                              */
/************************************************************************/
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
extern "C"
{
    //启动游戏
    void Java_com_batcatstudio_dragonfall_utils_LaunchHelper_nativeInitLuaEngine(JNIEnv *env, jobject thisz,jstring bundlePath)
    {
        std::string bundle_path("");
        bundle_path = cocos2d::JniHelper::jstring2string(bundlePath);

        std::vector<std::string> paths;
        bundle_path = bundle_path + "/";
        FileUtils::getInstance()->setDefaultResourceRootPath(bundle_path.c_str());
        FileUtils::getInstance()->setSearchPaths(paths);
        default_file_util_search_pahts = paths;
        AppDelegateExtern::initLuaEngine();
    }
    //发送游戏自定义事件(暂时只会发送 进入/退出后台的事件，与iOS统一)
    void Java_org_cocos2dx_lua_AppActivity_dispatchGameEvent(JNIEnv *env, jobject thisz,jstring jgameEventName)
    {
        std::string eventName("");
        eventName = cocos2d::JniHelper::jstring2string(jgameEventName);
        if(eventName.length() > 0)
        {
            Director::getInstance()->getEventDispatcher()->dispatchCustomEvent(eventName);
        }
    }
    //音乐结束回调
    void Java_org_cocos2dx_lib_Cocos2dxMusic_onBackgroundMusicCompletion(JNIEnv *env, jobject thisz)
    {
        Director::getInstance()->getEventDispatcher()->dispatchCustomEvent("APP_BACKGROUND_MUSIC_COMPLETION");
    }
}
#endif
