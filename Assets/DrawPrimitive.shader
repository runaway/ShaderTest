// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/DrawPrimitive" 
{ 

	Properties
	{
		_CircleRadius("Circle Radius", Range(0, 0.1)) = 0.05
		_OutlineWidth("Outline Width", Range(0, 1.1)) = 0.1 // 0.01
		_OutlineColor("Outline Color", Color) = (0, 1, 0, 0) // (1, 1, 1, 1)
		_LineWidth("Line Width", Range(0, 1.0)) = 1.0 // Range(0, 0.1) 0.01
		_LineColor("Line Color", Color) = (0, 1, 0, 0) // (1, 1, 1, 1)
		_Antialias("Antialias Factor", Range(0, 0.05)) = 0.05 // 0.01
		_BackgroundColor("Background Color", Color) = (0, 0, 0, 1) // (1, 1, 1, 1)

		fixed4Mouse("Mouse Pos", Vector) = (100, 100, 0, 0) //(100, 100, 0, 0)

		//float4 m_af4Fold[10];
		//m_af4Fold("m_af4Fold", Vector[]) = (0, 0, 0, 0)
		//float m_afFold[30];
		m_iFoldNum("m_iFoldNum", Range(0, 9)) = 0

		//_MainTex("Base (RGB)", 2D) = "white" {}
		_MainTex("Main Tex", 2D) = "white" {} 
	}


	CGINCLUDE    
	 	#include "UnityCG.cginc"   
  		#pragma target 3.0   
  		#pragma glsl   

		#pragma multi_compile FANCY_STUFF_OFF FANCY_STUFF_ON
		//#pragma surface Surf Lambert vertex:Vert
		//#pragma surface Surf Lambert
		#pragma vertex Vert 


  		#define vec2 float2
  		#define vec3 float3
  		#define vec4 float4
  		#define mat2 float2x2
  		#define iGlobalTime _Time.y
  		#define mod fmod
  		#define mix lerp
  		#define atan atan2
  		#define fract frac 
  		#define texture2D tex2D
  		
		// 屏幕的尺寸
  		#define iResolution _ScreenParams
  		
		// 屏幕中的坐标，以pixel为单位
  		#define gl_FragCoord ((_iParam.scrPos.xy / _iParam.scrPos.w) * _ScreenParams.xy) 
  		
  		#define pi 3.14159265358979
		#define SQRT3_DIVIDE_6 0.289
		#define SQRT6_DIVIDE_12 0.204
		#define SQRT6_DIVIDE_3 0.816
		#define SQRT3_DIVIDE_2 0.866
		#define ONE_DIVIDE_2SQRT3 0.289
		#define ONE_DIVIDE_SQRT3 0.577

  		float _CircleRadius;
  		float _OutlineWidth;
  		float4 _OutlineColor;
  		float _LineWidth;
  		float4 _LineColor;
  		float _Antialias;
  		float4 _BackgroundColor;

		float m_fFoldWidth;
		float4 m_af4Fold[10];
		float3 m_f3FoldColor;
		float3 m_f3FoldOffset;
		int m_iFoldNum;
  		
  		fixed4 fixed4Mouse;
  		sampler2D iChannel0;
  		fixed4 iChannelResolution0;

		sampler2D _MainTex;
		float4 _MainTex_ST;
		fixed4 _Color;
		float _Magnitude;
		float _Frequency;
		float _InvWaveLength;
		float _Speed;



#ifndef SHIFT_UV  	
		struct a2v 
		{
			float4 vertex : POSITION;
			float4 texcoord : TEXCOORD0;
		};


		struct v2f
		{
			float4 pos : SV_POSITION;
			float4 scrPos : TEXCOORD1;
			float2 uv : TEXCOORD0;
		};

		//struct Input
		//{
		//	float2 uv_MainTex;
		//	float4 vertCol;
		//};

		vec4 main(vec2 fragCoord, v2f _iParam);
		//v2f Vert(inout appdata_full v, out Input IN);
   
		//v2f vert(appdata_base v)
		//void Vert(inout appdata_full v, out Input IN)
		v2f Vert(appdata_full v) 
		{
			v2f o;

        	o.pos = UnityObjectToClipPos (v.vertex);

			//o.scrPos = ComputeScreenPos(o.pos);  
			//o.scrPos = ComputeScreenPos(o.pos + 1.1);// +_Time.y;
			o.scrPos.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
			//o.scrPos.xy += 0.5; 
			_Speed = 0.3;
			//o.scrPos.xy += float2(0.0, sin(_Time.y * _Speed));
			//o.scrPos.w = sin(_Time.y * _Speed);
			o.scrPos.z = sin(_Time.y * _Speed);

			//UNITY_INITIALIZE_OUTPUT(Input, IN);
			//v.vertex.y = sin(_Time.y + v.vertex.x); // _Time.y + 
			//o.pos.y = abs(sin(_Time.y + v.vertex.x));
			//o.pos.y = -5 + 2 * v.vertex.x + 3 * v.vertex.x * v.vertex.x;
			
			//float absh = abs(v.vertex.y);
			//IN.vertCol = float4(absh, absh, absh, 1.0); 
			

            return o;    
        }  


		fixed4 frag(v2f _iParam) : COLOR0 // , appdata_base v
		{
			vec2 fragCoord = gl_FragCoord;

			return main(gl_FragCoord, _iParam);

			//v2f o;
			//o.pos = UnityObjectToClipPos(v.vertex);
			//o.scrPos.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
			//fixed4 c = tex2D(_MainTex, o.scrPos.xy);
			//return c;

		}
#else
		struct a2v {
			float4 vertex : POSITION;
			float4 texcoord : TEXCOORD0;
		};

		struct v2f {
			float4 pos : SV_POSITION;
			float2 uv : TEXCOORD0;
			//float4 scrPos : TEXCOORD0;
		};

		vec4 main(vec2 fragCoord, v2f _iParam);

		v2f vert(a2v v) 
		{
			v2f o;

			float4 offset;
			offset.yzw = float3(0.0, 0.0, 0.0);
			//offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
			//offset.x = 0.0;
			offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;

			o.pos = UnityObjectToClipPos(v.vertex + offset);


			o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
			//_Speed = 11.5;
			o.uv += float2(0.0, _Time.y * _Speed);

			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			fixed4 c = tex2D(_MainTex, i.uv);
			c.rgb *= _Color.rgb;

			return c;
		}
#endif

        

        
        float Line(vec2 vec2Pos, vec2 vec2Point0, vec2 vec2Point1, float fWidth)
		{   		
    		vec2 vec2Dir0 = vec2Point1 - vec2Point0;
			vec2 vec2Dir1 = vec2Pos - vec2Point0;

			float h = clamp(dot(vec2Dir0, vec2Dir1) / dot(vec2Dir0, vec2Dir0), 0.0, 1.0);
			
			return (length(vec2Dir1 - vec2Dir0 * h) - fWidth * 0.5);
        }

		float Line(vec2 vec2Point0, vec2 vec2Point1, float fWidth)
		{
			// 计算点到直线的距离    
			float d = 0;// = abs((vec2Point1.y - vec2Point0.y) * i.vertex.x + (vec2Point0.x - vec2Point1.x) * i.vertex.y + vec2Point1.x * vec2Point0.y - vec2Point1.y * vec2Point0.x) / sqrt(pow(vec2Point1.y - vec2Point0.y, 2) + pow(vec2Point0.x - vec2Point1.x, 2));

			// 小于或者等于线宽的一半时，属于直线范围    
			if (d <= fWidth / 2)
			{
				return fixed4(0.8, 0.2, 0.5, 1);
			}
		}
        
        float Circle(vec2 vec2Pos, vec2 vec2Center, float fRadius)
		{
        	float fD = length(vec2Pos - vec2Center) - fRadius;

        	return fD;
        }

		float Arc(vec2 vec2Pos, vec2 vec2Center, float fInsideRadius, float fOutSideRadius)
		{

			float fD = length(vec2Pos - vec2Center) + fInsideRadius - fOutSideRadius;

			if (fD < fInsideRadius && fD > fOutSideRadius)
			{
				fD = 0.1;
			}
			else fD = 0.7;

			return fD;
		}
        
		//#ifdef SUB_SHADER  
		//sampler2D _MainTex;

		//struct Input
		//{
		//	float2 uv_MainTex;
		//	float4 vertCol;
		//};



		//void Vert(inout appdata_full v, out Input IN)
		//{
		//	UNITY_INITIALIZE_OUTPUT(Input, IN);
		//	v.vertex.y = sin(_Time.y + v.vertex.x);
		//	float absh = abs(v.vertex.y);
		//	IN.vertCol = float4(absh, absh, absh, 1.0);
		//}

		//void Surf(Input IN, inout SurfaceOutput o) 
		//{
		//	half4 c = tex2D(_MainTex, IN.uv_MainTex);
		//	o.Albedo = IN.vertCol.rgb * c.rgb;
		//	o.Alpha = c.a;
		//}
		//#endif


		vec4 main(vec2 fragCoord, v2f _iParam)
		{
			vec2 vec2OriginalPos = (2.0 * fragCoord - iResolution.xy) / iResolution.yy;
			//vec2 vec2OriginalPos; vec2OriginalPos.x = fixed4Mouse.x; vec2OriginalPos.y = fixed4Mouse.y;
			//vec2OriginalPos.xy += 0.5;

			vec2 vec2Pos = vec2OriginalPos;
			//vec2Pos.x = fixed4Mouse.x; vec2Pos.y = fixed4Mouse.y;
			//vec2Pos.y -= 0.5;

			m_f3FoldColor = float3(0, 1, 0); 
			m_fFoldWidth = 0.15;
			//m_af4Fold[0].x = 0; m_af4Fold[0].y = 0; m_af4Fold[1].x = 0.3; m_af4Fold[1].y = 0; m_af4Fold[2].x = 0.3; m_af4Fold[2].y = 0.3; m_af4Fold[3].x = 0.6; m_af4Fold[3].y = 0.3; m_af4Fold[4].x = 0.6; m_af4Fold[4].y = 0.6; m_af4Fold[5].x = 0.9; m_af4Fold[5].y = 0.6;
			m_f3FoldOffset.x = -1; m_f3FoldOffset.y = -0.6;
			vec2 vec2UV;

			// Twist
			// vec2Pos.x += 0.5 * sin(5.0 * vec2Pos.y);

			vec2 vec2Split = vec2(0, 0);

			if (fixed4Mouse.z > 0.0)
			{
				//_ScreenParams
				vec2Split = (-iResolution.xy + 2.0 * fixed4Mouse.xy) / iResolution.yy;
				vec2Pos = vec2OriginalPos - vec2Split;
			}



			// Background
			//vec3 vec3Color = _BackgroundColor.rgb * (1.0 - 0.2 * length(vec2OriginalPos));
			vec3 vec3Color = vec3(0, 0, 0);

			// Apply X Y Z rotations
    		// Find more info from http://en.wikipedia.org/wiki/Rotation_matrix
			float fXSpeed = 3.8; // 0.3;
			float fYSpeed = 0.0; // 0.5;
			float fZSpeed = 0.0; // 0.7;
		    
			float3x3 mat = float3x3(1., 0., 0.,
		                      0., cos(fXSpeed * iGlobalTime), sin(fXSpeed * iGlobalTime),
		                      0., -sin(fXSpeed * iGlobalTime), cos(fXSpeed * iGlobalTime));
		    
			mat = mul(float3x3(cos(fYSpeed * iGlobalTime), 0., -sin(fYSpeed * iGlobalTime),
		                      0., 1., 0.,
		                      sin(fYSpeed * iGlobalTime), 0., cos(fYSpeed * iGlobalTime)), mat);
		    
			mat = mul(float3x3(cos(fZSpeed * iGlobalTime), sin(fZSpeed * iGlobalTime), 0.,
		                 	  -sin(fZSpeed * iGlobalTime), cos(fZSpeed * iGlobalTime), 0.,
		                 	  0., 0., 0.), mat);
			
		    float fLength = 0.5; // 1.5
		    vec3 p0 = vec3(0.0, -0.5, ONE_DIVIDE_2SQRT3) * fLength; // (0.0, 0.0, SQRT6_DIVIDE_12 * 3.0)
		    vec3 p1 = vec3(0.0, 0.0, -ONE_DIVIDE_SQRT3) * fLength; // (-0.5, -SQRT3_DIVIDE_6, -SQRT6_DIVIDE_12)
		    vec3 p2 = vec3(SQRT6_DIVIDE_3, 0.0, 0.0) * fLength; // (0.5, -SQRT3_DIVIDE_6, -SQRT6_DIVIDE_12)
		    vec3 p3 = vec3(0.0, 0.5, ONE_DIVIDE_2SQRT3) * fLength; // (0.0, SQRT3_DIVIDE_6 * 2.0, -SQRT6_DIVIDE_12)
		    
		    p0 = mul(mat, p0);
		    p1 = mul(mat, p1);
		    p2 = mul(mat, p2);
		    p3 = mul(mat, p3);;
		    
		    vec2 vec2ArrowPoint0 = p0.xy;
		    vec2 vec2ArrowPoint1 = p1.xy;
		    vec2 vec2ArrowPoint2 = p2.xy;
		    vec2 vec2ArrowPoint3 = p3.xy;

			vec3 vec3Point0 = vec3(0.0, -0.5, 0.0); // (0.0, -0.5, 0.0)
			vec3 vec3Point1 = vec3(5.0, -0.5, 0.0); // (5.0, -0.5, 0.0)
			
			_LineWidth = 0.08;
			float fD = Line(vec2Pos, vec2ArrowPoint0, vec2ArrowPoint1, _LineWidth);
			fD = min(fD, Line(vec2Pos, vec2ArrowPoint1, vec2ArrowPoint2, _LineWidth));
			fD = min(fD, Line(vec2Pos, vec2ArrowPoint2, vec2ArrowPoint3, _LineWidth));
			fD = min(fD, Line(vec2Pos, vec2ArrowPoint0, vec2ArrowPoint2, _LineWidth));
			fD = min(fD, Line(vec2Pos, vec2ArrowPoint0, vec2ArrowPoint3, _LineWidth));
			fD = min(fD, Line(vec2Pos, vec2ArrowPoint1, vec2ArrowPoint3, _LineWidth));
			fD = min(fD, Circle(vec2Pos, vec2ArrowPoint0, _CircleRadius));
			fD = min(fD, Circle(vec2Pos, vec2ArrowPoint1, _CircleRadius));
			fD = min(fD, Circle(vec2Pos, vec2ArrowPoint2, _CircleRadius));
			fD = min(fD, Circle(vec2Pos, vec2ArrowPoint3, _CircleRadius));
			fD = min(fD, Arc(vec2Pos, vec2ArrowPoint3 + 0.5, 0.3, 1.2));
			
			if (0 < m_iFoldNum && 10 > m_iFoldNum)
			{
				for (int i = 0; i < m_iFoldNum; i++)
				{
					vec3Point0.x = m_f3FoldOffset.x + m_af4Fold[i].x;
					vec3Point0.y = m_f3FoldOffset.y + m_af4Fold[i].y;
					vec3Point0.z = 0;
					vec3Point1.x = m_f3FoldOffset.x + m_af4Fold[i + 1].x;
					vec3Point1.y = m_f3FoldOffset.y + m_af4Fold[i + 1].y;
					vec3Point1.z = 0;

					fD = min(fD, Line(vec2Pos, vec3Point0, vec3Point1, m_fFoldWidth));
				}
			}

			vec2UV = vec2OriginalPos; // IN.uv_MainTex;
			vec2UV += float2(_Time.x, _Time.y);
			fixed4 c = tex2D(_MainTex, vec2UV);
			//c.rgb *= _OutlineColor.rgb;

			//_LineColor = vec4(0, 1, 0, 0);
			//_LineColor += sin(_Time.y);
			_LineColor = c;
			_OutlineColor = vec4(0, 0, 1, 0);
			
			if (vec2OriginalPos.x < vec2Split.x)
			{
				vec3Color = mix(_OutlineColor.rgb, vec3Color, step(0, fD - _OutlineWidth));
				vec3Color = mix(_LineColor.rgb, vec3Color, step(0, fD));

			} 
			else if (vec2OriginalPos.y > vec2Split.y)
			{
				float w = _Antialias;

				//  smoothstep 返回一个在输入值之间平稳变化的插值
				vec3Color = mix(_OutlineColor.rgb, vec3Color, smoothstep(-w, w, fD - _OutlineWidth));
				vec3Color = mix(_LineColor.rgb, vec3Color, smoothstep(-w, w, fD));

			} 
			else 
			{
				// ddx 返回关于屏幕坐标x轴的偏导数, fwidth 返回abs(ddx(x) + abs(ddy(x))
				float w = fwidth(0.5 * fD) * 2.0;
				vec3Color = mix(_OutlineColor.rgb, vec3Color, smoothstep(-w, w, fD - _OutlineWidth));
				vec3Color = mix(_LineColor.rgb, vec3Color, smoothstep(-w, w, fD));

			}


			
			// Draw split lines
			// lerp 对输入值进行插值计算 Returns x + s(y - x)
			//vec3Color = mix(vec3(0, 1, 0), vec3Color, smoothstep(0.005, 0.007, abs(vec2OriginalPos.x - vec2Split.x))); // 0.005, 0.007
			//vec3Color = mix(vec3Color, vec3(0, 1, 0), (1 - smoothstep(0.005, 0.007, abs(vec2OriginalPos.y - vec2Split.y))) * step(vec2Split.x, vec2OriginalPos.x));
			
			//vec3Color = mix(m_f3FoldColor, vec3Color, smoothstep(0.001, m_fFoldWidth, abs(vec2OriginalPos.x - vec2Split.x))); // 0.005, 0.007
			//vec3Color = mix(m_f3FoldColor, vec3(0, 1, 0), (1 - smoothstep(0.005, 0.007, abs(vec2OriginalPos.y - vec2Split.y))) * step(vec2Split.x, vec2OriginalPos.x));
			//Input IN;
			//UNITY_INITIALIZE_OUTPUT(Input, IN);
			//_iParam.uv = vec2OriginalPos; // IN.uv_MainTex;
			//_iParam.uv += float2(_Time.x, _Time.y);
			//fixed4 c = tex2D(_MainTex, _iParam.uv);
			//c.rgb *= _Color.rgb;
			//return c;

			return vec4(vec3Color, 1.0); 
		}

		ENDCG



//		SubShader
//		{
//			// Need to disable batching because of the vertex animation
//			Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" "DisableBatching" = "True" }
//
//			Pass
//			{
//			Tags{ "LightMode" = "ForwardBase" }
//
//			ZWrite Off
//			Blend SrcAlpha OneMinusSrcAlpha
//			Cull Off
//
//			CGPROGRAM
//#pragma vertex vert 
//#pragma fragment Frag
//
//
//			struct a2v
//			{
//				float4 vertex : POSITION;
//				float4 texcoord : TEXCOORD0;
//			};
//
//			struct v2f1
//			{
//				float4 pos : SV_POSITION;
//				float2 uv : TEXCOORD0;
//			};
//
//			v2f1 vert(a2v v)
//			{
//				v2f1 o;
//
//				float4 offset;
//				offset.yzw = float3(0.0, 0.0, 0.0);
//				//offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
//				//offset.x = 0.0;
//				offset.x = sin(_Frequency * _Time.y + v.vertex.x * _InvWaveLength + v.vertex.y * _InvWaveLength + v.vertex.z * _InvWaveLength) * _Magnitude;
//
//				o.pos = UnityObjectToClipPos(v.vertex + offset);
//
//				o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
//				//_Speed = 11.5;
//				o.uv += float2(0.0, _Time.y * _Speed);
//
//				return o;
//			}
//
//			fixed4 Frag(v2f1 i) : SV_Target
//			{
//				fixed4 c = tex2D(_MainTex, i.uv);
//			c.rgb *= _Color.rgb;
//
//			return c;
//		}
//
//			ENDCG
//		}
//		}




		SubShader
		{


			//Tags{ "RenderType" = "Opaque" }
			//LOD 200
			//Cull Off

			//CGPROGRAM
			//#pragma surface surf Lambert vertex:MyVert // Unlit Lambert Standard fullforwardshadows
			////sampler2D _MainTex;

			//struct Input 
			//{
			//	float2 uv_MainTex;
			//	float4 vertCol;
			//};

			//void MyVert(inout appdata_full v, out Input IN)
			//{
			//	UNITY_INITIALIZE_OUTPUT(Input, IN);
			//	v.vertex.y = sin(_Time.y + v.vertex.x) / 3;
			//	float absh = abs(v.vertex.y);
			//	IN.vertCol = float4(absh, absh, absh, 1.0);
			//}

			//void surf(Input IN, inout SurfaceOutput o)
			//{
			//	half4 c = tex2D(_MainTex, IN.uv_MainTex);
			//	o.Albedo = IN.vertCol.rgb * c.rgb;
			//	o.Alpha = c.a;
			//}
			//ENDCG

			Pass
			{
			CGPROGRAM

			#pragma vertex vert    
			#pragma fragment frag    
			#pragma fragmentoption ARB_precision_hint_fastest   


			ENDCG
			}
		}

//#ifdef SUB_SHADER  

	//	SubShader
	//	{
	//		Tags{ "RenderType" = "Opaque" }
	//		LOD 200
	//		Cull Off



	////#pragma multi_compile FANCY_STUFF_OFF FANCY_STUFF_ON

	//		CGPROGRAM
	//#pragma surface surf Lambert vertex:MyVert

	//		sampler2D _MainTex;

	//	struct Input
	//	{
	//		float2 uv_MainTex;
	//		float4 vertCol;
	//	};

	//	void MyVert(inout appdata_full v, out Input IN)
	//	{
	//		UNITY_INITIALIZE_OUTPUT(Input, IN);
	//		v.vertex.y = sin(_Time.y + v.vertex.x);
	//		float absh = abs(v.vertex.y);
	//		IN.vertCol = float4(absh, absh, absh, 1.0);
	//	}

	//	void surf(Input IN, inout SurfaceOutput o) {
	//		half4 c = tex2D(_MainTex, IN.uv_MainTex);
	//		o.Albedo = IN.vertCol.rgb * c.rgb;
	//		o.Alpha = c.a;
	//	}
	//	ENDCG
	//	}
//#endif 




		 

    FallBack Off    
	//FallBack "Diffuse"
}
