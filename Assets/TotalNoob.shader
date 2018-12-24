// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'


Shader "shadertoy/TotalNoob" {  //https://www.shadertoy.com/view/XdlSDs
	Properties{
		iMouse ("Mouse Pos", Vector) = (100,100,0,0)
		iChannel0("iChannel0", 2D) = "white" {}  
		iChannelResolution0 ("iChannelResolution0", Vector) = (100,100,0,0)
	}
	  
	CGINCLUDE    
	 	#include "UnityCG.cginc"   
  		#pragma target 3.0      
  		#pragma glsl
 
  		#define vec2 float2
  		#define vec3 float3
  		#define vec4 float4
  		#define mat2 float2x2
  		#define iGlobalTime _Time.y
//  		#define mod fmod  // mod = sign*fmod
  		#define mix lerp
  		#define atan atan2
  		#define fract frac 
  		#define texture2D tex2D
  		// 屏幕的尺寸
  		#define iResolution _ScreenParams
  		// 屏幕中的坐标，以pixel为单位
  		#define gl_FragCoord ((_iParam.srcPos.xy/_iParam.srcPos.w)*_ScreenParams.xy) 
  		
  		#define PI2 6.28318530718
  		#define pi 3.14159265358979
  		#define halfpi (pi * 0.5)
  		#define oneoverpi (1.0 / pi)
  		
  		fixed4 iMouse;
  		sampler2D iChannel0;
  		fixed4 iChannelResolution0;
  		
        struct v2f {    
            float4 pos : SV_POSITION;    
            float4 srcPos : TEXCOORD0;   
        };              
        
       //   precision highp float;
        v2f vert(appdata_base v){  
        	v2f o;
        	o.pos = UnityObjectToClipPos (v.vertex);
            o.srcPos = ComputeScreenPos(o.pos);  
            return o;    
        }  
        
        vec4 main(v2f _iParam);
        
        fixed4 frag(v2f _iParam) : COLOR0 {  
			return main(_iParam);
        }  
        
		vec4 main(v2f _iParam) 
		{

		   	vec2 p = (2.0 * gl_FragCoord.xy - iResolution.xy) / iResolution.y;
			//if (gl_FragCoord.y > 100 && gl_FragCoord.x > 100) discard;
						
		    //float tau = 3.1415926535*2.0;
			float tau = 3;
			
		    float a = atan(p.x,p.y);
			//float a = 310;
			
		    //float r = length(p)*0.75;
			float r = length(p)*0.55;
			
		    vec2 uv = vec2(a/tau,r);
			
			//get the color
			float xCol = (uv.x - (iGlobalTime / 3.0)) * 3.0;
			xCol = sign(xCol) * fmod(xCol, 3.0);
			vec3 horColour = vec3(0.25, 0.25, 0.25);
			
			if (xCol < 1.0) {
				horColour.r += 1.0 - xCol;
				horColour.g += xCol;
			} 
			else if (xCol < 2.0) // 2.0 
			{
				xCol -= 1.0;
				horColour.g += 1.0 - xCol;
				horColour.b += xCol;
			} 
			else 
			{
				xCol -= 2.0; // 2.0;
				horColour.b += 1.0 - xCol;
				horColour.r += xCol;
			}
			
			horColour = vec3(0.25, 0.95, 0.25);
 
			// draw color beam
			uv = (7.0 * uv) - 3.0; // (2.0 * uv) - 1.0;
			//float beamWidth = (0.7+0.5*cos(uv.x*10.0*tau*0.15*clamp(floor(5.0 + 10.0*cos(iGlobalTime)), 0.0, 10.0))) * abs(1.0 / (30.0 * uv.y));
			//float beamWidth = 1.05; 

			float beamWidth = (1, 1.0, 0.5) * abs(1.0 / (150.0 * uv.y));
			
			vec3 horBeam = vec3(beamWidth,beamWidth,beamWidth);
			
			vec4 gl_FragColor = vec4((( horBeam)* horColour ), 1.0);
			//vec4 gl_FragColor = vec4(horBeam, 1.0);
			
			return gl_FragColor;
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
代码分