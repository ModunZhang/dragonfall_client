#pragma once
#include "cocos2d.h"
namespace cocos2d
{
	public ref class AdeasygoHelper sealed
	{
	private:

		AdeasygoHelper();
		
		cocos2d::ValueMap m_goods_map;
		
		bool m_goods_inited;
		bool m_isVisible;

	public:
		static property AdeasygoHelper^ Instance
		{
			AdeasygoHelper^ get()
			{
				static AdeasygoHelper^ instance = ref new AdeasygoHelper();
				return instance;
			}
		}

		static property Platform::String^ DeviceUniqueId
		{
			Platform::String^ get()
			{
				return Adeasygo::PaySDKWP81::SDKManager::DeviceUniqueId;
			}
		}

		property int handleId;
		property bool IsVisible
		{
			bool get()
			{
				return m_isVisible;
			}
			void set(bool isVisible)
			{
				m_isVisible = isVisible;
			}
		}

		//method

		void updateTransactionStates();

		void Init();

		void Pay(Platform::String^ productId);

		//event
		void PayDone(Platform::Object^ sender, Adeasygo::PaySDKWP81::Model::PayDoneEventArgs ^ args);
		void MsPurchas(Platform::Object^ sender, Adeasygo::PaySDKWP81::Model::MsPayEventArgs^ args);
	};
}



