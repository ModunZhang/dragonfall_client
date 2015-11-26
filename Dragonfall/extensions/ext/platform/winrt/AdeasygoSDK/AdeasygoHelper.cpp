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
#define _Microsoft_Store_Immediately 0 //调用购买后直接执行微软商店的购买而不经过sdk的回调进行微软商店购买
#define AdeasygoAppKey "c7867ffb85d75c70"
#define AdeasygoAppId "ea9d6d3a7d050b8b"
extern void OnPayDone(int handleId, cocos2d::ValueVector valVector);
extern void OnPayException(int handleId, std::string eventName);
namespace cocos2d
{
	AdeasygoHelper::AdeasygoHelper()
	{
		handleId = 0;
		m_goods_inited = false;
		m_isVisible = false;
		m_goods_map.clear();
	}

	void AdeasygoHelper::PayDone(Platform::Object^ sender, Adeasygo::PaySDKWP81::Model::PayDoneEventArgs ^ args)
	{
		SDKManager::ClosePayBox();
		m_isVisible = false;
		create_task(Adeasygo::PaySDKWP81::SDKManager::GetUnSyncTrade()).then([this](task<Model::TradeResultList^> task){
			try
			{
				Model::TradeResultList^ tradeResultList = task.get();
				CallLuaCallbakAdeasygo(tradeResultList);
			}
			catch (Platform::COMException^ e)
			{
				CallLuaCallbackException("UnSyncTrade");
			}
		});
	}
	
