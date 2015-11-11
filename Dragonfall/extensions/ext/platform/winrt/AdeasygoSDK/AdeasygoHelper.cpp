#include "pch.h"
#include "AdeasygoHelper.h"
#include <ppltasks.h>
#include <windows.h>
#include "WinRTHelper.h"
#include <collection.h>
using namespace concurrency;
using namespace Adeasygo::PaySDKWP81;
using namespace Windows::Foundation;
using namespace Windows::Foundation::Collections;
using namespace std;
using namespace cocos2d;
using namespace cocos2d::WinRTHelper;
using namespace Windows::ApplicationModel::Store;

#define AdeasygoAppKey "c7867ffb85d75c70"
#define AdeasygoAppId "ea9d6d3a7d050b8b"
extern void OnPayDone(int handleId, cocos2d::ValueVector valVector);
#define _DEBUG_Microsoft //测试微软支付
namespace cocos2d
{
	AdeasygoHelper::AdeasygoHelper()
	{
		handleId = 0;
		m_goods_inited = false;
		m_isVisible = false;
		m_goods_map.clear();
		m_vec_NeedValidateReceipt.clear();
	}

	void AdeasygoHelper::PayDone(Platform::Object^ sender, Adeasygo::PaySDKWP81::Model::PayDoneEventArgs ^ args)
	{
		SDKManager::ClosePayBox();
		m_isVisible = false;
		create_task(Adeasygo::PaySDKWP81::SDKManager::GetUnSyncTrade()).then([this](task<Model::TradeResultList^> task){
			Model::TradeResultList^ tradeResultList = task.get();
			CallLuaCallbakAdeasygo(tradeResultList);
		});
	}
	
	void AdeasygoHelper::MsPurchas(Platform::Object^ sender, Adeasygo::PaySDKWP81::Model::MsPayEventArgs ^ args)
	{
		m_isVisible = false;
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)
		Platform::String^ productId = findProductIdWithAdeasygoGoodsId(args->GoodsID);
		if (!productId->IsEmpty())
		{
#ifdef _DEBUG_Microsoft
			productId = "com.dragonfall.test";
#endif // _DEBUG_Microsoft
			CCLOG("购买%s", PlatformStringToString(productId).c_str());
			MSRequestProductPurchase(productId);
		}
#endif
	}

	void AdeasygoHelper::updateTransactionStates()
	{
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)
		MSGetUnfulfilledConsumables();
#endif
		RunOnUIThread([=](){
			if (!m_goods_inited)return;
			create_task(Adeasygo::PaySDKWP81::SDKManager::GetUnSyncTrade()).then([this](Model::TradeResultList^ tradeResultList)
			{
				CallLuaCallbakAdeasygo(tradeResultList);
			});

		});
	}

	void AdeasygoHelper::Pay(Platform::String^ productId)
	{
		auto cpp_productId = PlatformStringToString(productId);
		if (m_goods_inited)
		{
			auto sdkId = m_goods_map[cpp_productId].asString();
			RunOnUIThread([this, sdkId](){
				SDKManager::Pay(PlatformStringFromString(sdkId), "", "", "");
				m_isVisible = true;
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
				create_task(SDKManager::GetGoods()).then([this](Model::GoodsList^ goodsList){
					auto list = goodsList->goods_list;
					for_each(begin(list),
						end(list),
						[&](Model::Goods^ goods) {
						auto sdk_id = goods->id;
						auto product_id = goods->out_goods_id;
						CCLOG("product_id:%s", PlatformStringToString(product_id).c_str());
						CCLOG("price:%s", PlatformStringToString(goods->price).c_str());
						m_goods_map[PlatformStringToString(product_id)] = cocos2d::Value(PlatformStringToString(sdk_id));
					});
					m_goods_inited = true;
				});
			}
			
		}, Windows::UI::Core::CoreDispatcherPriority::High);
	}

	Platform::String^ AdeasygoHelper::DeviceUniqueId()
	{
		Platform::String^ DeviceUniqueId = "";
		create_task(cocos2d::WinRTHelper::RunOnUIThread([=, &DeviceUniqueId](){
			DeviceUniqueId = Adeasygo::PaySDKWP81::SDKManager::DeviceUniqueId;
		}, Windows::UI::Core::CoreDispatcherPriority::High)).wait();
		return DeviceUniqueId;
	}

	void AdeasygoHelper::CallLuaCallback(cocos2d::ValueVector valueVec)
	{
		if (handleId > 0)
		{
			OnPayDone(handleId, valueVec);
		}
	}
	
	void AdeasygoHelper::CallLuaCallbakAdeasygo(Adeasygo::PaySDKWP81::Model::TradeResultList^ tradeResultList)
	{
		if (nullptr == tradeResultList)return;
		auto list = tradeResultList->traderesult;
		if (nullptr == list)return;
		cocos2d::ValueVector vector;
		for_each(begin(list),end(list),[&](Model::TradeResult^ tradeResult)
		{
				cocos2d::ValueMap tempMap;
				tempMap["transactionIdentifier"] = PlatformStringToString(tradeResult->trade_no);
				tempMap["productIdentifier"] = PlatformStringToString(tradeResult->out_goods_id);
				tempMap["orderType"] = "Adeasygo";
				vector.push_back(cocos2d::Value(tempMap));
		});
		if (vector.size()>0)CallLuaCallback(vector);
	}

	Platform::String^ AdeasygoHelper::findProductIdWithAdeasygoGoodsId(Platform::String^ goodsId)
	{
		Platform::String^ ret = "";
		cocos2d::ValueMap::iterator it;
		for (it = m_goods_map.begin(); it != m_goods_map.end(); it++)
		{
			if (it->second.asString() == PlatformStringToString(goodsId))
			{
				ret = PlatformStringFromString(it->first);
				return ret;
			}
		}
		return ret;
	}

