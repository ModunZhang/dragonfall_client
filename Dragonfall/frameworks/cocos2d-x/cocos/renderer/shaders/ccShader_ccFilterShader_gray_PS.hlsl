Texture2D g_Texture0 : register(t0);

SamplerState TextureSampler : register(s0);

// A constant buffer that stores the three basic column-major matrices for composing geometry.
cbuffer ConstantBuffer : register(b0)
{
	float4 u_grayParam;
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
	float4 texColor = g_Texture0.Sample(TextureSampler, input.texUV);
	float grey = dot(texColor.rgba, u_grayParam);
	return float4(float3(grey, grey, grey), texColor.a) * input.color;
}
