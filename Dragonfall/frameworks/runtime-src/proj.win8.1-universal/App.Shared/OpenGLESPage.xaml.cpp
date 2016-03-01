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

#include "pch.h"
#include "OpenGLESPage.xaml.h"
#include "AdeasygoSDK/AdeasygoHelper.h"

using namespace cocos2d;

using namespace Platform;
using namespace Concurrency;
using namespace Windows::Foundation;
using namespace Windows::Foundation::Collections;
using namespace Windows::Graphics::Display;
using namespace Windows::System::Threading;
using namespace Windows::UI::Core;
using namespace Windows::UI::Input;
using namespace Windows::UI::Xaml;
using namespace Windows::UI::Xaml::Controls;
using namespace Windows::UI::Xaml::Controls::Primitives;
using namespace Windows::UI::Xaml::Data;
using namespace Windows::UI::Xaml::Input;
using namespace Windows::UI::Xaml::Media;
using namespace Windows::UI::Xaml::Navigation;

OpenGLESPage::OpenGLESPage() :
m_windowVisible(true),
m_coreInput(nullptr)
{
	InitializeComponent();
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)
	//dannyhe
	Windows::Phone::UI::Input::HardwareButtons::BackPressed += ref new Windows::Foundation::EventHandler<Windows::Phone::UI::Input::BackPressedEventArgs^>(this, &OpenGLESPage::HardwareButtons_BackPressed);
	Windows::UI::ViewManagement::ApplicationView::GetForCurrentView()->SuppressSystemOverlays = true; //full screen if switch auto hide navigation bar "on"
	Windows::UI::ViewManagement::ApplicationView::GetForCurrentView()->SetDesiredBoundsMode(Windows::UI::ViewManagement::ApplicationViewBoundsMode::UseCoreWindow);
	//end
