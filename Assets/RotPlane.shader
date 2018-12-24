// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/RotPlane"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "UnityCG.cginc"
            //�Զ���ṹ�壬����λ�ú���ɫ����
            struct v2f
            {
                float4 pos : POSITION;
                float4 col : COLOR;
            };
            //Vertex shader��ڣ���ɫ��ϢҲ�ڴ�һ��������
            v2f vert (appdata_base v)
            {
                v2f o;
                //������ת�Ƕȣ�����_SinTime.wΪ��ת�Ƕȼ������ڱ任���ʣ�_SinTime ��Unity�ṩ�����ñ�����
                float angle = length(v.vertex)* _SinTime.w;
                //��Y����ת����
                float4x4 RM={
                    float4(cos(angle) , 0 , sin(angle) , 0),
                    float4(0 , 1 ,0 , 0),
                    float4(-1 * sin(angle) , 0 , cos(angle),0),
                    float4(0 , 0 ,0 ,1)
                };
                //����RM����Ӱ�춥��λ����Ϣ
                float4 pos = mul(RM , v.vertex);
                //�Ѷ�����Ϣת������������ϵ��
                o.pos = UnityObjectToClipPos(pos);
                
                //�ɶ��㵽���ĵ�ľ��������ɫ��Ϣ
                angle = abs(sin(length(v.vertex)));
                o.col = float4(angle , 1 , 0 ,1);
                return o;
            }
            //Ƭ�γ�����ֱ�ӷ��ض���Shader�м���õ�����ɫ��Ϣ
            float4 frag (v2f v) : color
            {
                return v.col;
            }
            ENDCG
        }
    }
}