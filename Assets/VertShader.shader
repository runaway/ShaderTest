Shader "Custom/VertShader" {
    Properties {
        _MainTex ("Base (RGB)", 2D) = "white" {}
    }
    SubShader {
        Tags { "RenderType"="Opaque" }
        LOD 200
        Cull Off

        CGPROGRAM
        #pragma surface surf Lambert vertex:MyVert

        sampler2D _MainTex;

        struct Input {
            float2 uv_MainTex;
            float4 vertCol;
        };

        void MyVert(inout appdata_full v, out Input IN)
        {
            UNITY_INITIALIZE_OUTPUT(Input, IN);
            v.vertex.y = sin(_Time.y + v.vertex.x);
            float absh = abs(v.vertex.y);
            IN.vertCol = float4(absh, absh, absh, 1.0);
        }

        void surf (Input IN, inout SurfaceOutput o) {
            half4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = IN.vertCol.rgb * c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    } 
    FallBack "Diffuse"
}