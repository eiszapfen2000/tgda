

//--------------------------------------------------------------------------------------
// Constants
//--------------------------------------------------------------------------------------


float4x4 WorldViewProjection : SXWorldViewProjection;


//--------------------------------------------------------------------------------------
// Textures and Samplers
//--------------------------------------------------------------------------------------


Texture Font;

sampler FontSampler = sampler_state
{
	texture = <Font>;
	magfilter = LINEAR;
	minfilter = LINEAR;
	mipfilter = NONE;
	AddressU = WRAP;
	AddressV = WRAP;
};


//--------------------------------------------------------------------------------------
// Input and Output structs
//--------------------------------------------------------------------------------------


struct VertexInput
{
	float3 position		: POSITION;
	float4 color		: COLOR;
	float2 texcoord		: TEXCOORD0;
};

struct VertexOutput
{
	float4 position			: POSITION;
	float4 color			: COLOR;
	float2 texcoord			: TEXCOORD0;
};

struct PixelOutput
{
	float4 color		: COLOR0;
};


//--------------------------------------------------------------------------------------
// Vertex Shaders
//--------------------------------------------------------------------------------------


VertexOutput vs_default(VertexInput IN)
{
	VertexOutput OUT;
	
	OUT.position = mul(float4(IN.position.xyz, 1.0), WorldViewProjection);
	OUT.texcoord = IN.texcoord;
	OUT.color = IN.color;
	
	return OUT;
}


//--------------------------------------------------------------------------------------
// Pixel Shaders
//--------------------------------------------------------------------------------------


PixelOutput ps_default(VertexOutput IN)
{
	PixelOutput OUT;
	
	float4 fontcolor = tex2D(FontSampler, IN.texcoord);
    OUT.color = fontcolor * IN.color;

    return OUT;
}


//--------------------------------------------------------------------------------------
// Techniques
//--------------------------------------------------------------------------------------


technique render
{
    pass p0
    {
        VertexShader = compile vs_3_0 vs_default();
        PixelShader = compile ps_3_0 ps_default();
    }
}

