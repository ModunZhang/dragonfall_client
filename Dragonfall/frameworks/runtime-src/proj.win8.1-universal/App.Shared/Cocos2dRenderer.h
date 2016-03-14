/*
* cocos2d-x   http://www.cocos2d-x.org
*
* Copyright (c) 2010-2014 - cocos2d-x community
*
* Portions Copyright (c) Microsoft Open Technologies, Inc.
* All Rights Reserved
*
* Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an
* "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and limitations under the License.
*/
#pragma once

#include <agile.h>

#include "cocos2d.h"
#include "platform/wp8-xaml/cpp/IWP8Win.h"

class AppDelegate;

namespace cocos2d
{
    class Cocos2dRenderer
    {
    public:
        Cocos2dRenderer(int width, int height, float dpi, 
            Windows::Graphics::Display::DisplayOrientations orientation, 
            Windows::UI::Core::CoreDispatcher^ dispathcer, Windows::UI::Xaml::Controls::Panel^ panel);
        ~Cocos2dRenderer();
        void Draw(GLsizei width, GLsizei height, float dpi, Windows::Graphics::Display::DisplayOrientations orientation);
        void QueuePointerEvent(PointerEventType type, Windows::UI::Core::PointerEventArgs^ args);
        void QueueKeyBoardEvent(Cocos2dKeyEvent type, Windows::UI::Core::KeyEventArgs^ e);
        void Pause();
        void Resume();
        void DeviceLost();
		void Clear();

		void SetDeviceResources(const std::shared_ptr<DX::DeviceResources>& deviceResources)
		{
			m_deviceResources = deviceResources;
		}
		std::shared_ptr<DX::DeviceResources>& GetDeviceResources()
		{
			return m_deviceResources;
		}
    private:

        int m_width;
        int m_height;
        float m_dpi;

        // The AppDelegate for the Cocos2D app
        AppDelegate* m_app;
        Platform::Agile<Windows::UI::Core::CoreDispatcher> m_dispatcher;
        Platform::Agile<Windows::UI::Xaml::Controls::Panel> m_panel;
        Windows::Graphics::Display::DisplayOrientations m_orientation;

		std::shared_ptr<DX::DeviceResources> m_deviceResources;
		Microsoft::WRL::ComPtr<ID3D11DepthStencilState> m_depthStencilState;

	private:
		static Cocos2dRenderer* m_instance;
		class WP8Window* m_wp8window;
	public:
		static Cocos2dRenderer* GetInstance()
		{
			return m_instance;
		}

		friend class WP8Window;
    };


	class WP8Window : public cocos2d::IWP8Win
	{
		virtual ID3D11Device2* GetDevice()
		{
			return Cocos2dRenderer::GetInstance()->m_deviceResources->GetD3DDevice();
		}

		virtual ID3D11DeviceContext2* GetContext()
		{
			return Cocos2dRenderer::GetInstance()->m_deviceResources->GetD3DDeviceContext();
		}

		virtual ID3D11DepthStencilView* GetDepthStencilView()
		{
			return Cocos2dRenderer::GetInstance()->m_deviceResources->GetDepthStencilView();
		}

		virtual ID3D11RenderTargetView* const* GetRenderTargetView() const
		{
			return Cocos2dRenderer::GetInstance()->m_deviceResources->GetBackBufferRenderTargetViewAddress();
		}
	};
}

