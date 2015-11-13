//
//  FacebookSimple.h
//  
//
//  Created by dannyhe on 2015/11/13.
//
#pragma once
using namespace Windows::Foundation;

namespace cocos2d
{
	namespace FacebookSimple
	{
		
		public ref class FacebookSimple sealed
		{
		private:
			FacebookSimple(){ m_clientID = nullptr; };

			Uri^ BuildLoginUri(Platform::String^ clientID);

			Platform::String^ GetRedirectUriString();

			Platform::String^ m_clientID;
		public:

			static property FacebookSimple^ Instance
			{
				FacebookSimple^ get()
				{
					static FacebookSimple^ instance = ref new FacebookSimple();
					return instance;
				}
			}

			void Initialize(Platform::String^ clientID);

			void SetAccessToken(Platform::String^ token);

			Platform::String^ GetAccessToken();

			void Login();

		};
	}
}