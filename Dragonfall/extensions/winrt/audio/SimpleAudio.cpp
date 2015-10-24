#include "SimpleAudio.h"
#include "WinRTHelper.h"
#include "cocos2d.h"
#include <ppltasks.h>
using namespace concurrency;

using namespace Platform;
using namespace Concurrency;
using namespace Windows::System;
using namespace Windows::System::Threading;
using namespace Windows::UI::Core;
using namespace Windows::UI::Input;
using namespace Windows::UI::Xaml;
using namespace Windows::UI::Xaml::Controls;
using namespace Windows::UI::Xaml::Input;
using namespace Windows::Foundation;
using namespace Windows::UI::ViewManagement;

extern void OnExtAudioPlayDone();
NS_CC_BEGIN
namespace AudioExtension
{
	Platform::Object^ findXamlElement(Platform::Object^ parent, Platform::String^ name)
	{
		if (parent == nullptr || name == nullptr || name->Length() == 0)
		{
			return nullptr;
		}

		FrameworkElement^ element = dynamic_cast<FrameworkElement^>(parent);
		if (element == nullptr)
		{
			return nullptr;
		}

		if (element->Name == name)
		{
			return element;
		}

		Panel^ panel = dynamic_cast<Panel^>(element);
		if (panel == nullptr)
		{
			return nullptr;
		}

		int count = panel->Children->Size;
		for (int i = 0; i < count; i++)
		{
			auto result = findXamlElement(panel->Children->GetAt(i), name);
			if (result != nullptr)
			{
				return result;
			}
		}

		return nullptr;
	}

	SimpleAudio::SimpleAudio() : m_isLoop(true), m_volume(1.0), __index(0)
	{
		m_dispatcher = cocos2d::GLViewImpl::sharedOpenGLView()->getDispatcher();
		m_panel = cocos2d::GLViewImpl::sharedOpenGLView()->getPanel();
		m_effect_token_map = ref new Platform::Collections::Map <Platform::String^, Windows::Foundation::EventRegistrationToken>();
		m_effect_token_keys = ref new Platform::Collections::Vector<Platform::String^>();
	}

	void SimpleAudio::playBackGroundMusic(Platform::String^ name, bool loop)
	{
		m_isLoop = loop;
		if (m_dispatcher.Get() == nullptr || m_panel.Get() == nullptr)
		{
			return;
		}

		std::string fullPath = cocos2d::FileUtils::getInstance()->fullPathForFilename(WinRTHelper::PlatformStringToString(name));
		Uri^ url = ref new Uri(WinRTHelper::PlatformStringFromString(fullPath));

		// must create XAML element on main UI thread?
		m_dispatcher.Get()->RunAsync(Windows::UI::Core::CoreDispatcherPriority::Normal, ref new DispatchedHandler([this, url]()
		{
			critical_section::scoped_lock lock(m_criticalSection);
			auto item = findXamlElement(m_panel.Get(), "BackgroundMediaElement");
			if (item != nullptr)
			{
				Controls::MediaElement^ media = dynamic_cast<Controls::MediaElement^>(item);
				media->MediaEnded -= m_end_token;
				media->Stop();
				media->Source = url;
				media->Volume = m_volume;
				m_end_token = media->MediaEnded += ref new Windows::UI::Xaml::RoutedEventHandler(this, &AudioExtension::SimpleAudio::OnMediaEnded);
				media->Play();
			}
			else
			{
				MediaElement^ media = ref new MediaElement();
				media->Name = "BackgroundMediaElement";
				media->AudioCategory = Windows::UI::Xaml::Media::AudioCategory::GameMedia;
				media->Source = url;
				media->Volume = m_volume;
				m_panel->Children->Append(media);
				media->Play();
				m_end_token = media->MediaEnded += ref new Windows::UI::Xaml::RoutedEventHandler(this, &AudioExtension::SimpleAudio::OnMediaEnded);
				backgroundMedia = media;
			}
		}));
	}

