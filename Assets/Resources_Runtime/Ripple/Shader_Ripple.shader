Shader "Custom/Shader_Ripple"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Center ("Center", Vector) = (0.5, 0.5, 0, 0)
        _Frequency ("Frequency", Float) = 10.0
        _Amplitude ("Amplitude", Float) = 0.05
        _Speed ("Speed", Range(0,10)) = 1.0
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
            float4 _Center;
            float _Frequency;
            float _Amplitude;
            float _Speed;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 center = _Center.xy;
                float time = _Time * _Speed * 10;
                float dist = distance(i.uv, center);
                float ripple = sin(dist * _Frequency - time) * _Amplitude;
                float2 rippleTexCoord = i.uv + normalize(i.uv - center) * ripple;
                return tex2D(_MainTex, rippleTexCoord);
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}