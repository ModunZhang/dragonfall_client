#pragma once
#include "cocos2d.h"
namespace cocos2d
{
	public ref class AdeasygoHelper sealed
	{
	private:

		AdeasygoHelper();

		//商品id和sdk的商品id之间的对应表
		cocos2d::ValueMap m_goods_map;

		//sdk是否初始化完毕
		bool m_goods_inited;

		//sdk是否打开
		bool m_isVisible;

		//调用lua callback
		void CallLuaCallback(cocos2d::ValueVector valueVec);

		//调用lua回调的sdk接口
		void CallLuaCallbakAdeasygo(Adeasygo::PaySDKWP81::Model::TradeResultList^ tradeResultList);

		//调用lua回调的异常接口
		void CallLuaCallbackException(std::string eventName);

		//通过sdk的goodsId查找商品id
		Platform::String^ findProductIdWithAdeasygoGoodsId(Platform::String^ goodsId);

		//需要验证的微软收据
		cocos2d::ValueVector m_vec_NeedValidateReceipt;

		//获取sdk的商品列表
		Windows::Foundation::IAsyncOperation<Platform::Boolean>^ GetAdeasygoGoodsIf();

		Concurrency::critical_section m_criticalSection;

#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)

		//调用lua回调的微软接口
		void CallLuaCallbakMicrosoft(Platform::String^ productId, Platform::String^ transactionIdentifier);

		void CallLuaCallbakMicrosoft(Windows::Foundation::Collections::IVectorView<Windows::ApplicationModel::Store::UnfulfilledConsumable^>^ unfulfilledConsumables);
		//购买商品
		void MSRequestProductPurchase(Platform::String^ productId);
		//获取收据
		Platform::String^ MSGetProductReceipt(Platform::String^ productId);
		//获取未完成的订单信息
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
		//sdk生成的唯一标识码
		Platform::String^ DeviceUniqueId();
		//lua回调函数的id（无异常时）
		property int handleId;
		//异常发生时回调lua
		property int errorHandleId;
		//sdk的购买界面是否为显示状态
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

		//更新所有订单的信息
		void updateTransactionStates();
		
		//初始化sdk
		void Init();

		//购买
		void Pay(Platform::String^ productId);

		//sdk支付完成事件
		void PayDone(Platform::Object^ sender, Adeasygo::PaySDKWP81::Model::PayDoneEventArgs ^ args);

		//sdk中微软支付事件
		void MsPurchas(Platform::Object^ sender, Adeasygo::PaySDKWP81::Model::MsPayEventArgs^ args);

#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)
		//获取微软商品列表
		Windows::Foundation::Collections::IMap<Platform::String^, Windows::Foundation::Collections::IVector<Platform::String^>^>^ MSLoadListingInformationByProductIds(Windows::Foundation::Collections::IVector<Platform::String^>^ productIds);
		//确认微软购买商品
		void MSReportProductFulfillment(Platform::String^ productId);
		//对微软的收据进行验证 确保该方法要在和服务器通信正常的时候调用
		void MSValidateReceipts();
#endif
	};
}