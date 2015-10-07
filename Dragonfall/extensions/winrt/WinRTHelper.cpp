#include "pch.h"
#include "WinRTHelper.h"

namespace cocos2d
{
	namespace WinRTHelper
	{
		std::string PlatformStringToString(Platform::String^ s) {
			std::wstring t = std::wstring(s->Data());
			return std::string(t.begin(), t.end());
		}

		Platform::String^ PlatformStringFromString(const std::string& s)
		{
			std::wstring ws(CCUtf8ToUnicode(s.c_str()));
			return ref new Platform::String(ws.data(), ws.length());
		}
		std::wstring CCUtf8ToUnicode(const char * pszUtf8Str, unsigned len/* = -1*/)
		{
			std::wstring ret;
			do
			{
				if (!pszUtf8Str) break;
				// get UTF8 string length
				if (-1 == len)
				{
					len = strlen(pszUtf8Str);
				}
				if (len <= 0) break;

				// get UTF16 string length
				int wLen = MultiByteToWideChar(CP_UTF8, 0, pszUtf8Str, len, 0, 0);
				if (0 == wLen || 0xFFFD == wLen) break;

				// convert string  
				wchar_t * pwszStr = new wchar_t[wLen + 1];
				if (!pwszStr) break;
				pwszStr[wLen] = 0;
				MultiByteToWideChar(CP_UTF8, 0, pszUtf8Str, len, pwszStr, wLen + 1);
				ret = pwszStr;
				CC_SAFE_DELETE_ARRAY(pwszStr);
			} while (0);
			return ret;
		}

		std::string CCUnicodeToUtf8(const wchar_t* pwszStr)
		{
			std::string ret;
			do
			{
				if (!pwszStr) break;
				size_t len = wcslen(pwszStr);
				if (len <= 0) break;

				size_t convertedChars = 0;
				char * pszUtf8Str = new char[len * 3 + 1];
				WideCharToMultiByte(CP_UTF8, 0, pwszStr, len + 1, pszUtf8Str, len * 3 + 1, 0, 0);
				ret = pszUtf8Str;
				CC_SAFE_DELETE_ARRAY(pszUtf8Str);
			} while (0);

			return ret;
		}
	}
}
