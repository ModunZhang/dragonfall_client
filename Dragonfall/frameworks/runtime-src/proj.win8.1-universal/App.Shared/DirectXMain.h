#pragma once

#include "StepTimer.h"
#include "DeviceResources.h"
#include "Sample3DSceneRenderer.h"
#include "SampleFpsTextRenderer.h"

#if DIRECTX_ENABLED == 0
#include "OpenGLES.h"
#endif

#include "Cocos2dRenderer.h"

// 在屏幕上呈现 Direct2D 和 3D 内容。
namespace cocos2d
{
	class DirectXMain : public DX::IDeviceNotify
	{
	public:
		DirectXMain(const std::shared_ptr<DX::DeviceResources>& deviceResources);
		~DirectXMain();
		void CreateWindowSizeDependentResources();
		void StartTracking() { m_sceneRenderer->StartTracking(); }
		void TrackingUpdate(float positionX) { m_pointerLocationX = positionX; }
		void StopTracking() { m_sceneRenderer->StopTracking(); }
		bool IsTracking() { return m_sceneRenderer->IsTracking(); }
		void StartRenderLoop();
		void StopRenderLoop();
		Concurrency::critical_section& GetCriticalSection() { return m_criticalSection; }


		// 独立输入处理函数。
		void OnPointerPressed(Platform::Object^ sender, Windows::UI::Core::PointerEventArgs^ e);
		void OnPointerMoved(Platform::Object^ sender, Windows::UI::Core::PointerEventArgs^ e);
		void OnPointerReleased(Platform::Object^ sender, Windows::UI::Core::PointerEventArgs^ e);

		// IDeviceNotify
		virtual void OnDeviceLost();
		virtual void OnDeviceRestored();

		void SetOrientation(const Windows::Graphics::Display::DisplayOrientations& orientation)
		{
			this->m_orientation = orientation;
		}
		void SetSwapChainPanelSize(const Windows::Foundation::Size& size)
		{
			this->mSwapChainPanelSize = size;
		}
		void SetSwapChainPanel(Windows::UI::Xaml::Controls::SwapChainPanel^ panel)
		{
			this->swapChainPanel = panel;
			this->mSwapChainPanelSize = { panel->RenderSize.Width, panel->RenderSize.Height };
		}
		void CreateRenderSurface();
		void DestroyRenderSurface();
		void CleanupRenderSurface();
	private:
		void GetSwapChainPanelSize(GLsizei* width, GLsizei* height);
		void RecoverFromLostDevice();

		void ProcessInput();
		void Update();
		bool Render();

		// 缓存的设备资源指针。
		std::shared_ptr<DX::DeviceResources> m_deviceResources;

		// TODO: 将此替换为您自己的内容呈现器。
		std::unique_ptr<Sample3DSceneRenderer> m_sceneRenderer;
		std::unique_ptr<SampleFpsTextRenderer> m_fpsTextRenderer;

		Windows::Foundation::IAsyncAction^ m_renderLoopWorker;
		Concurrency::critical_section m_criticalSection;
		Concurrency::critical_section mRenderSurfaceCriticalSection;

		// 渲染循环计时器。
		DX::StepTimer m_timer;

		//跟踪当前输入指针位置
		float m_pointerLocationX;


#if DIRECTX_ENABLED == 0
		OpenGLES mOpenGLES;
		EGLSurface mRenderSurface;
#endif
		Windows::Foundation::Size mSwapChainPanelSize;
		Windows::UI::Xaml::Controls::SwapChainPanel^ swapChainPanel;

		std::shared_ptr<cocos2d::Cocos2dRenderer> m_renderer;
		Windows::Graphics::Display::DisplayOrientations m_orientation;
		bool m_deviceLost;
		
	};
}