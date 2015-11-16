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

		//����lua�ص���sdk�ӿ�
		void CallLuaCallbakAdeasygo(Adeasygo::PaySDKWP81::Model::TradeResultList^ tradeResultList);

		//����lua�ص����쳣�ӿ�
		void CallLuaCallbackException(std::string eventName);

		//ͨ��sdk��goodsId������Ʒid
		Platform::String^ findProductIdWithAdeasygoGoodsId(Platform::String^ goodsId);

		//��Ҫ��֤��΢���վ�
		cocos2d::ValueVector m_vec_NeedValidateReceipt;

		//��ȡsdk����Ʒ�б�
		Windows::Foundation::IAsyncOperation<Platform::Boolean>^ GetAdeasygoGoodsIf();

		Concurrency::critical_section m_criticalSection;

#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)

		//����lua�ص���΢��ӿ�
		void CallLuaCallbakMicrosoft(Platform::String^ productId, Platform::String^ transactionIdentifier);

		void CallLuaCallbakMicrosoft(Windows::Foundation::Collections::IVectorView<Windows::ApplicationModel::Store::UnfulfilledConsumable^>^ unfulfilledConsumables);
		//������Ʒ
		void MSRequestProductPurchase(Platform::String^ productId);
		//��ȡ�վ�
		Platform::String^ MSGetProductReceipt(Platform::String^ productId);
		//��ȡδ��ɵĶ�����Ϣ
		void MSGetUnfulfilledConsumables();
#endif
	public:

		static property AdeasygoHelper^ Instance
		{
			AdeasygoHelper^ get()
			{
				static AdeasygoHelper^ instance = ref new AdeasygoHelper();
				return instance;
			}
		}
		//sdk���ɵ�Ψһ��ʶ��
		Platform::String^ DeviceUniqueId();
		//lua�ص�������id�����쳣ʱ��
		property int handleId;
		//�쳣����ʱ�ص�lua
		property int errorHandleId;
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
		//��ȡ΢����Ʒ�б�
		Windows::Foundation::Collections::IMap<Platform::String^, Windows::Foundation::Collections::IVector<Platform::String^>^>^ MSLoadListingInformationByProductIds(Windows::Foundation::Collections::IVector<Platform::String^>^ productIds);
		//ȷ��΢������Ʒ
		void MSReportProductFulfillment(Platform::String^ productId);
		//��΢����վݽ�����֤ ȷ���÷���Ҫ�ںͷ�����ͨ��������ʱ�����
		void MSValidateReceipts();
#endif
	};
}