#pragma once
namespace cocos2d
{
	namespace WinRTHelper
	{
		void QueueEvent(const std::function<void()>& func);
		std::string PlatformStringToUtf8String(Platform::String^ s);
		std::string PlatformStringToString(Platform::String^ s);
		Platform::String^ PlatformStringFromString(const std::string& s);
		std::wstring CC_DLL CCUtf8ToUnicode(const char * pszUtf8Str, unsigned len = -1);
		std::string CC_DLL CCUnicodeToUtf8(const wchar_t* pwszStr);
		Windows::Foundation::IAsyncAction^ RunOnUIThread(std::function<void()> method, 
			Windows::UI::Core::CoreDispatcherPriority priorty = Windows::UI::Core::CoreDispatcherPriority::Normal);

		//提供对设备的操作
		public ref class Device sealed
		{
		private:
			Device(){};
			Windows::System::Display::DisplayRequest^ m_display_request;
		public:
			void DisplayRequestActive()
			{
				if (nullptr == m_display_request)
				{
					m_display_request = ref new Windows::System::Display::DisplayRequest();
				}
				m_display_request->RequestActive();
			}

			void DisplayRequestRelease()
			{
				if (nullptr != m_display_request)
				{
					m_display_request->RequestRelease();
				}
			}
			static property Device^ Instance
			{
				Device^ get()
				{
					static Device^ instance = ref new Device();
					return instance;
				}
			}
		};

	}
}