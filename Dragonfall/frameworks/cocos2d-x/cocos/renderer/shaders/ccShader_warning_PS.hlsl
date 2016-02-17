Texture2D g_Texture0;

SamplerState TextureSampler
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Wrap;
	AddressV = Wrap;
};

// A constant buffer that stores the three basic column-major matrices for composing geometry.
cbuffer ConstantBuffer : register(b0)
{
	float2 iResolution;
	float ratio;
};

// Per-pixel color data passed through the pixel shader.
struct PixelShaderInput
{
	float4 pos : SV_POSITION;
	float4 color : COLOR0;
	float2 texUV : TEXCOORD0;
};

static const float RADIUS = distance(float2(0.5, 0.5), float2(0.0, 0.0));
static const float2 MIDDLE = float2(0.5, 0.5);
static const float len = 0.4;
static const float transit = 0.2;

// A pass-through function for the (interpolated) color data.
float4 main(PixelShaderInput input) : SV_TARGET
{
	float2 pt = input.texUV - MIDDLE;
	float d = max(abs(pt.x) - len, abs(pt.y) - len);
	float alpha = smoothstep(0.0, transit, (d / RADIUS)) * ratio;
	return float4(1.0 * alpha, 0.14 * alpha, 0.0, alpha);
}
