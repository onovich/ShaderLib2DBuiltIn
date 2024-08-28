Shader "Unlit/Shader_Melt"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _DistortionStrength ("Distortion Strength", Range(0.0, 1.0)) = 0.5
        _RippleFrequency ("Ripple Frequency", Range(0.0, 10.0)) = 1.0
        _RippleAmplitude ("Ripple Amplitude", Range(0.0, 1.0)) = 0.1
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

            // Shader properties
            sampler2D _MainTex;
            float _DistortionStrength;
            float _RippleFrequency;
            float _RippleAmplitude;

            // Vertex data structure
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

            // Fragment shader
            fixed4 frag (v2f i) : SV_Target
            {
                // Calculate distortion
                float2 uvDistorted = i.uv;
                float time = _Time.y;
                
                // Ripple effect
                float ripple = sin(_RippleFrequency * (i.uv.x + time)) * sin(_RippleFrequency * (i.uv.y + time));
                float2 distortion = ripple * _RippleAmplitude * float2(sin(time), cos(time));

                // Apply distortion to UV coordinates
                uvDistorted += distortion * _DistortionStrength;

                // Sample the main texture
                fixed4 color = tex2D(_MainTex, uvDistorted);

                return color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}