/************************************************************************/
/* 微软支付相关方法														*/
/************************************************************************/

#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)

	void AdeasygoHelper::CallLuaCallbakMicrosoft(Platform::String^ productId, Platform::String^ transactionIdentifier)
	{
		cocos2d::ValueVector vector;
		cocos2d::ValueMap tempMap;
		tempMap["transactionIdentifier"] = PlatformStringToString(transactionIdentifier);
		tempMap["productIdentifier"] = PlatformStringToString(productId);
		tempMap["orderType"] = "Microsoft";
		vector.push_back(cocos2d::Value(tempMap));
		CallLuaCallback(vector);
	}

	void AdeasygoHelper::CallLuaCallbakMicrosoft(Windows::Foundation::Collections::IVectorView<UnfulfilledConsumable^>^ unfulfilledConsumables)
	{
		cocos2d::ValueVector vector;
		for_each(begin(unfulfilledConsumables), end(unfulfilledConsumables), [&](UnfulfilledConsumable^ unfulfilledConsumable)
		{
			cocos2d::ValueMap tempMap;
			auto receiptXml = MSGetProductReceipt(unfulfilledConsumable->ProductId);
			tempMap["transactionIdentifier"] = PlatformStringToString(receiptXml);
			tempMap["productIdentifier"] = PlatformStringToString(unfulfilledConsumable->ProductId);
			tempMap["orderType"] = "Microsoft";
			vector.push_back(cocos2d::Value(tempMap));
		});
		if (vector.size()>0)CallLuaCallback(vector);
	}

	Windows::Foundation::Collections::IMap<Platform::String^, Windows::Foundation::Collections::IVector<Platform::String^>^>^ AdeasygoHelper::MSLoadListingInformationByProductIds(Windows::Foundation::Collections::IVector<Platform::String^>^ productIds)
	{
		Platform::Collections::Map<Platform::String^, Windows::Foundation::Collections::IVector<Platform::String^>^>^ ret = ref new Platform::Collections::Map<Platform::String^, Windows::Foundation::Collections::IVector<Platform::String^>^>();
		auto request = CurrentApp::LoadListingInformationByProductIdsAsync(productIds);
		create_task(request).then([&ret](ListingInformation^ listingInformation)
		{
			auto productListings = listingInformation->ProductListings;
			for (auto itr : productListings)
			{
				auto productListing = itr->Value;
				Platform::Collections::Vector<Platform::String^>^ vec = ref new Platform::Collections::Vector<Platform::String^>();
				vec->Append(productListing->Name);
				vec->Append(productListing->FormattedPrice);
				vec->Append(productListing->Description);
				ret->Insert(productListing->ProductId, vec);
			}
		}).wait();
		return ret;
	}

	void AdeasygoHelper::MSRequestProductPurchase(Platform::String^ productId)
	{
		RunOnUIThread([=](void){
			create_task(CurrentApp::RequestProductPurchaseAsync(productId)).then([=](PurchaseResults^ results)
			{
				if (results->Status == ProductPurchaseStatus::Succeeded)
				{
					CCLOG("完成购买---");
					cocos2d::ValueMap tempMap;
					tempMap["transactionIdentifier"] = PlatformStringToString(results->ReceiptXml);
					tempMap["productIdentifier"] = PlatformStringToString(productId);
					tempMap["orderType"] = "Microsoft";
					m_vec_NeedValidateReceipt.push_back(cocos2d::Value(tempMap));
				}
				else if (results->Status == ProductPurchaseStatus::NotFulfilled)
				{
					CCLOG("未验证订单---");
					CallLuaCallbakMicrosoft(productId, results->ReceiptXml);
				}
				else if (results->Status == ProductPurchaseStatus::NotPurchased)
				{
					CCLOG("未购买---");
				}
			});
		});
	}
	void AdeasygoHelper::MSReportProductFulfillment(Platform::String^ productId)
	{
		auto licenses = CurrentApp::LicenseInformation->ProductLicenses;
		if (licenses->HasKey(productId))
		{
			auto currentLicense = licenses->Lookup(productId);
			//暂时只支持消耗品
			if (currentLicense->IsActive && currentLicense->IsConsumable)
			{
				CurrentApp::ReportProductFulfillment(productId);
			}
		}
	}

	Platform::String^ AdeasygoHelper::MSGetProductReceipt(Platform::String^ productId)
	{
		Platform::String^ ret = "";
		auto request = CurrentApp::GetProductReceiptAsync(productId);
		create_task(request).then([&ret](Platform::String^ receiptXml){
			ret = receiptXml;
		}).wait();
		return ret;
	}

	void AdeasygoHelper::MSGetUnfulfilledConsumables()
	{
		auto request = CurrentApp::GetUnfulfilledConsumablesAsync();
		create_task(request).then([=](Windows::Foundation::Collections::IVectorView<UnfulfilledConsumable^>^ unfulfilledConsumables)
		{
			CallLuaCallbakMicrosoft(unfulfilledConsumables);
		}).wait();
	}
	void AdeasygoHelper::MSValidateReceipts()
	{
		if (m_vec_NeedValidateReceipt.size() > 0)
		{
			CallLuaCallback(m_vec_NeedValidateReceipt);
			m_vec_NeedValidateReceipt.clear();//调用lua后无论成功失败清空列表
		}
	}
#endif /* WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP) */
}