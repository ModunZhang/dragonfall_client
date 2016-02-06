#pragma once

NS_CC_BEGIN

class IWP8Win
{
public:
	virtual ID3D11Device2* GetDevice() = 0;
	virtual ID3D11DeviceContext2* GetContext() = 0;
	virtual ID3D11DepthStencilView* GetDepthStencilView() = 0;
	virtual ID3D11RenderTargetView* const* GetRenderTargetView() const = 0;
};

NS_CC_END
