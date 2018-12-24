// Upgrade NOTE: upgraded instancing buffer 'Props' to new syntax.

Shader "Instanced/BasicDiffuse" {


	Properties{
		_EmissiveColor("Emissive Color", Color) = (1,1,1,1)
		_AmbientColor("Ambient Color", Color) = (1,1,1,1)
		_MySliderValue("This is a Slider", Range(0,10)) = 2.5
		_RampTex("Ramp Texture", 2D) = "white"{}
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		// And generate the shadow pass with instancing support
		//#pragma surface surf Standard fullforwardshadows addshadow
		#pragma surface surf BasicDiffuse

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		// Enable instancing for this shader
		#pragma multi_compile_instancing

		// Config maxcount. See manual page.
		// #pragma instancing_options

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;

		float4 _EmissiveColor;
		float4 _AmbientColor;
		float _MySliderValue;
		sampler2D _RampTex;

		// Declare instanced properties inside a cbuffer.
		// Each instanced property is an array of by default 500(D3D)/128(GL) elements. Since D3D and GL imposes a certain limitation
		// of 64KB and 16KB respectively on the size of a cubffer, the default array size thus allows two matrix arrays in one cbuffer.
		// Use maxcount option on #pragma instancing_options directive to specify array size other than default (divided by 4 when used
		// for GL).
		UNITY_INSTANCING_BUFFER_START(Props)
			UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)	// Make _Color an instanced property (i.e. an array)
#define _Color_arr Props
		UNITY_INSTANCING_BUFFER_END(Props)

			void surf(Input IN, inout SurfaceOutput o) {
			float4 c;
			c = pow((_EmissiveColor + _AmbientColor), _MySliderValue);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}

		inline float4 LightingBasicDiffuse(SurfaceOutput s, fixed3 lightDir, fixed atten) {
			//float difLight = max(0, dot(s.Normal, lightDir));
			float difLight = dot(s.Normal, lightDir);
			//float hLambert = 0.5 * difLight + 0.5;
			float hLambert = 0.9 * difLight;
			float4 col;
			float3 ramp = tex2D(_RampTex, float2(hLambert, hLambert)).rgb;
			//col.rgb = s.Albedo * _LightColor0.rgb * (difLight * atten * 2);
			//col.rgb = s.Albedo * _LightColor0.rgb * (hLambert * atten * 2);
			col.rgb = s.Albedo * _LightColor0.rgb * ramp;
			col.a = s.Alpha;


			return col;
		}

		inline float4 LightingHalfLambert(SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten) {
			float difLight = dot(s.Normal, lightDir);
			float rimLight = dot(s.Normal, viewDir);
			float dif_hLambert = 0.5 * difLight + 0.5;
			float rim_hLambert = 0.5 * rimLight + 0.5;
			float3 ramp = tex2D(_RampTex, float2(dif_hLambert, rim_hLambert)).rgb;

			float4 col;
			col.rgb = s.Albedo * _LightColor0.rgb * ramp;
			col.a = s.Albedo;
			return col;
		}

		ENDCG
	}
	FallBack "Diffuse"
}
