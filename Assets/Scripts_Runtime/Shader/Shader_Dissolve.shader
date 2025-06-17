Shader "Custom/Dissolve"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _DissolveTex ("Dissolve Texture", 2D) = "white" {}
        _DissolveValue ("Dissolve Value", Range(0, 1)) = 0
        _BurnSize ("Burn Size", Range(0, 1)) = 0.1
        _BurnColor ("Burn Color", Color) = (1, 0.3, 0, 1)
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
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
            sampler2D _DissolveTex;
            float4 _MainTex_ST;
            float _DissolveValue;
            float _BurnSize;
            float4 _BurnColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 mainTex = tex2D(_MainTex, i.uv);
                fixed4 noiseTex = tex2D(_DissolveTex, i.uv);
                
                // Avoid burn color when dissolve is 0 or 1
                float burnSizeStep = _BurnSize * step(0.001, _DissolveValue) * step(_DissolveValue, 0.999);
                
                float threshold = smoothstep(noiseTex.r - burnSizeStep, noiseTex.r, _DissolveValue);
                float border = smoothstep(noiseTex.r, noiseTex.r + burnSizeStep, _DissolveValue);
                
                fixed4 col;
                col.a = mainTex.a * threshold;
                col.rgb = lerp(_BurnColor.rgb, mainTex.rgb, border);
                
                return col;
            }
            ENDCG
        }
    }
}