	void SimpleAudio::OnMediaEnded(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
	{
		if (m_isLoop)
		{
			if (backgroundMedia == nullptr) return;
			m_dispatcher.Get()->RunAsync(Windows::UI::Core::CoreDispatcherPriority::Normal, ref new DispatchedHandler([this](){
				backgroundMedia->Volume = m_volume;
				backgroundMedia->Play();
			}));
		}
		else
		{
			OnExtAudioPlayDone();
		}
	}
	//TODO::maybe,do not need remve xaml element?
	void SimpleAudio::stopBackGroundMusic()
	{
		m_dispatcher.Get()->RunAsync(Windows::UI::Core::CoreDispatcherPriority::Normal, ref new DispatchedHandler([this]()
		{
			critical_section::scoped_lock lock(m_criticalSection);
			auto item = findXamlElement(m_panel.Get(), "BackgroundMediaElement");
			if (item != nullptr)
			{
				Controls::MediaElement^ media = dynamic_cast<Controls::MediaElement^>(item);
				if (backgroundMedia != nullptr)
				{
					unsigned  int indexOfMedia = 0;
					if (m_panel->Children->IndexOf(media, &indexOfMedia))
					{
						media->Stop();
						media->MediaEnded -= m_end_token;
						m_panel->Children->RemoveAt(indexOfMedia);
						backgroundMedia = nullptr;
					}
				}

			}
		}));
	}

	void SimpleAudio::setVolume(float val)
	{

		m_volume = val;
		m_dispatcher.Get()->RunAsync(Windows::UI::Core::CoreDispatcherPriority::Normal, ref new DispatchedHandler([this]()
		{
			critical_section::scoped_lock lock(m_criticalSection);
			auto item = findXamlElement(m_panel.Get(), "BackgroundMediaElement");
			if (item != nullptr)
			{
				Controls::MediaElement^ media = dynamic_cast<Controls::MediaElement^>(item);
				media->Volume = m_volume;

			}
		}));
	}

	void SimpleAudio::playEffect(Platform::String^ filename)
	{
		if (m_dispatcher.Get() == nullptr || m_panel.Get() == nullptr)
		{
			return;
		}

		std::string fullPath = cocos2d::FileUtils::getInstance()->fullPathForFilename(WinRTHelper::PlatformStringToString(filename));
		Uri^ url = ref new Uri(WinRTHelper::PlatformStringFromString(fullPath));

		// must create XAML element on main UI thread?
		m_dispatcher.Get()->RunAsync(Windows::UI::Core::CoreDispatcherPriority::Normal, ref new DispatchedHandler([this, url]()
		{
			critical_section::scoped_lock lock(m_criticalSection);

			MediaElement^ media = ref new MediaElement();
			media->AudioCategory = Windows::UI::Xaml::Media::AudioCategory::GameMedia;
			media->Source = url;
			media->Name = this->Index;
			Windows::Foundation::EventRegistrationToken token = media->MediaEnded += ref new Windows::UI::Xaml::RoutedEventHandler(this, &AudioExtension::SimpleAudio::OnEffectMediaEnded);
			m_effect_token_map->Insert(media->Name, token);
			m_effect_token_keys->Append(media->Name);
			m_panel->Children->Append(media);
			media->Play();

		}));
	}

	void SimpleAudio::OnEffectMediaEnded(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
	{
		Controls::MediaElement^ media = dynamic_cast<Controls::MediaElement^>(sender);
		Windows::Foundation::EventRegistrationToken token = m_effect_token_map->Lookup(media->Name);
		media->MediaEnded -= token;
		m_effect_token_map->Remove(media->Name);
		unsigned  int indexOfKey = 0;
		if (m_effect_token_keys->IndexOf(media->Name, &indexOfKey))
		{
			m_effect_token_keys->RemoveAt(indexOfKey);
		}
		m_dispatcher.Get()->RunAsync(Windows::UI::Core::CoreDispatcherPriority::Normal, ref new DispatchedHandler([this, media](){
			critical_section::scoped_lock lock(m_criticalSection);
			unsigned  int indexOfMedia = 0;
			if (m_panel->Children->IndexOf(media, &indexOfMedia))
			{
				m_panel->Children->RemoveAt(indexOfMedia);
			}
		}));
	}

	void SimpleAudio::stopAllEffects()
	{
		m_dispatcher.Get()->RunAsync(Windows::UI::Core::CoreDispatcherPriority::Normal, ref new DispatchedHandler([this](){
			critical_section::scoped_lock lock(m_criticalSection);
			for (auto key : m_effect_token_keys)
			{
				auto token = m_effect_token_map->Lookup(key);
				auto item = findXamlElement(m_panel.Get(), key);
				if (item != nullptr)
				{
					Controls::MediaElement^ media = dynamic_cast<Controls::MediaElement^>(item);
					unsigned  int indexOfMedia = 0;
					if (m_panel->Children->IndexOf(media, &indexOfMedia))
					{
						m_panel->Children->RemoveAt(indexOfMedia);
						media->MediaEnded -= token;
						media->Stop();
					}
				}
			}
			m_effect_token_map->Clear();
			m_effect_token_keys->Clear();
		}));

	}

	void SimpleAudio::pauseBackgroundMusic()
	{
		if (backgroundMedia && backgroundMedia->CurrentState == Media::MediaElementState::Playing)
		{
			m_dispatcher.Get()->RunAsync(Windows::UI::Core::CoreDispatcherPriority::Normal, ref new DispatchedHandler([this](){
				critical_section::scoped_lock lock(m_criticalSection);
				backgroundMedia->Pause();
			}));
		}
	}

	void SimpleAudio::resumeBackgroundMusic()
	{
		if (backgroundMedia && backgroundMedia->CurrentState == Media::MediaElementState::Paused)
		{
			m_dispatcher.Get()->RunAsync(Windows::UI::Core::CoreDispatcherPriority::Normal, ref new DispatchedHandler([this](){
				critical_section::scoped_lock lock(m_criticalSection);
				backgroundMedia->Play();
			}));
		}
		
	}

	bool SimpleAudio::isMusicPlaying()
	{
		bool flag = false;
		if (backgroundMedia)
		{
			create_task(m_dispatcher.Get()->RunAsync(Windows::UI::Core::CoreDispatcherPriority::Normal, ref new DispatchedHandler([this,&flag](){
				flag = backgroundMedia->CurrentState == Media::MediaElementState::Playing;
			}))).wait();
		}
		return flag;
	}
}
NS_CC_END