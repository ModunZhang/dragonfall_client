Texture2D g_Texture0 : register(t0);

SamplerState TextureSampler : register(s0);

// A constant buffer that stores the three basic column-major matrices for composing geometry.
cbuffer ConstantBuffer : register(b0)
{
	float2 iResolution;
};
 
// Per-pixel color data passed through the pixel shader.
struct PixelShaderInput
{
	float4 pos : SV_POSITION;
	float4 color : COLOR0;
	float2 texUV : TEXCOORD0;
};

static float RADIUS = distance(float2(0.5, 0.5), float2(0.0, 0.0));
static float2 MIDDLE = float2(0.5, 0.5);
// A pass-through function for the (interpolated) color data.
float4 main(PixelShaderInput input) : SV_TARGET
{
	float2 pt = input.texUV - MIDDLE;
	pt.x *= iResolution.x / iResolution.y;
	float alpha = smoothstep(0.0, 0.7, distance(pt, float2(0.0, 0.0)) / RADIUS);
	return float4(float3(0.0, 0.0, 0.0), alpha);
}
