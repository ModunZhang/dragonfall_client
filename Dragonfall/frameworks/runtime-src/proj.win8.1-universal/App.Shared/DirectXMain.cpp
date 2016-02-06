#include "pch.h"
#include "DirectXMain.h"
#include "DirectXHelper.h"

using namespace cocos2d;
using namespace Platform;
using namespace Concurrency;
using namespace Windows::Foundation;
using namespace Windows::System::Threading;
using namespace Windows::Graphics::Display;
using namespace Windows::UI::Xaml;


// 加载应用程序时加载并初始化应用程序资产。
DirectXMain::DirectXMain(const std::shared_ptr<DX::DeviceResources>& deviceResources) :
m_deviceResources(deviceResources)
, m_pointerLocationX(0.0f)
#if DIRECTX_ENABLED == 0
, mRenderSurface(EGL_NO_SURFACE)
#endif
, m_orientation(DisplayOrientations::Landscape)
, m_deviceLost(false)
{
	// 注册以在设备丢失或重新创建时收到通知
	m_deviceResources->RegisterDeviceNotify(this);

	// TODO: 将此替换为应用程序内容的初始化。
	m_sceneRenderer = std::unique_ptr<Sample3DSceneRenderer>(new Sample3DSceneRenderer(m_deviceResources));

	//m_fpsTextRenderer = std::unique_ptr<SampleFpsTextRenderer>(new SampleFpsTextRenderer(m_deviceResources));

	// TODO: 如果需要默认的可变时间步长模式之外的其他模式，请更改计时器设置。
	// 例如，对于 60 FPS 固定时间步长更新逻辑，请调用:
	/*
	m_timer.SetFixedTimeStep(true);
	m_timer.SetTargetElapsedSeconds(1.0 / 60);
	*/
}

DirectXMain::~DirectXMain()
{
	// 取消注册设备通知
	m_deviceResources->RegisterDeviceNotify(nullptr);
}

// 在窗口大小更改(例如，设备方向更改)时更新应用程序状态
void DirectXMain::CreateWindowSizeDependentResources()
{
	// TODO: 将此替换为应用程序内容的与大小相关的初始化。
	m_sceneRenderer->CreateWindowSizeDependentResources();
}

void DirectXMain::StartRenderLoop()
{
	// 如果动画呈现循环已在运行，则请勿启动其他线程。
	if (m_renderLoopWorker != nullptr && m_renderLoopWorker->Status == AsyncStatus::Started)
	{
		return;
	}

	DisplayInformation^ currentDisplayInformation = DisplayInformation::GetForCurrentView();
	auto dpi = currentDisplayInformation->LogicalDpi;

	auto dispatcher = Windows::UI::Xaml::Window::Current->CoreWindow->Dispatcher;


	//创建一个将在后台线程上运行的任务。
	auto workItemHandler = ref new WorkItemHandler([this, dispatcher, dpi](IAsyncAction ^ action)
	{
		critical_section::scoped_lock lock(mRenderSurfaceCriticalSection);
#if DIRECTX_ENABLED == 0
		mOpenGLES.MakeCurrent(mRenderSurface);
#endif

		GLsizei panelWidth = 0;
		GLsizei panelHeight = 0;
		GetSwapChainPanelSize(&panelWidth, &panelHeight);

		if (m_renderer.get() == nullptr)
		{
			m_renderer = std::make_shared<Cocos2dRenderer>(panelWidth, panelHeight, dpi, m_orientation, dispatcher, swapChainPanel);
			m_renderer->SetDeviceResources(m_deviceResources);
		}

		if (m_deviceLost)
		{
			m_deviceLost = false;
			m_renderer->DeviceLost();
		}
		else
		{
			m_renderer->Resume();
		}

		while (action->Status == Windows::Foundation::AsyncStatus::Started && !m_deviceLost)
		{
#if DIRECTX_ENABLED == 0
			GetSwapChainPanelSize(&panelWidth, &panelHeight);
			m_renderer.get()->Draw(panelWidth, panelHeight, dpi, m_orientation);

			// The call to eglSwapBuffers might not be successful (i.e. due to Device Lost)
			// If the call fails, then we must reinitialize EGL and the GL resources.
			if (mOpenGLES.SwapBuffers(mRenderSurface) != GL_TRUE)
			{
				m_deviceLost = true;
				//dannyhe
				if (m_renderer)
				{
					m_renderer->Pause();
				}
				// XAML objects like the SwapChainPanel must only be manipulated on the UI thread.
				swapChainPanel->Dispatcher->RunAsync(Windows::UI::Core::CoreDispatcherPriority::High, ref new Windows::UI::Core::DispatchedHandler([=]()
				{
					RecoverFromLostDevice();
				}, CallbackContext::Any));

				return;
			}
#else
			{
				auto context = m_deviceResources->GetD3DDeviceContext();

				// 将视区重置为针对整个屏幕。
				auto viewport = m_deviceResources->GetScreenViewport();
				context->RSSetViewports(1, &viewport);

				// 将呈现目标重置为屏幕。
				ID3D11RenderTargetView *const targets[1] = { m_deviceResources->GetBackBufferRenderTargetView() };
				context->OMSetRenderTargets(1, targets, m_deviceResources->GetDepthStencilView());

				// 清除后台缓冲区和深度模具视图。
				context->ClearRenderTargetView(m_deviceResources->GetBackBufferRenderTargetView(), DirectX::Colors::Black);
				context->ClearDepthStencilView(m_deviceResources->GetDepthStencilView(), D3D11_CLEAR_DEPTH, 1.0f, 0);
				GetSwapChainPanelSize(&panelWidth, &panelHeight);
				m_renderer.get()->Draw(panelWidth, panelHeight, dpi, m_orientation);
				//Update();
				//Render();
				m_deviceResources->Present();
			}
#endif
		}
		//dannyhe
		if (m_renderer)
		{
			m_renderer->Pause();
		}
	});

	// 在高优先级的专用后台线程上运行任务。
	m_renderLoopWorker = ThreadPool::RunAsync(workItemHandler, WorkItemPriority::High, WorkItemOptions::TimeSliced);
}

