Shader "Custom/Shader_Vortex"
{
    Properties
    {
        _Color1 ("Color 1", Color) = (1,0,0,1)
        _Color2 ("Color 2", Color) = (0,0,1,1)
        _Color3 ("Transition Color", Color) = (0,0,0,1)
        _Color4 ("Start/End Color", Color) = (1,1,1,1)
        _Contrast ("Contrast", Range(0, 10)) = 5
        _Gradual ("Gradual", Range(0.0, 2.0)) = 2.0
        _Width1 ("Width 1", Range(0.01, 1.0)) = 0.04
        _Width2 ("Width 2", Range(0.01, 1.0)) = 0.1
        _Scale1 ("Scale 1", Range(0.0, 100.0)) = 10.0
        _Scale2 ("Scale 2", Range(0.0, 10.0)) = 1.0
        _Offset ("Offset", Vector) = (0, 0, 0, 0)
        _Intensity ("Intensity", Range(0.0, 4.0)) = 0.2
        _SpinSpeed ("Spin Speed", Range(0.0, 10.0)) = 0.2
        _SpinAmount ("Spin Amount", Range(0.0, 10.0)) = 1.5
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

        // 设置透明混合模式
        Blend SrcAlpha OneMinusSrcAlpha 

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float3 _Color1;
            float3 _Color2;
            float3 _Color3;
            float3 _Color4;
            int _Contrast;
            float _Gradual;
            float _Width1;
            float _Width2;
            float _Scale1;
            float _Scale2;
            float2 _Offset;
            float _Intensity;
            float _SpinSpeed;
            float _SpinAmount;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float3 ApplyGradient(float3 color1, float3 color2, float3 color3, float3 color4, float paintRes, float c3p, float c4p)
            {
                float3 retColor = lerp(color1, color2, paintRes);
                retColor = lerp(retColor, color3, c3p);
                retColor = lerp(retColor, color4, c4p);
                return retColor;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // 将UV坐标从[0,1]范围转换到[-0.5, 0.5]范围，以图片中心为原点
                float2 uv = (i.uv - 0.5) * _Scale2; 

                // 进行偏移操作
                uv += _Offset;

                // 计算旋转所需的距离和角度
                float uvLen = length(uv);
                float angle = atan2(uv.y, uv.x);

                // 根据距离衰减旋转，并应用时间变化
                angle -= _SpinAmount * uvLen;
                angle += _Time * _SpinSpeed;

                // 进行旋转
                uv = float2(uvLen * cos(angle), uvLen * sin(angle)) * _Scale2;

                // 恢复到[0,1]范围
                uv = uv * _Scale1 + 0.5;

                float2 uv2 = float2(uv.x + uv.y, uv.x + uv.y);

                for (int j = 0; j < _Contrast; j++)
                {
                    uv2 += sin(uv);
                    float cosVal = cos(_Intensity * uv2.y + _Time);
                    float sinVal = sin(_Intensity * uv2.x - _Time);
                    uv += float2(cosVal, sinVal);
                    uv -= float2(cos(uv.x + uv.y), sin(uv.x - uv.y));
                }

                float paintRes = smoothstep(0.0, _Gradual, length(uv) / _Scale1);

                float c3p = 1.0 - min(_Width2, abs(paintRes - 0.5)) * (1.0 / _Width2);
                float cOut = max(0.0, (paintRes - (1.0 - _Width1))) * (1.0 / _Width1);
                float cIn = max(0.0, -(paintRes - _Width1)) * (1.0 / _Width1);
                float c4p = cOut + cIn;

                float3 retColor = ApplyGradient(_Color1, _Color2, _Color3, _Color4, paintRes, c3p, c4p);

                return float4(retColor, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}