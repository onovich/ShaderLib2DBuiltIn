Shader "Unlit/Shader_Wobble"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _WobbleAmount ("Wobble Amount", Range(0.0, 0.1)) = 0.05
        _WobbleSpeed ("Wobble Speed", Range(0.0, 10.0)) = 1.0
        _WobbleFrequency ("Wobble Frequency", Range(0.0, 10.0)) = 1.0
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
            float _WobbleAmount;
            float _WobbleSpeed;
            float _WobbleFrequency;
            float2 _MainTex_TexelSize;

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
                float wobbleX = sin(i.uv.y * _WobbleFrequency + _Time.y * _WobbleSpeed) * _WobbleAmount;
                float wobbleY = cos(i.uv.x * _WobbleFrequency + _Time.y * _WobbleSpeed) * _WobbleAmount;
                float2 uvOffset = float2(wobbleX, wobbleY);
                fixed4 color = tex2D(_MainTex, i.uv + uvOffset);
                return color;
            }
            ENDCG
        }
    }
}