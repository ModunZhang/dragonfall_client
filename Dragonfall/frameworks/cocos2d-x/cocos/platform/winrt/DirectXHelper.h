//-----------------------------------------------------------------------------------------------
// Copyright (c) 2012 Andrew Garrison
//-----------------------------------------------------------------------------------------------
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
// and associated documentation files (the "Software"), to deal in the Software without 
// restriction, including without limitation the rights to use, copy, modify, merge, publish, 
// distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or 
// substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//-----------------------------------------------------------------------------------------------
#pragma once


#include "platform/CCPlatformConfig.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WINRT)
#include <ppltasks.h>	// 对于 create_task
// Helper utilities to make Win32 APIs work with exceptions.
namespace DX
{
   inline void ThrowIfFailed(HRESULT hr)
   {
      if (FAILED(hr))
      {
         // Set a breakpoint on this line to catch Win32 API errors.
         throw Platform::Exception::CreateException(hr);
      }
   }

   // 从二进制文件中执行异步读取操作的函数。
	inline Concurrency::task< std::vector<byte> > ReadDataAsync(const std::wstring& filename)
	{
		using namespace Windows::Storage;
		using namespace Concurrency;

		auto folder = Windows::ApplicationModel::Package::Current->InstalledLocation;

		return create_task(folder->GetFileAsync(Platform::StringReference(filename.c_str()))).then([] (StorageFile^ file) 
		{
			return FileIO::ReadBufferAsync(file);
		}).then([] (Streams::IBuffer^ fileBuffer) -> std::vector<byte> 
		{
			std::vector<byte> returnBuffer;
			returnBuffer.resize(fileBuffer->Length);
			Streams::DataReader::FromBuffer(fileBuffer)->ReadBytes(Platform::ArrayReference<byte>(returnBuffer.data(), fileBuffer->Length));
			return returnBuffer;
		});
	}

	// 将使用与设备无关的像素(DIP)表示的长度转换为使用物理像素表示的长度。
	inline float ConvertDipsToPixels(float dips, float dpi)
	{
		static const float dipsPerInch = 96.0f;
		return floorf(dips * dpi / dipsPerInch + 0.5f); // 舍入到最接近的整数。
	}


#if defined(_DEBUG)
   // 请检查 SDK 层支持。
   inline bool SdkLayersAvailable()
   {
	   HRESULT hr = D3D11CreateDevice(
		   nullptr,
		   D3D_DRIVER_TYPE_NULL,       // 无需创建实际硬件设备。
		   0,
		   D3D11_CREATE_DEVICE_DEBUG,  // 请检查 SDK 层。
		   nullptr,                    // 任何功能级别都会这样。
		   0,
		   D3D11_SDK_VERSION,          // 对于 Windows 应用商店应用，始终将此值设置为 D3D11_SDK_VERSION。
		   nullptr,                    // 无需保留 D3D 设备引用。
		   nullptr,                    // 无需知道功能级别。
		   nullptr                     // 无需保留 D3D 设备上下文引用。
		   );

	   return SUCCEEDED(hr);
   }
#endif
}

#endif // (CC_TARGET_PLATFORM == CC_PLATFORM_WINRT)
