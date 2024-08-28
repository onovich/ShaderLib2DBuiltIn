Shader "Custom/Shader_BarrelBlur"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BlurAmount ("Blur Amount", Range(0.0, 1.0)) = 0.5
        _Distortion ("Distortion", Range(0.0, 1.0)) = 0.5
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

            sampler2D _MainTex;
            float _BlurAmount;
            float _Distortion;

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;
                float2 center = float2(0.5, 0.5); // 中心点
                float2 offset = uv - center; // 从中心点的偏移量

                // 计算鱼眼畸变
                float dist = length(offset) * _Distortion;
                float2 distortedUV = center + offset * (1.0 + dist);

                // 计算模糊
                float blurFactor = _BlurAmount * dist;
                float4 color = float4(0.0, 0.0, 0.0, 0.0);
                int samples = 8; // 采样次数
                for (int j = 0; j < samples; j++)
                {
                    float angle = (float)j / (float)samples * 6.283185; // 0 to 2*PI
                    float2 sampleOffset = float2(cos(angle), sin(angle)) * blurFactor;
                    color += tex2D(_MainTex, distortedUV + sampleOffset) / (float)samples;
                }

                return color;
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}