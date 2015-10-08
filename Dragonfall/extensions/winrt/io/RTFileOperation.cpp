#include "pch.h"
#include "RTFileOperation.h"
#include <ppltasks.h>
#include "cocos2d.h"
#include <stdio.h>
#include <string>
#include "WinRTHelper.h"

using namespace cocos2d;
using namespace concurrency;
using namespace Windows::Storage;
using namespace Windows::Foundation;
RTFileOperation::RTFileOperation()
{
}
//��ȡ·�����ļ���λ�� c:/a/b.txt -> c:/a/
static void GetFileFolderFromPath(std::string &path)
{
	std::size_t found = path.rfind("/");
	if (found != std::string::npos)
	{
		path.erase(found+1);
	}
}
//��·��ת��Ϊwindows�µ�·����ʽ
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
// ע�⣺to��������ʹ��Ϊ��װ��·����
// ���Ŀ��λ����ͬ���ļ�����ɾ��Ȼ��ִ�п���
bool RTFileOperation::copyFile(std::string from, std::string to)
{
	bool ret = true;
	if (!FileUtils::getInstance()->isFileExist(from)) return false;
	if (FileUtils::getInstance()->isFileExist(to))FileUtils::getInstance()->removeFile(to);
	GetFileFolderFromPath(to);
	createDirectory(to);
	Platform::String^ psfrom = cocos2d::WinRTHelper::PlatformStringFromString(convertPathFormatToWinStyle(from));
	Platform::String^ psto = cocos2d::WinRTHelper::PlatformStringFromString(convertPathFormatToWinStyle(to));
	create_task(StorageFolder::GetFolderFromPathAsync(psto)).then([=, &psfrom,&ret](task<StorageFolder^> task){
		try
		{
			StorageFolder^ folder = task.get();
			create_task(StorageFile::GetFileFromPathAsync(psfrom)).then([=, &folder](StorageFile^ file){
				create_task(file->CopyAsync(folder)).wait();
			}).wait();
		}
		catch (Platform::COMException^ ex)
		{
			ret = false;
		}
	}).wait();

	return ret;
}