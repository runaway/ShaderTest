// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/stalendp/myDiamondShader" {  
    Properties {  
        _Color ("Color", Color) = (1,1,1,1)  
        _ReflectTex ("Reflection Texture", Cube) = "" { }  
        _RefractTex ("Refraction Texture", Cube) = "" { }  
    }     
    CGINCLUDE    
        #include "UnityCG.cginc"               
          
        fixed4 _Color;    
        samplerCUBE _RefractTex;      
        samplerCUBE _ReflectTex;         
          
        struct v2f {        
            half4 pos:SV_POSITION;        
            half3 Reflect : TEXCOORD0;       
            half3 RefractR : TEXCOORD1;  
            half3 RefractG : TEXCOORD2;  
            half3 RefractB : TEXCOORD3;  
            half Ratio : TEXCOORD4;  
        };      
      
        v2f vert(appdata_full v) {      
              
            float EtaR = 0.65;  
            float EtaG = 0.67;  
            float EtaB = 0.69;  
            float FresnelPower = 5.0;  
            float F = ((1.0-EtaG) * (1.0-EtaG)) / ((1.0+EtaG) * (1.0+EtaG));  
              
            float3 i = -normalize(ObjSpaceViewDir(v.vertex));   
            float3 n = normalize(v.normal); // ??????  
              
            v2f o;  
            o.Ratio = F + (1.0 - F) * pow((1.0 - dot(-i, n)), FresnelPower) ;  
            o.RefractR = refract(i, n, EtaR);  
            o.RefractG = refract(i, n, EtaG);  
            o.RefractB = refract(i, n, EtaB);  
            o.Reflect = reflect(i, n);  
            o.pos = UnityObjectToClipPos (v.vertex);     
                  
            return o;      
        }      
      
        fixed4 frag(v2f i) : COLOR0 {    
            float3 refractColor, reflectColor;  
              
            refractColor.r = float3(texCUBE(_RefractTex, i.RefractR)).r;  
            refractColor.g = float3(texCUBE(_RefractTex, i.RefractG)).g;  
            refractColor.b = float3(texCUBE(_RefractTex, i.RefractB)).b;  
            reflectColor = float3(texCUBE(_ReflectTex, i.Reflect));  
              
            return  2*_Color * pow(fixed4(lerp( _Color * refractColor * 5, reflectColor * 2, i.Ratio), 1), 1.8);  
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