#endif

	// 注册页面生命周期的事件处理程序。
	CoreWindow^ window = Window::Current->CoreWindow;

	window->VisibilityChanged +=
		ref new TypedEventHandler<CoreWindow^, VisibilityChangedEventArgs^>(this, &OpenGLESPage::OnVisibilityChanged);

	DisplayInformation^ currentDisplayInformation = DisplayInformation::GetForCurrentView();

	currentDisplayInformation->DpiChanged +=
		ref new TypedEventHandler<DisplayInformation^, Object^>(this, &OpenGLESPage::OnDpiChanged);

	currentDisplayInformation->OrientationChanged +=
		ref new TypedEventHandler<DisplayInformation^, Object^>(this, &OpenGLESPage::OnOrientationChanged);

	DisplayInformation::DisplayContentsInvalidated +=
		ref new TypedEventHandler<DisplayInformation^, Object^>(this, &OpenGLESPage::OnDisplayContentsInvalidated);

	swapChainPanel->CompositionScaleChanged +=
		ref new TypedEventHandler<SwapChainPanel^, Object^>(this, &OpenGLESPage::OnCompositionScaleChanged);

	swapChainPanel->SizeChanged +=
		ref new SizeChangedEventHandler(this, &OpenGLESPage::OnSwapChainPanelSizeChanged);

	this->Loaded +=
		        ref new Windows::UI::Xaml::RoutedEventHandler(this, &OpenGLESPage::OnPageLoaded);

	#if (WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
	    Windows::UI::ViewManagement::StatusBar::GetForCurrentView()->HideAsync();
	#else
	    // Disable all pointer visual feedback for better performance when touching.
	    // This is not supported on Windows Phone applications.
	    auto pointerVisualizationSettings = Windows::UI::Input::PointerVisualizationSettings::GetForCurrentView();
	    pointerVisualizationSettings->IsContactFeedbackEnabled = false;
	    pointerVisualizationSettings->IsBarrelButtonFeedbackEnabled = false;
	#endif

	// 此时，我们具有访问设备的权限。
	// 我们可创建与设备相关的资源。
	m_deviceResources = std::make_shared<DX::DeviceResources>();
	m_deviceResources->SetSwapChainPanel(swapChainPanel);

	// 注册我们的 SwapChainPanel 以获取独立的输入指针事件
	auto workItemHandler = ref new WorkItemHandler([this](IAsyncAction ^)
	{
		// 对于指定的设备类型，无论它是在哪个线程上，CoreIndependentInputSource 都将引发指针事件。
		m_coreInput = swapChainPanel->CreateCoreIndependentInputSource(
			Windows::UI::Core::CoreInputDeviceTypes::Mouse |
			Windows::UI::Core::CoreInputDeviceTypes::Touch |
			Windows::UI::Core::CoreInputDeviceTypes::Pen
			);

		// 指针事件的寄存器，将在后台线程上引发。
		m_coreInput->PointerPressed += ref new TypedEventHandler<Object^, PointerEventArgs^>(this, &OpenGLESPage::OnPointerPressed);
		m_coreInput->PointerMoved += ref new TypedEventHandler<Object^, PointerEventArgs^>(this, &OpenGLESPage::OnPointerMoved);
		m_coreInput->PointerReleased += ref new TypedEventHandler<Object^, PointerEventArgs^>(this, &OpenGLESPage::OnPointerReleased);

		// 一旦发送输入消息，即开始处理它们。
		m_coreInput->Dispatcher->ProcessEvents(CoreProcessEventsOption::ProcessUntilQuit);
	});

	// 在高优先级的专用后台线程上运行任务。
	m_inputLoopWorker = ThreadPool::RunAsync(workItemHandler, WorkItemPriority::High, WorkItemOptions::TimeSliced);

	m_main = std::unique_ptr<DirectXMain>(new DirectXMain(m_deviceResources));
	m_main->SetOrientation(currentDisplayInformation->CurrentOrientation);
	m_main->SetSwapChainPanel(swapChainPanel);
}
//
//OpenGLESPage::OpenGLESPage(OpenGLES* openGLES) :
//    mOpenGLES(openGLES),
//    mRenderSurface(EGL_NO_SURFACE),
//    mCustomRenderSurfaceSize(0,0),
//    mUseCustomRenderSurfaceSize(false),
//    m_coreInput(nullptr),
//    m_dpi(0.0f),
//    m_deviceLost(false),
//    m_orientation(DisplayOrientations::Landscape
//	)
//{
//    InitializeComponent();
//#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)
//   //dannyhe
//	Windows::Phone::UI::Input::HardwareButtons::BackPressed += ref new Windows::Foundation::EventHandler<Windows::Phone::UI::Input::BackPressedEventArgs^>(this, &OpenGLESPage::HardwareButtons_BackPressed);
//	Windows::UI::ViewManagement::ApplicationView::GetForCurrentView()->SuppressSystemOverlays = true; //full screen if switch auto hide navigation bar "on"
//	Windows::UI::ViewManagement::ApplicationView::GetForCurrentView()->SetDesiredBoundsMode(Windows::UI::ViewManagement::ApplicationViewBoundsMode::UseCoreWindow);
//	//end
//#endif
//    Windows::UI::Core::CoreWindow^ window = Windows::UI::Xaml::Window::Current->CoreWindow;
//
//    window->VisibilityChanged +=
//        ref new Windows::Foundation::TypedEventHandler<Windows::UI::Core::CoreWindow^, Windows::UI::Core::VisibilityChangedEventArgs^>(this, &OpenGLESPage::OnVisibilityChanged);
//
//    swapChainPanel->SizeChanged +=
//        ref new Windows::UI::Xaml::SizeChangedEventHandler(this, &OpenGLESPage::OnSwapChainPanelSizeChanged);
//
//    DisplayInformation^ currentDisplayInformation = DisplayInformation::GetForCurrentView();
//
//    currentDisplayInformation->OrientationChanged +=
//        ref new TypedEventHandler<DisplayInformation^, Object^>(this, &OpenGLESPage::OnOrientationChanged);
//
//    m_orientation = currentDisplayInformation->CurrentOrientation;
//
//    this->Loaded +=
//        ref new Windows::UI::Xaml::RoutedEventHandler(this, &OpenGLESPage::OnPageLoaded);
//
//    mSwapChainPanelSize = { swapChainPanel->RenderSize.Width, swapChainPanel->RenderSize.Height };
//
//#if (WINAPI_FAMILY == WINAPI_FAMILY_PHONE_APP)
//    Windows::UI::ViewManagement::StatusBar::GetForCurrentView()->HideAsync();
//#else
//    // Disable all pointer visual feedback for better performance when touching.
//    // This is not supported on Windows Phone applications.
//    auto pointerVisualizationSettings = Windows::UI::Input::PointerVisualizationSettings::GetForCurrentView();
//    pointerVisualizationSettings->IsContactFeedbackEnabled = false;
//    pointerVisualizationSettings->IsBarrelButtonFeedbackEnabled = false;
//#endif
//
//    // Register our SwapChainPanel to get independent input pointer events
//    auto workItemHandler = ref new WorkItemHandler([this](IAsyncAction ^)
//    {
//        // The CoreIndependentInputSource will raise pointer events for the specified device types on whichever thread it's created on.
//        m_coreInput = swapChainPanel->CreateCoreIndependentInputSource(
//            Windows::UI::Core::CoreInputDeviceTypes::Mouse |
//            Windows::UI::Core::CoreInputDeviceTypes::Touch |
//            Windows::UI::Core::CoreInputDeviceTypes::Pen
//            );
//
//        // Register for pointer events, which will be raised on the background thread.
//        m_coreInput->PointerPressed += ref new TypedEventHandler<Object^, PointerEventArgs^>(this, &OpenGLESPage::OnPointerPressed);
//        m_coreInput->PointerMoved += ref new TypedEventHandler<Object^, PointerEventArgs^>(this, &OpenGLESPage::OnPointerMoved);
//        m_coreInput->PointerReleased += ref new TypedEventHandler<Object^, PointerEventArgs^>(this, &OpenGLESPage::OnPointerReleased);
//
//        // Begin processing input messages as they're delivered.
//        m_coreInput->Dispatcher->ProcessEvents(CoreProcessEventsOption::ProcessUntilQuit);
//    });
//
//    // Run task on a dedicated high priority background thread.
//    m_inputLoopWorker = ThreadPool::RunAsync(workItemHandler, WorkItemPriority::High, WorkItemOptions::TimeSliced);
//
//}


