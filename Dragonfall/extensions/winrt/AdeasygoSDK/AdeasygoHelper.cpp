#include "pch.h"
#include "AdeasygoHelper.h"
#include <ppltasks.h>
#include <windows.h>
#include <collection.h>
#include "WinRTHelper.h"
#include <windows.h>

using namespace concurrency;
using namespace Adeasygo::PaySDKWP81;
using namespace Windows::Foundation;
using namespace Windows::Foundation::Collections;
using namespace std;
using namespace cocos2d;
using namespace cocos2d::WinRTHelper;

#define AdeasygoAppKey "c7867ffb85d75c70"
#define AdeasygoAppId "ea9d6d3a7d050b8b"
extern void OnPayDone(int handleId, cocos2d::ValueVector valVector);
namespace cocos2d
{
	AdeasygoHelper::AdeasygoHelper()
	{
		handleId = 0;
		m_goods_inited = false;
		m_goods_map.clear();
	}

	void AdeasygoHelper::PayDone(Platform::Object^ sender, Adeasygo::PaySDKWP81::Model::PayDoneEventArgs ^ args)
	{
		SDKManager::ClosePayBox();
		create_task(Adeasygo::PaySDKWP81::SDKManager::GetUnSyncTrade()).then([this](task<Model::TradeResultList^> task){
			Model::TradeResultList^ tradeResultList = task.get();
			auto list = tradeResultList->traderesult;
			if (nullptr != list)
			{
				cocos2d::ValueVector resultVerctor;
				for_each(begin(list),
					end(list),
					[&](Model::TradeResult^ tradeResult)
				{
					cocos2d::ValueMap tempMap;
					tempMap["orderId"] = PlatformStringToString(tradeResult->trade_no);
					tempMap["transactionIdentifier"] = PlatformStringToString(tradeResult->out_goods_id);
					resultVerctor.push_back(cocos2d::Value(tempMap));
				}
				);
				if (handleId > 0)
				{
					OnPayDone(handleId, resultVerctor);
				}
			}
		});
	}

	void AdeasygoHelper::updateTransactionStates()
	{
		if (!m_goods_inited)return;
		//call on ui thread?
		RunOnUIThread([=](){
			create_task(Adeasygo::PaySDKWP81::SDKManager::GetUnSyncTrade()).then([this](task<Model::TradeResultList^> task){
				Model::TradeResultList^ tradeResultList = task.get();
				auto list = tradeResultList->traderesult;
				if (nullptr != list)
				{
					cocos2d::ValueVector resultVerctor;
					for_each(begin(list),
						end(list),
						[&](Model::TradeResult^ tradeResult)
					{
						cocos2d::ValueMap tempMap;
						tempMap["orderId"] = PlatformStringToString(tradeResult->trade_no);
						tempMap["transactionIdentifier"] = PlatformStringToString(tradeResult->out_goods_id);
						resultVerctor.push_back(cocos2d::Value(tempMap));
					}
					);
					if (handleId > 0)
					{
						OnPayDone(handleId, resultVerctor);
					}
				}
			});
		});
	}

	void AdeasygoHelper::MsPurchas(Platform::Object^ sender, Adeasygo::PaySDKWP81::Model::MsPayEventArgs ^ args)
	{
		Windows::UI::Popups::MessageDialog("MsPurchas:" + args->GoodsID).ShowAsync();
	}

	void AdeasygoHelper::Pay(Platform::String^ productId)
	{
		auto cpp_productId = PlatformStringToString(productId);
		if (m_goods_inited)
		{
			auto sdkId = m_goods_map[cpp_productId].asString();
			RunOnUIThread([=](){
				SDKManager::Pay(PlatformStringFromString(sdkId), "", "", "");
				
			});
		}
	}

	void AdeasygoHelper::Init()
	{
		RunOnUIThread([this](){
			SDKManager::ToMarketPurchase += ref new EventHandler <Adeasygo::PaySDKWP81::Model::MsPayEventArgs ^>(this, &cocos2d::AdeasygoHelper::MsPurchas);
			SDKManager::PayDone += ref new Windows::Foundation::EventHandler<Adeasygo::PaySDKWP81::Model::PayDoneEventArgs ^>(this, &cocos2d::AdeasygoHelper::PayDone);
			SDKManager::SetKey(AdeasygoAppKey, AdeasygoAppId);
			SDKManager::Init();
			if (!m_goods_inited)
			{
				create_task(SDKManager::GetGoods()).then([this](task<Model::GoodsList^> task){
					Model::GoodsList^ goodsList = task.get();
					auto list = goodsList->goods_list;
					for_each(begin(list),
						end(list),
						[&](Model::Goods^ goods) {
						auto sdk_id = goods->id;
						auto product_id = goods->out_goods_id;
						m_goods_map[PlatformStringToString(product_id)] = cocos2d::Value(PlatformStringToString(sdk_id));
					});
					m_goods_inited = true;
				});
			}
			
		});
	}
}