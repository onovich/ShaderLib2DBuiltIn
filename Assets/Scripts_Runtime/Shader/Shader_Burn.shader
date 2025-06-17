Shader "Custom/Burn"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _Position ("Burn Position", Vector) = (0.5, 0.5, 0, 0)
        _Radius ("Burn Radius", Range(0, 2)) = 0
        _BorderWidth ("Border Width", Float) = 0.02
        _BurnMult ("Burn Multiplier", Float) = 0.135
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
            sampler2D _NoiseTex;
            float4 _MainTex_ST;
            float2 _Position;
            float _Radius;
            float _BorderWidth;
            float _BurnMult;
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
                fixed4 col = tex2D(_MainTex, i.uv);
                float noise = tex2D(_NoiseTex, i.uv).b;
                float dist = length(_Position - i.uv) + noise * _BurnMult;
                
                // Apply burn color to border
                col.rgb = lerp(col.rgb, _BurnColor.rgb, step(dist, _Radius + _BorderWidth));
                
                // Make center transparent
                col.a *= 1.0 - step(dist, _Radius);
                
                return col;
            }
            ENDCG
        }
    }
}