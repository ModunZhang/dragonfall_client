/**
	dannyhe
	通过windows phone8.1的控件播放音乐，很多接口不实现,
	所有数据交给控件管理，不存在对steam的管理
	查询是否有背景音乐播放的接口可能有些性能问题...
**/
#ifndef __SimpleAudio_H__
#define __SimpleAudio_H__
#include "platform/CCPlatformConfig.h"
#if CC_TARGET_PLATFORM == CC_PLATFORM_WINRT
#include <collection.h>

using namespace Platform::Collections;
using namespace Windows::Foundation::Collections;
NS_CC_BEGIN
namespace AudioExtension
{
	ref class SimpleAudio sealed
	{
	private:
		bool m_isLoop;
		SimpleAudio();
		Windows::UI::Xaml::Controls::MediaElement^ backgroundMedia;

		Concurrency::critical_section m_criticalSection;

		Platform::Agile<Windows::UI::Core::CoreDispatcher> m_dispatcher;
		Platform::Agile<Windows::UI::Xaml::Controls::Panel> m_panel;

		Windows::Foundation::EventRegistrationToken m_end_token;

		void OnMediaEnded(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
		void OnEffectMediaEnded(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
		float m_volume;
		unsigned int __index;
		Platform::Collections::Map <Platform::String^, Windows::Foundation::EventRegistrationToken>^ m_effect_token_map;
		Platform::Collections::Vector<Platform::String^>^ m_effect_token_keys;
	public:

		property Platform::String^ Index {
			Platform::String^ get()
			{
				return  "" + (__index++);
			}
		}
		static property SimpleAudio^ Instance
		{
			SimpleAudio^ get()
			{
				static SimpleAudio^ instance = ref new SimpleAudio();
				return instance;
			}
		}

		void playBackGroundMusic(Platform::String^ filename, bool loop = true);
		void stopBackGroundMusic();
		void pauseBackgroundMusic();
		void resumeBackgroundMusic();


		//background music only
		void setVolume(float val);
		float getVolume(){ return m_volume; };

		bool isMusicPlaying();

		//effects
		void playEffect(Platform::String^ filename);
		void stopAllEffects();
		//TODO:
		void pauseAllEffects(){};
		void resumeAllEffects(){};
	};

}
NS_CC_END
#endif // CC_TARGET_PLATFORM == CC_PLATFORM_WINRT

#endif