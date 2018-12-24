

Shader "Unlit/WaveformTestFrag"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color)=(1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float y:FLOAT;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                float phase=_Time.y;
                float y;
                float x=v.uv.x;
                //perfect sin
    //          y=sin(fmod(v.uv.x,1.0f)*2.0f*3.1415926f+phase);
                //hill
    //          y=abs(sin(fmod(v.uv.x,1.0f)*3.1415926f+phase));
                //inverse hill
    //          y=1.0f-abs(sin(fmod(v.uv.x,1.0f)*3.1415926f+phase));
                //SawTooth
    //          y=saturate(fmod(v.uv.x+phase,1.0f));
                //Inverse SawTooth
    //          y=1-saturate(fmod(v.uv.x+phase,1.0f));
                //Exponential SawTooth
    //          y=saturate(pow(frac(v.uv.x+phase),10.0f));
                //Inverse Exponential SawTooth
    //          y=1-saturate(pow(fmod(v.uv.x+phase,1.0f),10.0f));
                //Chang
    //          y=saturate(saturate(pow(fmod(x+phase,1.0f),10.0f))*100.0f);
                //Triangle
    //          y=abs(fmod(x+phase,1.0f)*2.0f-1.0f);
                //Tapezoid
    //          y=saturate(abs(fmod(x+phase,1.0f)*2.0f-1.0f)*2.0f);
                //Discontinuous Triangles/Inverse Trapezoid
    //          y=1-saturate(abs(fmod(x+phase,1.0f)*2.0f-1.0f)*2.0f);
                //Square
                y=round(sin(x+phase));

    //          v.vertex.y=y;
                o.y=y;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {


                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return _Color*i.y;
            }
            ENDCG
        }
    }
}