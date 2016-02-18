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
	float4 texColor = g_Texture0.Sample(TextureSampler, input.texUV);
	float max_p = max(texColor.r, max(texColor.g, texColor.b));
	float min_p = min(texColor.r, min(texColor.g, texColor.b));
	float mid_p = texColor.r + texColor.g + texColor.b - max_p - min_p;
	float gray = float(max_p - mid_p) * 0.4 + float(mid_p - min_p) * 0.4 + min_p;
	return float4(float3(gray, gray, gray), texColor.a) * input.color;
}
