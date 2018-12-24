
//Algorithms and shaders based on code from this journal
//http://cgg-journal.com/2008-2/06/index.html

#ifndef UCLA_GAMELAB_WIREFRAME
#define UCLA_GAMELAB_WIREFRAME

#include "UnityCG.cginc"

// DATA STRUCTURES //
// Vertex to Geometry
struct UCLAGL_v2g
{
	float4	pos		: POSITION;		// vertex position
	float2  uv		: TEXCOORD0;	// vertex uv coordinate
};

// Geometry to  UCLAGL_fragment
struct UCLAGL_g2f
{
	float4	pos		: POSITION;		// fragment position
	float2	uv		: TEXCOORD0;	// fragment uv coordinate
	float3  dist	: TEXCOORD1;	// distance to each edge of the triangle
};

// PARAMETERS //

//float4 _Texture_ST;			// For the Main Tex UV transform
float _Thickness = 1;		// Thickness of the wireframe line rendering
float4 _Color = { 1,1,1,1 };	// Color of the line
float4 _MainTex_ST;			// For the Main Tex UV transform
sampler2D _MainTex;			// Texture used for the line

// SHADER PROGRAMS //
// Vertex Shader
UCLAGL_v2g UCLAGL_vert(appdata_base v)
{
	UCLAGL_v2g output;
	output.pos = mul(UNITY_MATRIX_MVP, v.vertex);
	output.uv = TRANSFORM_TEX(v.texcoord, _MainTex);//v.texcoord;

	return output;
}
// Geometry Shader
[maxvertexcount(3)]
void UCLAGL_geom(triangle UCLAGL_v2g p[3], inout TriangleStream<UCLAGL_g2f> triStream)
{
	UCLAGL_v2g np[3];
	bool find = false;
	for (int i = 0; i < 3 && !find; i++)
	{
		for (int j = i + 1; j < 3 && !find; j++)
		{
			if (abs(p[i].uv.x - p[j].uv.x)>0.01f && abs(p[i].uv.y - p[j].uv.y)>0.01f)
			{
				np[0] = p[3 - i - j];//设置np[0]为直角点
				np[1] = p[i];
				np[2] = p[j];
				find = true;
			}
		}
	}
	//points in screen space
	float2 p0 = _ScreenParams.xy * np[0].pos.xy / np[0].pos.w;
	float2 p1 = _ScreenParams.xy * np[1].pos.xy / np[1].pos.w;
	float2 p2 = _ScreenParams.xy * np[2].pos.xy / np[2].pos.w;

	//edge vectors
	float2 v0 = p2 - p1;
	float2 v1 = p2 - p0;
	float2 v2 = p1 - p0;

	//area of the triangle
	float area = abs(v1.x*v2.y - v1.y * v2.x);

	//values based on distance to the edges
	float dist0 = area / length(v0);
	float dist1 = area / length(v1);
	float dist2 = area / length(v2);


	UCLAGL_g2f pIn;

	//add the first point
	pIn.pos = np[0].pos;
	pIn.uv = np[0].uv;
	pIn.dist = float3(dist0, 0, 0);
	triStream.Append(pIn);

	//add the second point
	pIn.pos = np[1].pos;
	pIn.uv = np[1].uv;
	pIn.dist = float3(0, dist1, 0);
	triStream.Append(pIn);

	//add the third point
	pIn.pos = np[2].pos;
	pIn.uv = np[2].uv;
	pIn.dist = float3(0, 0, dist2);
	triStream.Append(pIn);
}

// Fragment Shader
float4 UCLAGL_frag(UCLAGL_g2f input) : COLOR
{
    //blend between the lines and the negative space to give illusion of anti aliasing
    float4 targetColor = _Color * tex2D(_MainTex, input.uv);
	float4 transCol = float4(0, 0, 0, 0);
    return (_Thickness > input.dist.y || _Thickness > input.dist.z) ? targetColor : transCol;
}


#endif