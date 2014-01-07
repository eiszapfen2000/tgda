//-----------------------------------------------------------------------------
// Parallax Occlusion Mapping.fx
//
// This effect file implements the baseline parallax occlusion mapping 
// as described in the chapter "A Closer Look At Parallax Occlusion Mapping"
// by Jason Zink.
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Parameters
//-----------------------------------------------------------------------------
float4x4 mWVP				: WorldViewProjection;
float4x4 mW					: World;
float4  EyePosition			: ViewPosition;
float4  LightPosition		: ViewParm0;

Texture2D ColorMap			: ColorMap0; 
Texture2D NormalHeightMap	: ColorMap1; 

float	fHeightMapScale		= 0.1;
int		nMaxSamples			= 20;
int		nMinSamples			= 4;
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
SamplerState LinearSampler
{
	Filter			= MIN_MAG_MIP_LINEAR;
	AddressU		= Wrap;
	AddressV		= Wrap;
	AddressW		= Wrap;
};

//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
struct vertex
{
   	float3 position	: POSITION;
   	float2 texcoord	: TEXCOORD0;
   	float3 normal	: NORMAL;
   	float3 tangent	: TANGENT;
   	float3 binormal	: BINORMAL;
};
//-----------------------------------------------------------------------------
struct fragment
{
	float4 position	: SV_Position;
	float2 texcoord	: TEXCOORD0;
	float3 eye		: TEXCOORD1;
	float3 normal   : TEXCOORD2;
	float3 light    : TEXCOORD3;
};
//-----------------------------------------------------------------------------
struct pixel
{
	float4 color	: SV_Target0;
};
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// Vertex Shader
//-----------------------------------------------------------------------------
fragment VS( vertex IN )
{
    fragment OUT;

	// Calculate the world space position of the vertex and view points.
	float3 P = mul( float4( IN.position, 1 ), mW ).xyz;
	float3 N = IN.normal;
	float3 E = P - EyePosition.xyz;
	float3 L = LightPosition.xyz - P;

	// The per-vertex tangent, binormal, normal form the tangent to object 
	// space rotation matrix.  Multiply by the world matrix to form tangent
	// to world space rotation matrix.  Then transpose the matrix to form
	// the inverse tangent to world space, otherwise called the world to
	// tangent space rotation matrix.
	float3x3 tangentToWorldSpace;		

	tangentToWorldSpace[0] = mul( normalize( IN.tangent ), mW );					
	tangentToWorldSpace[1] = mul( normalize( IN.binormal ), mW );				
	tangentToWorldSpace[2] = mul( normalize( IN.normal ), mW );					
	
	float3x3 worldToTangentSpace = transpose(tangentToWorldSpace);

	// Output the projected vertex position for rasterization and
	// pass through the texture coordinates.
	OUT.position = mul( float4(IN.position, 1), mWVP );
	OUT.texcoord = IN.texcoord;

	// Output the tangent space normal, eye, and light vectors.
	OUT.eye		= mul( E, worldToTangentSpace );
	OUT.normal	= mul( N, worldToTangentSpace );
	OUT.light	= mul( L, worldToTangentSpace );

	return OUT;
}
//-----------------------------------------------------------------------------
// Pixel Shader
//-----------------------------------------------------------------------------
pixel PS( fragment IN )
{
	pixel OUT;

	// Calculate the parallax offset vector max length.
	// This is equivalent to the tangent of the angle between the
	// viewer position and the fragment location.
	float fParallaxLimit = -length( IN.eye.xy ) / IN.eye.z;

	// Scale the parallax limit according to heightmap scale.
	fParallaxLimit *= fHeightMapScale;						

	// Calculate the parallax offset vector direction and maximum offset.
	float2 vOffsetDir = normalize( IN.eye.xy );
	float2 vMaxOffset = vOffsetDir * fParallaxLimit;
	
	// Calculate the geometric surface normal vector, the vector from
	// the viewer to the fragment, and the vector from the fragment
	// to the light.
	float3 N = normalize( IN.normal );
	float3 E = normalize( IN.eye );
	float3 L = normalize( IN.light );

	// Calculate how many samples should be taken along the view ray
	// to find the surface intersection.  This is based on the angle
	// between the surface normal and the view vector.
	int nNumSamples = (int)lerp( nMaxSamples, nMinSamples, dot( E, N ) );
	
	// Specify the view ray step size.  Each sample will shift the current
	// view ray by this amount.
	float fStepSize = 1.0 / (float)nNumSamples;

	// Calculate the texture coordinate partial derivatives in screen
	// space for the tex2Dgrad texture sampling instruction.
	float2 dx = ddx( IN.texcoord );
	float2 dy = ddy( IN.texcoord );

	// Initialize the starting view ray height and the texture offsets.
	float fCurrRayHeight = 1.0;	
	float2 vCurrOffset = float2( 0, 0 );
	float2 vLastOffset = float2( 0, 0 );
	
	float fLastSampledHeight = 1;
	float fCurrSampledHeight = 1;

	int nCurrSample = 0;

	while ( nCurrSample < nNumSamples )
	{
		// Sample the heightmap at the current texcoord offset.  The heightmap 
		// is stored in the alpha channel of the height/normal map.
		//fCurrSampledHeight = tex2Dgrad( NH_Sampler, IN.texcoord + vCurrOffset, dx, dy ).a;
		fCurrSampledHeight = NormalHeightMap.SampleGrad( LinearSampler, IN.texcoord + vCurrOffset, dx, dy ).a;

		// Test if the view ray has intersected the surface.
		if ( fCurrSampledHeight > fCurrRayHeight )
		{
			// Find the relative height delta before and after the intersection.
			// This provides a measure of how close the intersection is to 
			// the final sample location.
			float delta1 = fCurrSampledHeight - fCurrRayHeight;
			float delta2 = ( fCurrRayHeight + fStepSize ) - fLastSampledHeight;
			float ratio = delta1/(delta1+delta2);

			// Interpolate between the final two segments to 
			// find the true intersection point offset.
			vCurrOffset = (ratio) * vLastOffset + (1.0-ratio) * vCurrOffset;
			
			// Force the exit of the while loop
			nCurrSample = nNumSamples + 1;	
		}
		else
		{
			// The intersection was not found.  Now set up the loop for the next
			// iteration by incrementing the sample count,
			nCurrSample++;

			// take the next view ray height step,
			fCurrRayHeight -= fStepSize;
			
			// save the current texture coordinate offset and increment
			// to the next sample location, 
			vLastOffset = vCurrOffset;
			vCurrOffset += fStepSize * vMaxOffset;

			// and finally save the current heightmap height.
			fLastSampledHeight = fCurrSampledHeight;
		}
	}

	// Calculate the final texture coordinate at the intersection point.
	float2 vFinalCoords = IN.texcoord + vCurrOffset;
	
	// Use the final texture coordinates to get the normal vector, then 
	// expand it from [0,1] to [-1,1] range.
	float4 vFinalNormal = NormalHeightMap.Sample( LinearSampler, vFinalCoords ); //.a;
		
	// Sample the colormap at the final intersection point.
	float4 vFinalColor = ColorMap.Sample( LinearSampler, vFinalCoords );

	// Expand the final normal vector from [0,1] to [-1,1] range.
	vFinalNormal = vFinalNormal * 2.0f - 1.0f;

	// Shade the fragment based on light direction and normal.
	float3 vAmbient = vFinalColor.rgb * 0.1f;
	float3 vDiffuse = vFinalColor.rgb * max( 0.0f, dot( L, vFinalNormal.xyz ) ) * 0.5f;
	vFinalColor.rgb = vAmbient + vDiffuse;
	
	OUT.color = vFinalColor;

// Define the 'GRIDLINES' preprocessor directive to draw the gridlines
// on the texture surface.  This helps visualization of the simulated surface

//#define GRIDLINES
#ifdef GRIDLINES
	float2 vGridCoords = frac( vFinalCoords * 10.0f );

	if ( ( vGridCoords.x < 0.025f ) || ( vGridCoords.x > 0.975f ) )
		OUT.color = float4( 1.0f, 1.0f, 1.0f, 1.0f );

	if ( ( vGridCoords.y < 0.025f ) || ( vGridCoords.y > 0.975f ) )
		OUT.color = float4( 1.0f, 1.0f, 1.0f, 1.0f );
#endif

	return OUT;
}

//-----------------------------------------------------------------------------
// Techniques
//-----------------------------------------------------------------------------
technique10 Parallax_Occlusion_Mapping
{
    pass Pass0
    {
        SetVertexShader( CompileShader( vs_4_0, VS() ) );
        SetGeometryShader( NULL );
        SetPixelShader( CompileShader( ps_4_0, PS() ) );
    }
}
//-----------------------------------------------------------------------------