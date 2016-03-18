Texture2D g_Texture0 : register(t0);

SamplerState TextureSampler : register(s0);

// A constant buffer that stores the three basic column-major matrices for composing geometry.
cbuffer ConstantBuffer : register(b0)
{
	float unit_count;
	float unit_len;
	float percent;
	float elapse;
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
	if (elapse > 1.0 - input.texUV.y){
		discard;
	}
	// float p = smoothstep(elapse - 0.1, elapse, 1.0 - v_texCoord.y);
	float y = fmod(input.texUV.y, unit_len) * unit_count;
	float ry = fmod(y + percent, 1.0);
	return g_Texture0.Sample(TextureSampler, float2(input.texUV.x, ry));
}
