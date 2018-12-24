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
                // 绘制圆形，此处半径使用了固定值1000和500,当然大家也可以把他们写成可调的参数    
                if( pow((i.vertex.x- _Point1.x ),2) + pow((i.vertex.y- _Point1.y ),2) <1000   )    
                {    
                    return fixed4(0,1,0,1);    
                }    
                if( pow((i.vertex.x- _Point2.x ),2) + pow((i.vertex.y- _Point2.y ),2) <500   )    
                {    
                    return fixed4(1,0,0,1);    
                }    
     
                // 绘制直线上两点    
                if( pow((i.vertex.x- _LP1.x ),2) + pow((i.vertex.y- _LP1.y ),2) <100   )    
                {    
                    return fixed4(0,0,1,1);    
                }    
                if( pow((i.vertex.x- _LP2.x ),2) + pow((i.vertex.y- _LP2.y ),2) <100   )    
                {    
                    return fixed4(0,0,1,1);    
                }    
     
                // 计算点到直线的距离    
                float d = abs((_LP2.y-_LP1.y)*i.vertex.x + (_LP1.x - _LP2.x)*i.vertex.y +_LP2.x*_LP1.y -_LP2.y*_LP1.x )/sqrt(pow(_LP2.y-_LP1.y,2) + pow(_LP1.x-_LP2.x,2));    
                
				// 小于或者等于线宽的一半时，属于直线范围    
                if(d<=_LineWidth/2)    
                {    
                    return fixed4(0.8,0.2,0.5,1);    
                }    
     
                // 绘制网格直线  
				// 竖线	
                if( (unsigned int)i.vertex.x% (unsigned int)(0.25*_ScreenParams.x)==0 )    
                {    
                    return fixed4(0,1,0,0.3);    
                }    
				
				// 横线
                if( (unsigned int)i.vertex.y% (unsigned int)(0.1*_ScreenParams.x)==0 )    
                {    
                    return fixed4(0,0,1,1);    
                }    
				
                // 默认返回白色    
                //return fixed4(1, 1, 1, 1);    
				return fixed4(0, 0, 0, 0);    
     
            }    
            ENDCG    
        }    
    }    
}  