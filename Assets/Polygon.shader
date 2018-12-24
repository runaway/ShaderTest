// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/polygon"  
{  
    Properties    
    {    
        //����������ԣ����Դӱ༭������������õı���    
        // _MainTex ("Texture", 2D) = "white" {}    
    }    
  
    CGINCLUDE  
            //��Ӧ�ó����붥�㺯�������ݽṹ����   
            struct appdata    
            {    
                float4 vertex : POSITION;    
                float2 uv : TEXCOORD0;    
            };    
            //�Ӷ��㺯������Ƭ�κ��������ݽṹ����    
            struct v2f    
            {    
                float2 uv : TEXCOORD0;    
                float4 vertex : SV_POSITION;    
            };    
            //������ͼ����    
            sampler2D _MainTex;    
            // float4 _MainTex_ST;    
  
            //������ű�����ͨ�ŵı���  
            vector Value[6];   
            int PointNum =0;  
  
            //���������ľ���ĺ���  
            float Dis(float4 v1,float4 v2)  
            {  
                return sqrt(pow((v1.x-v2.x),2)+pow((v1.y-v2.y),2));  
            }     
  
            //�����߶�  
            bool DrawLineSegment(float4 p1, float4 p2, float lineWidth,v2f i)  
            {  
                float4 center = float4((p1.x+p2.x)/2,(p1.y+p2.y)/2,0,0);  
                //����㵽ֱ�ߵľ���    
                float d = abs((p2.y-p1.y)*i.vertex.x + (p1.x - p2.x)*i.vertex.y +p2.x*p1.y -p2.y*p1.x )/sqrt(pow(p2.y-p1.y,2) + pow(p1.x-p2.x,2));    
                //С�ڻ��ߵ����߿��һ��ʱ������ֱ�߷�Χ    
                float lineLength = sqrt(pow(p1.x-p2.x,2)+pow(p1.y-p2.y,2));  
                if(d<=lineWidth/2 && Dis(i.vertex,center)<lineLength/2)    
                {    
                    return true;    
                }    
                return false;  
            }  
  
            //���ƶ���Σ����������˶�����������6�������Լ�������Ҫ���ġ�  
            bool pnpoly(int nvert, float4 vert[6], float testx, float testy)  
            {  
                  
                int i, j;  
                bool c=false;  
                float vertx[6];  
                float verty[6];  
  
                for(int n=0;n<nvert;n++)  
                {  
                    vertx[n] = vert[n].x;  
                    verty[n] = vert[n].y;  
                }  
                for (i = 0, j = nvert-1; i < nvert; j = i++) {  
                if ( ((verty[i]>testy) != (verty[j]>testy)) && (testx < (vertx[j]-vertx[i]) * (testy-verty[i]) / (verty[j]-verty[i]) + vertx[i]) )  
                   c = !c;  
                }  
                return c;  
            }  
                              
            v2f vert (appdata v)    
            {    
                v2f o;    
                //�����嶥���ģ�Ϳռ任����������ÿռ䣬Ҳ�ɲ��ü�д��ʽ����o.vertex = UnityObjectToClipPos(v.vertex);    
                o.vertex = UnityObjectToClipPos(v.vertex);    
                //2D UV����任,Ҳ���Բ��ü�д��ʽ����o.uv = TRANSFORM_TEX(v.uv, _MainTex);    
                //o.uv = v.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;    
                return o;    
            }               
            fixed4 frag (v2f i) : SV_Target    
            {    
                  
                //���ƶ���ζ���  
                for(int j=0;j<PointNum;j++)  
                {  
                    if(Dis(i.vertex, Value[j])<3)  
                    {  
                        return fixed4(1,0,0,0.5);  
                    }  
                }  
                //���ƶ���εı�  
                for(int k=0;k<PointNum;k++)  
                {  
                    if(k==PointNum-1)  
                    {  
                        if(DrawLineSegment(Value[k],Value[0],2,i))  
                        {  
                            return fixed4(1,1,0,0.5);  
                        }  
                    }  
                    else  
                    {  
                        if(DrawLineSegment(Value[k],Value[k+1],2,i))  
                        {  
                            return fixed4(1,1,0,0.5);  
                        }  
                    }  
  
                }  
                //��������ڲ�  
                if(pnpoly(PointNum, Value,i.vertex.x ,i.vertex.y))  
                {  
                    return fixed4(0,1,0,0.3);  
                }  
                return fixed4(0,0,0,0);  
                //fixed4 col = tex2D(_MainTex, i.uv);   
                //return col;    
            }    
    ENDCG  
  
    SubShader    
    {    
        Tags { "RenderType"="Opaque" }    
        LOD 100    
        Pass    
        {    
            //ѡȡAlpha��Ϸ�ʽ    
            Blend  SrcAlpha OneMinusSrcAlpha    
            //��CGPROGRAM�������д�Լ��Ĵ������    
            CGPROGRAM    
            //���嶥�㺯����Ƭ�κ�������ڷֱ�Ϊvert��frag    
            #pragma vertex vert    
            #pragma fragment frag    
            //�����������ļ���������һЩ�궨��ͻ�������    
            #include "UnityCG.cginc"                 
             
            ENDCG    
        }    
    }    
}  