	void AdeasygoHelper::MsPurchas(Platform::Object^ sender, Adeasygo::PaySDKWP81::Model::MsPayEventArgs ^ args)
	{
		m_isVisible = false;
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)
		Platform::String^ productId = findProductIdWithAdeasygoGoodsId(args->GoodsID);
		if (!productId->IsEmpty())
		{
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
			create_task(Adeasygo::PaySDKWP81::SDKManager::GetUnSyncTrade()).then([=](task<Model::TradeResultList^> task)
			{
				try
				{
					auto tradeResultList = task.get();
					CallLuaCallbakAdeasygo(tradeResultList);
				}
				catch (Platform::COMException ^ e)
				{
					CallLuaCallbackException("UnSyncTrade");
				}
			});

		});
	}

	void AdeasygoHelper::Pay(Platform::String^ productId)
	{
#if _Microsoft_Store_Immediately && WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)
		MSRequestProductPurchase(productId);
		return;
#endif // _Microsoft_Store_Immediately
		if (m_isVisible)return;
		RunOnUIThread([this, productId](){
			create_task(GetAdeasygoGoodsIf()).then([=](task<Platform::Boolean> task)
			{
				try
				{
					Platform::Boolean success = task.get();
					if (success)
					{
						auto cpp_productId = PlatformStringToString(productId);
						if (m_goods_map.find(cpp_productId) == m_goods_map.end())
						{
							CCLOGWARN("Not found productId in SDK:%s", cpp_productId.c_str());
							return;
						}
						auto sdkId = m_goods_map[cpp_productId].asString();
						SDKManager::Pay(PlatformStringFromString(sdkId), "", "", "");
						m_isVisible = true;
					}
				}
				catch (Platform::COMException^ e)
				{
					m_isVisible = false;
					CallLuaCallbackException("Pay");
				}
			});
		});
	}

	IAsyncOperation<Platform::Boolean>^ AdeasygoHelper::GetAdeasygoGoodsIf()
 	{
		critical_section::scoped_lock lock(m_criticalSection);
		return create_async([=]()
		{
			if (m_goods_inited)
			{
				return create_task([=]() -> bool{
					return true;
				});
			}
			else
			{
				return create_task(SDKManager::GetGoods(), task_continuation_context::use_current()).then([this](task<Model::GoodsList^> task) ->bool{
					try
					{
						auto goodsList = task.get();
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
					}
					catch (Platform::COMException^ e)
					{
						m_goods_inited = false;
					}
					return m_goods_inited;
				});
			}
		});
	}
	void AdeasygoHelper::CallLuaCallbackException(std::string eventName)
	{
		if (errorHandleId > 0)
		{
			WinRTHelper::QueueEvent([=]()
			{
				OnPayException(handleId, eventName);
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
			create_task(GetAdeasygoGoodsIf());
			
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
			WinRTHelper::QueueEvent([=]()
			{
				OnPayDone(handleId, valueVec);
			});
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
				tempMap["transactionId"] = PlatformStringToString(tradeResult->trade_no);
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

	void AdeasygoHelper::CallLuaCallbakMicrosoft(Platform::String^ productId, Platform::String^ transactionIdentifier, Platform::String^ transactionId)
	{
		cocos2d::ValueVector vector;
		cocos2d::ValueMap tempMap; 
		tempMap["transactionIdentifier"] = PlatformStringToUtf8String(transactionIdentifier);
		tempMap["productIdentifier"] = PlatformStringToString(productId);
		tempMap["transactionId"] = PlatformStringToString(transactionId);
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
			tempMap["transactionIdentifier"] = PlatformStringToUtf8String(receiptXml);
			tempMap["productIdentifier"] = PlatformStringToString(unfulfilledConsumable->ProductId);
			tempMap["transactionId"] = PlatformStringToString(unfulfilledConsumable->TransactionId.ToString());
			tempMap["orderType"] = "Microsoft";
			vector.push_back(cocos2d::Value(tempMap));
		});
		if (vector.size()>0)CallLuaCallback(vector);
	}

	Windows::Foundation::Collections::IMap<Platform::String^, Windows::Foundation::Collections::IVector<Platform::String^>^>^ AdeasygoHelper::MSLoadListingInformationByProductIds(Windows::Foundation::Collections::IVector<Platform::String^>^ productIds)
	{
		Platform::Collections::Map<Platform::String^, Windows::Foundation::Collections::IVector<Platform::String^>^>^ ret = ref new Platform::Collections::Map<Platform::String^, Windows::Foundation::Collections::IVector<Platform::String^>^>();
		auto request = CurrentApp::LoadListingInformationByProductIdsAsync(productIds);
		create_task(request).then([&ret,this](task<ListingInformation^> task)
		{
			try
			{
				auto listingInformation = task.get();
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
			}
			catch (Platform::COMException^ e)
			{
				CallLuaCallbackException("ListingInformation");
			}
		}).wait();
		return ret;
	}

	void AdeasygoHelper::MSRequestProductPurchase(Platform::String^ productId)
	{
		RunOnUIThread([=](void){
			create_task(CurrentApp::RequestProductPurchaseAsync(productId)).then([=](task<PurchaseResults^> task)
			{
				try
				{
					auto results = task.get();
					if (results->Status == ProductPurchaseStatus::Succeeded)
					{
						CCLOGWARN("---finish buy---");
					}
					else if (results->Status == ProductPurchaseStatus::NotFulfilled)
					{
						CCLOGWARN("---have NotFulfilled---");
						CallLuaCallbakMicrosoft(productId, results->ReceiptXml,results->TransactionId.ToString());
					}
					else if (results->Status == ProductPurchaseStatus::NotPurchased)
					{
						CCLOGWARN("---not buy---");
					}
				}
				catch (Platform::COMException^ e)
				{
					CallLuaCallbackException("MSPay");
				}
			});
		});
	}
	void AdeasygoHelper::MSReportProductFulfillment(Platform::String^ productId, Platform::String^ transactionId)
	{
		if (transactionId->IsEmpty() || productId->IsEmpty())return;
		auto licenses = CurrentApp::LicenseInformation->ProductLicenses;
		if (licenses->HasKey(productId))
		{
			auto currentLicense = licenses->Lookup(productId);
			//暂时只支持消耗品
			if (currentLicense->IsActive && currentLicense->IsConsumable)
			{
				GUID guid;
				HRESULT hr = IIDFromString(transactionId->Data(), &guid);
				if (SUCCEEDED(hr)) {
					Platform::Guid guid_transactionId(guid);
					auto fuillAsync = CurrentApp::ReportConsumableFulfillmentAsync(productId, guid_transactionId);
					create_task(fuillAsync).then([=](task<Windows::ApplicationModel::Store::FulfillmentResult> task)
					{
						try
						{
							auto result = task.get();
							switch (result)
							{
							case Windows::ApplicationModel::Store::FulfillmentResult::Succeeded:
								CCLOGWARN("------FulfillmentResult::Succeeded------");
								break;
							case Windows::ApplicationModel::Store::FulfillmentResult::NothingToFulfill:
								CCLOGWARN("------FulfillmentResult::NothingToFulfill------");
								break;
							case Windows::ApplicationModel::Store::FulfillmentResult::PurchasePending:
								CCLOGWARN("------FulfillmentResult::PurchasePending------");
								break;
							case Windows::ApplicationModel::Store::FulfillmentResult::PurchaseReverted:
								CCLOGWARN(L"------FulfillmentResult::PurchaseReverted------");
								break;
							case Windows::ApplicationModel::Store::FulfillmentResult::ServerError:
								CCLOGWARN(L"------FulfillmentResult::ServerError------");
								break;
							default:
								break;
							}
						}
						catch (Platform::COMException^ e)
						{
							CallLuaCallbackException("MSReportProductFulfillment");
						}
					});
				}
			}
		}
	}

	Platform::String^ AdeasygoHelper::MSGetProductReceipt(Platform::String^ productId)
	{
		Platform::String^ ret = "";
		auto request = CurrentApp::GetProductReceiptAsync(productId);
		create_task(request).then([&ret,this](task<Platform::String^> task)
		{
			try
			{
				auto receiptXml = task.get();
				ret = receiptXml;
			}
			catch (Platform::COMException^ e)
			{
				CallLuaCallbackException("MSReceipt");
			}
		}).wait();
		return ret;
	}

	void AdeasygoHelper::MSGetUnfulfilledConsumables()
	{
		auto request = CurrentApp::GetUnfulfilledConsumablesAsync();
		create_task(request).then([=](task<Windows::Foundation::Collections::IVectorView<UnfulfilledConsumable^>^> task)
		{
			try
			{
				auto unfulfilledConsumables = task.get();
				CallLuaCallbakMicrosoft(unfulfilledConsumables);
			}
			catch (Platform::COMException^ e)
			{
				CallLuaCallbackException("Receipt");
			}
			
		}).wait();
	}
#endif /* WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP) */
}