// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/UseAlphaBlending"
{
	Properties
	{
		_FrontColor("外表面的颜色",Color) =(1,0,0,0)
		_BackColor("内表面的颜色",Color) = (1,0,0,0)
	}
		//第一个Pass块渲染该材质网格的背面（里面），它首先被渲染，之后再渲染材质网格的外面。
		SubShader{

		//在所有的不透明网格渲染之后渲染
		Tags{ "Queue" = "Transparent" }

		Pass{

		//第一个通道剔除外表面，只渲染内表面
		Cull Front
		//不要深度缓冲，为了不挡住其他物体
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha // use alpha blending
										////==float4 result=fragment_output.aaaa*fragment_output +(float4(1.0, 1.0, 1.0, 1.0) - fragment_output.aaaa)*pixel_color

		CGPROGRAM

#pragma vertex vert 
#pragma fragment frag

		 float4 _BackColor;
		float4 vert(float4 vertexPos : POSITION) : SV_POSITION
	{
		return UnityObjectToClipPos(vertexPos);
	}

		float4 frag(void) : COLOR
	{
		return _BackColor;
	}

		ENDCG
	}

		Pass{
		//第二个通道剔除内表面，只渲染外表面
		Cull Back 
		ZWrite Off 
		Blend SrcAlpha OneMinusSrcAlpha // use alpha blending
										////==float4 result=fragment_output.aaaa*fragment_output +(float4(1.0, 1.0, 1.0, 1.0) - fragment_output.aaaa)*pixel_color

		CGPROGRAM
		float4 _FrontColor;
#pragma vertex vert 
#pragma fragment frag

		float4 vert(float4 vertexPos : POSITION) : SV_POSITION
	{
		return UnityObjectToClipPos(vertexPos);
	}

		float4 frag(void) : COLOR
	{
		return _FrontColor;
	}

		ENDCG
	}
	}
}
