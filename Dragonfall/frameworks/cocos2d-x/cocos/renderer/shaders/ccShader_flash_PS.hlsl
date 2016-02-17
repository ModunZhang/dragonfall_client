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
	float ratio;
};
 
// Per-pixel color data passed through the pixel shader.
struct PixelShaderInput
{
	float4 pos : SV_POSITION;
	float4 color : COLOR0;
	float2 texUV : TEXCOORD0;
};

static const float MAX_ = .4;
// A pass-through function for the (interpolated) color data.
float4 main(PixelShaderInput input) : SV_TARGET
{
	float4 col = g_Texture0.Sample(TextureSampler, input.texUV);
	float mid = step(0.5, ratio);
	float r = smoothstep(0.0, 1.0, ratio * (1.0 - mid) / 0.5) * (1.0 - mid) + smoothstep(0.0, 1.0, (1.0 - ratio) * mid / 0.5) * mid;
	return input.color * float4(col.rgb * (r * MAX_ + 1.0), col.a);
}
