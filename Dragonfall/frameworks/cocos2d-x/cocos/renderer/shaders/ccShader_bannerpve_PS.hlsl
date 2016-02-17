Texture2D g_Texture0;

SamplerState TextureSampler
{
	Filter = MIN_MAG_MIP_LINEAR;
	AddressU = Wrap;
	AddressV = Wrap;
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
	float4 col = g_Texture0.Sample(TextureSampler, input.texUV);
	return float4(float3(0.0, 0.0, 0.0), smoothstep(0.2, 1.0, 1.0 - abs(col.x - 0.5) * 2.0) * 0.6);
}
