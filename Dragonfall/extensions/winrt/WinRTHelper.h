#pragma once
namespace cocos2d
{
	namespace WinRTHelper
	{
		//cocos2dx
		std::string PlatformStringToString(Platform::String^ s);
		Platform::String^ PlatformStringFromString(const std::string& s);
		std::wstring CC_DLL CCUtf8ToUnicode(const char * pszUtf8Str, unsigned len = -1);
		std::string CC_DLL CCUnicodeToUtf8(const wchar_t* pwszStr);
	}
}

