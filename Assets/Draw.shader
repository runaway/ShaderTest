Shader "Custom/Draw"   
{    
    Properties    
    {    
        _Point1("Point1",vector) = (100,100,0,0)    
        _Point2("Point2",vector) = (200,200,0,0)    
        _LP1("linePoint1",vector) = (300,100,0,0)    
        _LP2("linePoint2",vector) = (600,400,0,0)    
        _LineWidth("LineWidth",range(1,20)) = 2.0    
         
    }    
    SubShader    
    {    
        Pass    
        {    
            CGPROGRAM    
            #pragma vertex vert    
            #pragma fragment frag    
                
            #include "UnityCG.cginc"    
     
            struct appdata    
            {    
                float4 vertex : POSITION;    
            };    
     
            struct v2f    
            {    
                float4 vertex : SV_POSITION;    
            };    
            float4 _Point1;    
            float4 _Point2;    
            float4 _LP1;    
            float4 _LP2;    
            float _LineWidth;           
                 
            v2f vert (appdata v)    
            {    
                v2f o;    
 
                o.vertex = UnityObjectToClipPos(v.vertex);    
                return o;    
            }    
                 
            fixed4 frag (v2f i) : SV_Target    
            {    
                // ����Բ�Σ��˴��뾶ʹ���˹̶�ֵ1000��500,��Ȼ���Ҳ���԰�����д�ɿɵ��Ĳ���    
                if( pow((i.vertex.x- _Point1.x ),2) + pow((i.vertex.y- _Point1.y ),2) <1000   )    
                {    
                    return fixed4(0,1,0,1);    
                }    
                if( pow((i.vertex.x- _Point2.x ),2) + pow((i.vertex.y- _Point2.y ),2) <500   )    
                {    
                    return fixed4(1,0,0,1);    
                }    
     
                // ����ֱ��������    
                if( pow((i.vertex.x- _LP1.x ),2) + pow((i.vertex.y- _LP1.y ),2) <100   )    
                {    
                    return fixed4(0,0,1,1);    
                }    
                if( pow((i.vertex.x- _LP2.x ),2) + pow((i.vertex.y- _LP2.y ),2) <100   )    
                {    
                    return fixed4(0,0,1,1);    
                }    
     
                // ����㵽ֱ�ߵľ���    
                float d = abs((_LP2.y-_LP1.y)*i.vertex.x + (_LP1.x - _LP2.x)*i.vertex.y +_LP2.x*_LP1.y -_LP2.y*_LP1.x )/sqrt(pow(_LP2.y-_LP1.y,2) + pow(_LP1.x-_LP2.x,2));    
                
				// С�ڻ��ߵ����߿��һ��ʱ������ֱ�߷�Χ    
                if(d<=_LineWidth/2)    
                {    
                    return fixed4(0.8,0.2,0.5,1);    
                }    
     
                // ��������ֱ��  
				// ����	
                if( (unsigned int)i.vertex.x% (unsigned int)(0.25*_ScreenParams.x)==0 )    
                {    
                    return fixed4(0,1,0,0.3);    
                }    
				
				// ����
                if( (unsigned int)i.vertex.y% (unsigned int)(0.1*_ScreenParams.x)==0 )    
                {    
                    return fixed4(0,0,1,1);    
                }    
				
                // Ĭ�Ϸ��ذ�ɫ    
                //return fixed4(1, 1, 1, 1);    
				return fixed4(0, 0, 0, 0);    
     
            }    
            ENDCG    
        }    
    }    
}  