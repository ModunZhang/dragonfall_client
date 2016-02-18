Texture2D g_Texture0 : register(t0);

SamplerState TextureSampler : register(s0);
 
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
	float4 col = g_Texture0.Sample(TextureSampler, input.texUV);
	return float4(float3(0.0, 0.0, 0.0), (1.0 - smoothstep(0.5, 1.0, col.x / 1.0)) * 0.5);
}
