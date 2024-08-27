Shader "Unlit/Shader_RGBShift"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Amount ("Amount", Range(0, 0.05)) = 0.01
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
            float _Amount;

            struct Input {
                float2 uv_MainTex;
            };

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

            inline fixed4 GetRGBShiftColor(v2f i){
                float2 coords = i.uv.xy;
                float offset = _Amount;
                
                float4 red = tex2D(_MainTex , coords.xy - offset);
                float4 green = tex2D(_MainTex, coords.xy );
                float4 blue = tex2D(_MainTex, coords.xy + offset);
                
                float4 finalColor = float4(red.r, green.g, blue.b, 1.0f);
                return finalColor;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c = GetRGBShiftColor(i);
                return c;
            }
           
            ENDCG
        }
    }
}