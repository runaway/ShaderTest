// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "Custom/shadertoy/Waves" {  
 
	CGINCLUDE  
 
		#include "UnityCG.cginc"              
		#pragma target 3.0  

		struct vertOut 
		{  
			float4 pos:SV_POSITION;  
			float4 srcPos : TEXCOORD0;
		};
 
		vertOut vert(appdata_base v) {
			vertOut o;
			o.pos = UnityObjectToClipPos (v.vertex);
			o.srcPos = ComputeScreenPos(o.pos);
			return o;
		}
 
		fixed4 frag(vertOut i) : COLOR0 {
 
			fixed3 COLOR1 = fixed3(0.0,0.0,0.3);
			fixed3 COLOR2 = fixed3(0.5,0.0,0.0);
			float BLOCK_WIDTH = 0.03;
 
			float2 uv = (i.srcPos.xy/i.srcPos.w);
 
			// To create the BG pattern
			fixed3 final_color = fixed3(1.0, 0.0, 0.0);
			fixed3 bg_color = fixed3(0.0, 0.0, 0.0);
			fixed3 wave_color = fixed3(0.0, 0.0, 0.0);
 
			float c1 = fmod(uv.x, 2.0* BLOCK_WIDTH);
			c1 = step(BLOCK_WIDTH, c1);
			float c2 = fmod(uv.y, 2.0* BLOCK_WIDTH);
			c2 = step(BLOCK_WIDTH, c2);
			bg_color = lerp(uv.x * COLOR1, uv.y * COLOR2, c1*c2);
 
			// TO create the waves 
			float wave_width = 0.01;
			uv = -1.0 + 2.0*uv;
			uv.y += 0.1;
			for(float i=0.0; i<10.0; i++) {
				uv.y += (0.07 * sin(uv.x + i/7.0 +  _Time.y));
				wave_width = abs(1.0 / (150.0 * uv.y));
				wave_color += fixed3(wave_width * 1.9, wave_width, wave_width * 1.5);
			}
			final_color = bg_color + wave_color;
 
			return fixed4(final_color, 1.0);
		}
 
	ENDCG  
 
	SubShader {  
		Pass {  
			CGPROGRAM  
 
			#pragma vertex vert  
			#pragma fragment frag  
			#pragma fragmentoption ARB_precision_hint_fastest   
 
			ENDCG  
		}  
 
	}   
	FallBack Off  
}
