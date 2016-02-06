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


#include "OpenGLESPage.g.h"

#include "DeviceResources.h"
#include "DirectXMain.h"
#if DIRECTX_ENABLED == 0
#include "OpenGLES.h"
#include <memory>
#include "Cocos2dRenderer.h"
#endif

namespace cocos2d
{
    public ref class OpenGLESPage sealed
    {
    public:
        OpenGLESPage();
        virtual ~OpenGLESPage();
		//dannyhe
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)
		void HardwareButtons_BackPressed(Platform::Object^ sender, Windows::Phone::UI::Input::BackPressedEventArgs^ e);
#endif
    internal:
#if DIRECTX_ENABLED == 0
        OpenGLESPage(OpenGLES* openGLES);
#endif

    private:
		void OnPageLoaded(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
		// XAML 低级渲染事件处理程序。
		//void OnRendering(Platform::Object^ sender, Platform::Object^ args);
        
		// 窗口事件处理程序。
        void OnVisibilityChanged(Windows::UI::Core::CoreWindow^ sender, Windows::UI::Core::VisibilityChangedEventArgs^ args);
        
		// DisplayInformation 事件处理程序。
		void OnDpiChanged(Windows::Graphics::Display::DisplayInformation^ sender, Platform::Object^ args);
		void OnOrientationChanged(Windows::Graphics::Display::DisplayInformation^ sender, Platform::Object^ args);
		void OnDisplayContentsInvalidated(Windows::Graphics::Display::DisplayInformation^ sender, Platform::Object^ args);

		// 其他事件处理程序。
		//void AppBarButton_Click(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e);
		void OnCompositionScaleChanged(Windows::UI::Xaml::Controls::SwapChainPanel^ sender, Object^ args);
		void OnSwapChainPanelSizeChanged(Platform::Object^ sender, Windows::UI::Xaml::SizeChangedEventArgs^ e);

		// 在后台工作线程上跟踪我们的独立输入。
		Windows::Foundation::IAsyncAction^ m_inputLoopWorker;
		Windows::UI::Core::CoreIndependentInputSource^ m_coreInput;

		// 独立输入处理函数。
		void OnPointerPressed(Platform::Object^ sender, Windows::UI::Core::PointerEventArgs^ e);
		void OnPointerMoved(Platform::Object^ sender, Windows::UI::Core::PointerEventArgs^ e);
		void OnPointerReleased(Platform::Object^ sender, Windows::UI::Core::PointerEventArgs^ e);

		// 用于在 XAML 页面背景中呈现 DirectX 内容的资源。
		std::shared_ptr<DX::DeviceResources> m_deviceResources;
		std::unique_ptr<DirectXMain> m_main;
		bool m_windowVisible;

		void TerminateApp();
#if DIRECTX_ENABLED == 0
        void GetSwapChainPanelSize(GLsizei* width, GLsizei* height);
        void CreateRenderSurface();
        void DestroyRenderSurface();
        void RecoverFromLostDevice();
		
        void StartRenderLoop();
        void StopRenderLoop();

        OpenGLES* mOpenGLES;
        std::shared_ptr<cocos2d::Cocos2dRenderer> m_renderer;

        Windows::Foundation::Size mSwapChainPanelSize;
        Concurrency::critical_section mSwapChainPanelSizeCriticalSection;

        Windows::Foundation::Size mCustomRenderSurfaceSize;
        bool mUseCustomRenderSurfaceSize;

        EGLSurface mRenderSurface;     // This surface is associated with a swapChainPanel on the page
        Concurrency::critical_section mRenderSurfaceCriticalSection;
        Windows::Foundation::IAsyncAction^ mRenderLoopWorker;

        float m_dpi;
        bool m_deviceLost;
        Windows::Graphics::Display::DisplayOrientations m_orientation;
#endif
    };
}