OpenGLESPage::~OpenGLESPage()
{
	// 析构时停止渲染和处理事件。
	m_main->StopRenderLoop();
#if DIRECTX_ENABLED == 0
	m_main->DestroyRenderSurface();
#endif
	m_coreInput->Dispatcher->StopProcessEvents();
}

void OpenGLESPage::OnPageLoaded(Platform::Object^ sender, Windows::UI::Xaml::RoutedEventArgs^ e)
{
    // The SwapChainPanel has been created and arranged in the page layout, so EGL can be initialized.
#if DIRECTX_ENABLED == 0
	m_main->CreateRenderSurface();
#endif
	m_main->StartRenderLoop();
}
#if 0

void OpenGLESPage::OnPointerPressed(Object^ sender, PointerEventArgs^ e)
{
    if (m_renderer)
    {
        m_renderer->QueuePointerEvent(PointerEventType::PointerPressed, e);
    }
}

void OpenGLESPage::OnPointerMoved(Object^ sender, PointerEventArgs^ e)
{
    if (m_renderer)
    {
        m_renderer->QueuePointerEvent(PointerEventType::PointerMoved, e);
    }
}

void OpenGLESPage::OnPointerReleased(Object^ sender, PointerEventArgs^ e)
{
    if (m_renderer)
    {
        m_renderer->QueuePointerEvent(PointerEventType::PointerReleased, e);
    }
}

void OpenGLESPage::OnOrientationChanged(DisplayInformation^ sender, Object^ args)
{
    critical_section::scoped_lock lock(mSwapChainPanelSizeCriticalSection);
   m_orientation = sender->CurrentOrientation;
}

void OpenGLESPage::OnVisibilityChanged(Windows::UI::Core::CoreWindow^ sender, Windows::UI::Core::VisibilityChangedEventArgs^ args)
{
    if (args->Visible && mRenderSurface != EGL_NO_SURFACE)
    {
        StartRenderLoop();
    }
    else
    {
        StopRenderLoop();
    }
}

void OpenGLESPage::OnSwapChainPanelSizeChanged(Object^ sender, Windows::UI::Xaml::SizeChangedEventArgs^ e)
{
    // Size change events occur outside of the render thread.  A lock is required when updating
    // the swapchainpanel size
    critical_section::scoped_lock lock(mSwapChainPanelSizeCriticalSection);
    mSwapChainPanelSize = { e->NewSize.Width, e->NewSize.Height };
	extendedSplashImage->Height = e->NewSize.Height;
	extendedSplashImage->Width = e->NewSize.Width;
}

