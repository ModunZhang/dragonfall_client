Texture2D g_Texture0 : register(t0);

SamplerState TextureSampler : register(s0);

// A constant buffer that stores the three basic column-major matrices for composing geometry.
cbuffer ConstantBuffer : register(b0)
{
	float4 rect;
	float enable;
};
static const float EDGE = 0.005;
 
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
	if (enable < 1.0) {
		return float4(0.0, 0.0, 0.0, 0.6);
	}
	float a = 0.;
	a = step(input.texUV.x - rect.x, 0.0) * smoothstep(0.0, EDGE, rect.x - input.texUV.x);
	a += step(input.texUV.y - rect.y, 0.0) * smoothstep(0.0, EDGE, rect.y - input.texUV.y);
	a += step(0.0, input.texUV.x - rect.x - rect.z) * smoothstep(0.0, EDGE, input.texUV.x - rect.x - rect.z);
	a += step(0.0, input.texUV.y - rect.y - rect.w) * smoothstep(0.0, EDGE, input.texUV.y - rect.y - rect.w);
	return float4(0.0, 0.0, 0.0, min(a, 0.6));
}
