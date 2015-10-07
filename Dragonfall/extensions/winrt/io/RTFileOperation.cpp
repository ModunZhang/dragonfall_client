#include "pch.h"
#include "RTFileOperation.h"
#include "NativeDelegate.h"
#include "ppltasks.h"
#include "cocos2d.h"
#include <stdio.h>
#include <string>
using namespace cocos2d;
using namespace concurrency;
using namespace Windows::Storage;
using namespace Windows::Foundation;
RTFileOperation::RTFileOperation()
{
}
static void GetFileFolderFromPath(std::string &path)
{
	std::size_t found = path.rfind("/");
	if (found != std::string::npos)
	{
		path.erase(found);
	}
}

static inline std::string convertPathFormatToWinStyle(const std::string& path)
{
	std::string ret = path;
	int len = ret.length();
	for (int i = 0; i < len; ++i)
	{
		if (ret[i] == '/')
		{
			ret[i] = '\\';
		}
	}
	return ret;
}


bool RTFileOperation::createDirectory(std::string path)
{
	return FileUtils::getInstance()->createDirectory(path);
}

bool RTFileOperation::removeDirectory(std::string path)
{
	return FileUtils::getInstance()->removeDirectory(path);
}
// 注意：to参数不能使用为包路径！
bool RTFileOperation::copyFile(std::string from, std::string to)
{
	if (!FileUtils::getInstance()->isFileExist(from)) return false;
	GetFileFolderFromPath(to);
	createDirectory(to);
	std::string fwPath = convertPathFormatToWinStyle(from);
	Platform::String^ psfrom = Plus2SharpHelper::PlatformStringFromString(fwPath);
	Platform::String^ psto = Plus2SharpHelper::PlatformStringFromString(to);
	StorageFolder ^ toSF;
	create_task(StorageFolder::GetFolderFromPathAsync(psto)).then([&toSF](StorageFolder^ folder){
		toSF = folder;
	}).wait();
	create_task(StorageFile::GetFileFromPathAsync(psfrom)).then([=](StorageFile^ file)
    {
		file->CopyAsync(toSF);
	}).wait();


	return true;
}