void OpenGLESPage::GetSwapChainPanelSize(GLsizei* width, GLsizei* height)
{
    critical_section::scoped_lock lock(mSwapChainPanelSizeCriticalSection);
    // If a custom render surface size is specified, return its size instead of
    // the swapchain panel size.
    if (mUseCustomRenderSurfaceSize)
    {
        *width = static_cast<GLsizei>(mCustomRenderSurfaceSize.Width);
        *height = static_cast<GLsizei>(mCustomRenderSurfaceSize.Height);
    }
    else
    {
        *width = static_cast<GLsizei>(mSwapChainPanelSize.Width);
        *height = static_cast<GLsizei>(mSwapChainPanelSize.Height);
    }
}

void OpenGLESPage::CreateRenderSurface()
{
    if (mOpenGLES)
    {
        //
        // A Custom render surface size can be specified by uncommenting the following lines.
        // The render surface will be automatically scaled to fit the entire window.  Using a
        // smaller sized render surface can result in a performance gain.
        //
        //mCustomRenderSurfaceSize = Size(800, 600);
        //mUseCustomRenderSurfaceSize = true;

        mRenderSurface = mOpenGLES->CreateSurface(swapChainPanel, mUseCustomRenderSurfaceSize ? &mCustomRenderSurfaceSize : nullptr);
    }
}

void OpenGLESPage::DestroyRenderSurface()
{
    if (mOpenGLES)
    {
        mOpenGLES->DestroySurface(mRenderSurface);
    }
    mRenderSurface = EGL_NO_SURFACE;
}

void OpenGLESPage::RecoverFromLostDevice()
{
    // Stop the render loop, reset OpenGLES, recreate the render surface
    // and start the render loop again to recover from a lost device.

    StopRenderLoop();

    {
        critical_section::scoped_lock lock(mRenderSurfaceCriticalSection);
        DestroyRenderSurface();
        mOpenGLES->Reset();
        CreateRenderSurface();
    }

    StartRenderLoop();
}

void OpenGLESPage::StartRenderLoop()
{
    // If the render loop is already running then do not start another thread.
    if (mRenderLoopWorker != nullptr && mRenderLoopWorker->Status == Windows::Foundation::AsyncStatus::Started)
    {
        return;
    }

    DisplayInformation^ currentDisplayInformation = DisplayInformation::GetForCurrentView();
    m_dpi = currentDisplayInformation->LogicalDpi;

    auto dispatcher = Windows::UI::Xaml::Window::Current->CoreWindow->Dispatcher;

    // Create a task for rendering that will be run on a background thread.
    auto workItemHandler = ref new Windows::System::Threading::WorkItemHandler([this, dispatcher](Windows::Foundation::IAsyncAction ^ action)
    {
        critical_section::scoped_lock lock(mRenderSurfaceCriticalSection);

        mOpenGLES->MakeCurrent(mRenderSurface);

        GLsizei panelWidth = 0;
        GLsizei panelHeight = 0;
        GetSwapChainPanelSize(&panelWidth, &panelHeight);
        


        if (m_renderer.get() == nullptr)
        {
            m_renderer = std::make_shared<Cocos2dRenderer>(panelWidth, panelHeight, m_dpi, m_orientation, dispatcher, swapChainPanel);
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
            GetSwapChainPanelSize(&panelWidth, &panelHeight);
            m_renderer.get()->Draw(panelWidth, panelHeight, m_dpi, m_orientation);

            // The call to eglSwapBuffers might not be successful (i.e. due to Device Lost)
            // If the call fails, then we must reinitialize EGL and the GL resources.
            if (mOpenGLES->SwapBuffers(mRenderSurface) != GL_TRUE)
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
        }
		//dannyhe
		if (m_renderer)
		{
			m_renderer->Pause();
		}
    });

    // Run task on a dedicated high priority background thread.
    mRenderLoopWorker = Windows::System::Threading::ThreadPool::RunAsync(workItemHandler, Windows::System::Threading::WorkItemPriority::High, Windows::System::Threading::WorkItemOptions::TimeSliced);
}

void OpenGLESPage::StopRenderLoop()
{
    if (mRenderLoopWorker)
    {
        mRenderLoopWorker->Cancel();
        mRenderLoopWorker = nullptr;
    }
}

