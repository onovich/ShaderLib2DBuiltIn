Shader "Custom/Shader_Blur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("Blur Size", float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100

        // 设置透明混合模式
        Blend SrcAlpha OneMinusSrcAlpha 

        Pass
        {
            // Pass 1: Horizontal Blur
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float _BlurSize;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0, 0, 0, 0);
                float2 texelSize = _BlurSize / float2(_ScreenParams.x, _ScreenParams.y);
                float weightSum = 0.0;

                for (int x = -4; x <= 4; x++)
                {
                    for (int y = -4; y <= 4; y++)
                    {
                        float2 offset = float2(x, y) * texelSize;
                        float weight = exp(-0.5 * (x * x + y * y) / (_BlurSize * _BlurSize));
                        color += tex2D(_MainTex, i.uv + offset) * weight;
                        weightSum += weight;
                    }
                }
                
                return color / weightSum;
            }
            ENDCG
        }

        Pass
        {
            // Pass 2: Vertical Blur
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float _BlurSize;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 color = float4(0, 0, 0, 0);
                float2 texelSize = _BlurSize / float2(_ScreenParams.x, _ScreenParams.y);
                float weightSum = 0.0;

                for (int x = -4; x <= 4; x++)
                {
                    for (int y = -4; y <= 4; y++)
                    {
                        float2 offset = float2(x, y) * texelSize;
                        float weight = exp(-0.5 * (x * x + y * y) / (_BlurSize * _BlurSize));
                        color += tex2D(_MainTex, i.uv + offset) * weight;
                        weightSum += weight;
                    }
                }
                
                return color / weightSum;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}