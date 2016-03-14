Texture2D g_Texture0 : register(t0);

SamplerState TextureSampler : register(s0);

// A constant buffer that stores the three basic column-major matrices for composing geometry.
cbuffer ConstantBuffer : register(b0)
{
	float unit_count;
	float unit_len;
};
 
// Per-pixel color data passed through the pixel shader.
struct PixelShaderInput
{
	float4 pos : SV_POSITION;
	float4 color : COLOR0;
	float2 texUV : TEXCOORD0;
};

// A pass-through function for the (interpolated) color data.
float4 main(PixelShaderInput input) : SV_TARGET
{
	float y = fmod(input.texUV.y, unit_len) * unit_count;
	return g_Texture0.Sample(TextureSampler, float2(input.texUV.x, y));
}