#endif
void OpenGLESPage::TerminateApp()
{
#if DIRECTX_ENABLED == 0
	m_main->CleanupRenderSurface();
#endif
	Windows::UI::Xaml::Application::Current->Exit();
}
//
#if WINAPI_FAMILY_PARTITION(WINAPI_PARTITION_PHONE_APP)
void OpenGLESPage::HardwareButtons_BackPressed(Platform::Object^ sender, Windows::Phone::UI::Input::BackPressedEventArgs^ e)
{
#if defined(__AdeasygoSDK__)
	if (!cocos2d::AdeasygoHelper::Instance->IsVisible)
#endif // defined(__AdeasygoSDK__)
	{
		using namespace Windows::UI::Popups;
		auto loader = ref new Windows::ApplicationModel::Resources::ResourceLoader();
		auto title = loader->GetString("exit_game_title");
		auto content = loader->GetString("exit_game_content");
		auto yes_string = loader->GetString("yes");
		auto no_string = loader->GetString("no");
		auto msgDlg = ref new MessageDialog(content, title);

		msgDlg->Commands->Append(ref new UICommand(yes_string, ref new UICommandInvokedHandler([this](IUICommand^)
		{
			TerminateApp();
		})));
		msgDlg->Commands->Append(ref new UICommand(no_string, ref new UICommandInvokedHandler([=](IUICommand^){})));
		msgDlg->ShowAsync();
	}
#if defined(__AdeasygoSDK__)
	cocos2d::AdeasygoHelper::Instance->IsVisible = false;
#endif // defined(__AdeasygoSDK__)
	e->Handled = true;
}
#endif

// 窗口事件处理程序。

void OpenGLESPage::OnVisibilityChanged(CoreWindow^ sender, VisibilityChangedEventArgs^ args)
{
	m_windowVisible = args->Visible;
	if (m_windowVisible)
	{
		m_main->StartRenderLoop();
	}
	else
	{
		m_main->StopRenderLoop();
	}
}


// DisplayInformation 事件处理程序。

void OpenGLESPage::OnDpiChanged(DisplayInformation^ sender, Object^ args)
{
	critical_section::scoped_lock lock(m_main->GetCriticalSection());
	m_deviceResources->SetDpi(sender->LogicalDpi);
	m_main->CreateWindowSizeDependentResources();
}

void OpenGLESPage::OnOrientationChanged(DisplayInformation^ sender, Object^ args)
{
	critical_section::scoped_lock lock(m_main->GetCriticalSection());
	m_deviceResources->SetCurrentOrientation(sender->CurrentOrientation);
	m_main->CreateWindowSizeDependentResources();
	m_main->SetOrientation(sender->CurrentOrientation);
}


void OpenGLESPage::OnDisplayContentsInvalidated(DisplayInformation^ sender, Object^ args)
{
	critical_section::scoped_lock lock(m_main->GetCriticalSection());
	m_deviceResources->ValidateDevice();
}

void OpenGLESPage::OnPointerPressed(Object^ sender, PointerEventArgs^ e)
{
	// 按下指针时开始跟踪指针移动。
	m_main->OnPointerPressed(sender, e);
}

void OpenGLESPage::OnPointerMoved(Object^ sender, PointerEventArgs^ e)
{
	// 更新指针跟踪代码。
	m_main->OnPointerMoved(sender, e);
}

void OpenGLESPage::OnPointerReleased(Object^ sender, PointerEventArgs^ e)
{
	// 释放指针时停止跟踪指针移动。
	m_main->OnPointerReleased(sender, e);
}

void OpenGLESPage::OnCompositionScaleChanged(SwapChainPanel^ sender, Object^ args)
{
	critical_section::scoped_lock lock(m_main->GetCriticalSection());
	m_deviceResources->SetCompositionScale(sender->CompositionScaleX, sender->CompositionScaleY);
	m_main->CreateWindowSizeDependentResources();
}

void OpenGLESPage::OnSwapChainPanelSizeChanged(Object^ sender, SizeChangedEventArgs^ e)
{
	critical_section::scoped_lock lock(m_main->GetCriticalSection());
	m_deviceResources->SetLogicalSize(e->NewSize);
	m_main->CreateWindowSizeDependentResources();

	m_main->SetSwapChainPanelSize({ e->NewSize.Width, e->NewSize.Height });
	extendedSplashImage->Height = e->NewSize.Height;
	extendedSplashImage->Width = e->NewSize.Width;
}

// 如果在电话应用程序中使用应用程序栏，则取消对其的注释。
// 在单击应用程序栏按钮时调用。
//void OpenGLESPage::AppBarButton_Click(Object^ sender, RoutedEventArgs^ e)
//{
//	// 如果应用程序栏适合您的应用程序，则使用它。设计应用程序栏，
//	// 然后填充事件处理程序(与此示例类似)。
//}