void DirectXMain::StopRenderLoop()
{
	m_renderLoopWorker->Cancel();
}

// 每帧更新一次应用程序状态。
void DirectXMain::Update()
{
	//ProcessInput();

	// 更新场景对象。
	m_timer.Tick([&]()
	{
		// TODO: 将此替换为应用程序内容的更新函数。
		m_sceneRenderer->Update(m_timer);
		//m_fpsTextRenderer->Update(m_timer);
	});
}

//在更新游戏状态之前处理所有用户输入
void DirectXMain::ProcessInput()
{
	// TODO: 按帧输入处理在此处添加。
	//m_sceneRenderer->TrackingUpdate(m_pointerLocationX);
}

// 根据当前应用程序状态呈现当前帧。
// 如果帧已呈现并且已准备好显示，则返回 true。
bool DirectXMain::Render()
{
	// 在首次更新前，请勿尝试呈现任何内容。
	if (m_timer.GetFrameCount() == 0)
	{
		return false;
	}

	//auto context = m_deviceResources->GetD3DDeviceContext();

	//// 将视区重置为针对整个屏幕。
	//auto viewport = m_deviceResources->GetScreenViewport();
	//context->RSSetViewports(1, &viewport);

	//// 将呈现目标重置为屏幕。
	//ID3D11RenderTargetView *const targets[1] = { m_deviceResources->GetBackBufferRenderTargetView() };
	//context->OMSetRenderTargets(1, targets, m_deviceResources->GetDepthStencilView());

	//// 清除后台缓冲区和深度模具视图。
	//context->ClearRenderTargetView(m_deviceResources->GetBackBufferRenderTargetView(), DirectX::Colors::Black);
	//context->ClearDepthStencilView(m_deviceResources->GetDepthStencilView(), D3D11_CLEAR_DEPTH | D3D11_CLEAR_STENCIL, 1.0f, 0);

	// 呈现场景对象。
	// TODO: 将此替换为应用程序内容的渲染函数。
	m_sceneRenderer->Render();
	//m_fpsTextRenderer->Render();

	return true;
}


void DirectXMain::OnPointerPressed(Platform::Object^ sender, Windows::UI::Core::PointerEventArgs^ e)
{
	if (m_renderer.get())
	{
		m_renderer->QueuePointerEvent(PointerEventType::PointerPressed, e);
	}
}

void DirectXMain::OnPointerMoved(Platform::Object^ sender, Windows::UI::Core::PointerEventArgs^ e)
{
	if (m_renderer.get())
	{
		m_renderer->QueuePointerEvent(PointerEventType::PointerMoved, e);
	}
}

void DirectXMain::OnPointerReleased(Platform::Object^ sender, Windows::UI::Core::PointerEventArgs^ e)
{
	if (m_renderer.get())
	{
		m_renderer->QueuePointerEvent(PointerEventType::PointerReleased, e);
	}
}


// 通知呈现器，需要释放设备资源。
void DirectXMain::OnDeviceLost()
{
	m_sceneRenderer->ReleaseDeviceDependentResources();
	//m_fpsTextRenderer->ReleaseDeviceDependentResources();
}

// 通知呈现器，现在可重新创建设备资源。
void DirectXMain::OnDeviceRestored()
{
	m_sceneRenderer->CreateDeviceDependentResources();
	//m_fpsTextRenderer->CreateDeviceDependentResources();
	CreateWindowSizeDependentResources();
}


void DirectXMain::GetSwapChainPanelSize(GLsizei* width, GLsizei* height)
{
	critical_section::scoped_lock lock(GetCriticalSection());
	*width = static_cast<GLsizei>(mSwapChainPanelSize.Width);
	*height = static_cast<GLsizei>(mSwapChainPanelSize.Height);
}
void DirectXMain::CreateRenderSurface()
{
#if DIRECTX_ENABLED == 0
	mRenderSurface = mOpenGLES.CreateSurface(swapChainPanel, nullptr);
#endif
}
void DirectXMain::DestroyRenderSurface()
{
#if DIRECTX_ENABLED == 0
	mOpenGLES.DestroySurface(mRenderSurface);
	mRenderSurface = EGL_NO_SURFACE;
#endif
}
void DirectXMain::CleanupRenderSurface()
{
#if DIRECTX_ENABLED == 0
	mOpenGLES.DestroySurface(mRenderSurface);
	mOpenGLES.Cleanup(); // change Cleanup to public
#endif
}
void DirectXMain::RecoverFromLostDevice()
{
    // Stop the render loop, reset OpenGLES, recreate the render surface
    // and start the render loop again to recover from a lost device.

    StopRenderLoop();
#if DIRECTX_ENABLED == 0
    {
		critical_section::scoped_lock lock(mRenderSurfaceCriticalSection);
        DestroyRenderSurface();
        mOpenGLES.Reset();
        CreateRenderSurface();
    }
#endif

    StartRenderLoop();
}
