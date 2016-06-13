#include "cocos2d.h"
#include "FileOperation.h"
#include <string>
#if CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_WINRT || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID

#if CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
#include <copyfile.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#elif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include <android/log.h>
#define LOG_TAG ("FileOperation.cpp")
#define LOGI(...) ((void)__android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__))
#define LOGD(...) ((void)__android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, __VA_ARGS__))
#define LOGE(...) ((void)__android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__))
#define CLASS_NAME "com/batcatstudio/dragonfall/io/JniFileOperation"
#elif CC_TARGET_PLATFORM == CC_PLATFORM_WINRT
#include "pch.h"
#include <ppltasks.h>
#include <stdio.h>
#include "WinRTHelper.h"
using namespace cocos2d;
using namespace concurrency;
using namespace Windows::Storage;
using namespace Windows::Foundation;
#endif

using namespace std;

#if CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
typedef struct stat Stat;
static int do_mkdir(const char *path, mode_t mode)
{
	Stat            st;
	int             status = 0;

	if (stat(path, &st) != 0)
	{
		/* Directory does not exist. EEXIST for race condition */
		if (mkdir(path, mode) != 0 && errno != EEXIST)
			status = -1;
	}
	else if (!S_ISDIR(st.st_mode))
	{
		errno = ENOTDIR;
		status = -1;
	}

	return(status);
}

int mkpath(const char *path, mode_t mode)
{
	char           *pp;
	char           *sp;
	int             status;
	char           *copypath = strdup(path);

	status = 0;
	pp = copypath;
	while (status == 0 && (sp = strchr(pp, '/')) != 0)
	{
		if (sp != pp)
		{
			/* Neither root nor double slash in path */
			*sp = '\0';
			status = do_mkdir(copypath, mode);
			*sp = '/';
		}
		pp = sp + 1;
	}
	if (status == 0)
		status = do_mkdir(path, mode);
	free(copypath);
	return (status);
}
#endif /* CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_IOS */

bool FileOperation::createDirectory(const std::string& path){
#if CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
	int succ = mkpath(path.c_str(), S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);
	if(succ != 0){
		return false;
	}
	return true;
#elif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	cocos2d::JniMethodInfo t;
	jboolean ret = false;
	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "createDir", "(Ljava/lang/String;)Z")) {
		jstring jFilename =  t.env->NewStringUTF(path.c_str());
		ret = t.env->CallStaticBooleanMethod(t.classID, t.methodID,jFilename);
		t.env->DeleteLocalRef(jFilename);
		t.env->DeleteLocalRef(t.classID);
	}
	return ret;
#elif CC_TARGET_PLATFORM == CC_PLATFORM_WINRT
	return FileUtils::getInstance()->createDirectory(path);
#endif
}

bool FileOperation::removeDirectory(const std::string& path){
#if CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
	int succ = remove(path.c_str());
	if(succ != 0){
		return false;
	}
	return true;
#elif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	cocos2d::JniMethodInfo t;
	jboolean ret = false;
	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "removeDir", "(Ljava/lang/String;)Z")) {
		jstring jFilename =  t.env->NewStringUTF(path.c_str());
		ret = t.env->CallStaticBooleanMethod(t.classID, t.methodID,jFilename);
		t.env->DeleteLocalRef(jFilename);
		t.env->DeleteLocalRef(t.classID);
	}
	return ret;
#elif CC_TARGET_PLATFORM == CC_PLATFORM_WINRT
	return FileUtils::getInstance()->removeDirectory(path);
#endif
}

bool FileOperation::copyFile(const std::string& from, const std::string& to){
#if CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_IOS
	copyfile_state_t _copyfileState;
	_copyfileState = copyfile_state_alloc();
	mode_t processMask = umask(0);
	int ret = copyfile(from.c_str(), to.c_str(), _copyfileState, COPYFILE_ALL);
	umask(processMask);
	copyfile_state_free(_copyfileState);

	if (ret != 0 && (errno != EEXIST))
	{
		return false;
	}
	return true;
#elif CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	cocos2d::JniMethodInfo t;
	jboolean ret = false;
	if (cocos2d::JniHelper::getStaticMethodInfo(t, CLASS_NAME, "copyFileTo", "(Ljava/lang/String;Ljava/lang/String;)Z")) {
		jstring jfrom =  t.env->NewStringUTF(from.c_str());
		jstring jto =  t.env->NewStringUTF(to.c_str());
		ret = t.env->CallStaticBooleanMethod(t.classID, t.methodID,jfrom,jto);
		t.env->DeleteLocalRef(jfrom);
		t.env->DeleteLocalRef(jto);
		t.env->DeleteLocalRef(t.classID);
	}
	return ret;
#elif CC_TARGET_PLATFORM == CC_PLATFORM_WINRT
	std::wstring wfrom(from.begin(), from.end());
	std::wstring wto(to.begin(), to.end());
	return SUCCEEDED(CopyFile2(wfrom.c_str(), wto.c_str(), NULL)) ? true : false;
#endif
}
#endif // CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_IOS || CC_TARGET_PLATFORM == CC_PLATFORM_WINRT || CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
