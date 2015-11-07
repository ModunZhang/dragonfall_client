#pragma once
#include "cocos2d.h"
namespace cocos2d
{
	public ref class AdeasygoHelper sealed
	{
	private:

		AdeasygoHelper();

		//��Ʒid��sdk����Ʒid֮��Ķ�Ӧ��
		cocos2d::ValueMap m_goods_map;

		//sdk�Ƿ��ʼ�����
		bool m_goods_inited;

		//sdk�Ƿ��
		bool m_isVisible;

		//����lua callback
		void CallLuaCallback(cocos2d::ValueVector valueVec);
		
		void CallLuaCallbakAdeasygo(Adeasygo::PaySDKWP81::Model::TradeResultList^ tradeResultList);

		//ͨ��sdk��goodsId������Ʒid
		Platform::String^ findProductIdWithAdeasygoGoodsId(Platform::String^ goodsId);

#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)
		//����lua�ص���΢��ӿ�
		void CallLuaCallbakMicrosoft(Platform::String^ productId, Platform::String^ transactionIdentifier);

		void CallLuaCallbakMicrosoft(Windows::Foundation::Collections::IVectorView<Windows::ApplicationModel::Store::UnfulfilledConsumable^>^ unfulfilledConsumables);
		//��ȡ��Ʒ�б�
		void MSLoadListingInformationByProductIds(Platform::Collections::Vector<Platform::String^>^ productIds);
		//������Ʒ
		void MSRequestProductPurchase(Platform::String^ productId);
		//��ȡ�վ�
		Platform::String^ MSGetProductReceipt(Platform::String^ productId);
		//��ȡδ��ɵĶ�����Ϣ
		void MSGetUnfulfilledConsumables();
#endif
	public:
		cocos2d::ValueVector vecMSUnfulfilledConsumables;
		static property AdeasygoHelper^ Instance
		{
			AdeasygoHelper^ get()
			{
				static AdeasygoHelper^ instance = ref new AdeasygoHelper();
				return instance;
			}
		}
		//sdk���ɵ�Ψһ��ʶ��
		static property Platform::String^ DeviceUniqueId
		{
			Platform::String^ get()
			{
				return Adeasygo::PaySDKWP81::SDKManager::DeviceUniqueId;
			}
		}

		//lua�ص�������id
		property int handleId;
		
		//sdk�Ĺ�������Ƿ�Ϊ��ʾ״̬
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

		//�������ж�������Ϣ
		void updateTransactionStates();
		
		//��ʼ��sdk
		void Init();

		//����
		void Pay(Platform::String^ productId);

		//sdk֧������¼�
		void PayDone(Platform::Object^ sender, Adeasygo::PaySDKWP81::Model::PayDoneEventArgs ^ args);

		//sdk��΢��֧���¼�
		void MsPurchas(Platform::Object^ sender, Adeasygo::PaySDKWP81::Model::MsPayEventArgs^ args);

#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)
		//ȷ��΢������Ʒ
		void MSReportProductFulfillment(Platform::String^ productId);
#endif
	};
}