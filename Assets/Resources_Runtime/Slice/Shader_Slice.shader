Shader "Unlit/Shader_Slice"
{

    Properties 
    {
        _MainTex("_Color", 2D) = "white" {}
        _GlitchAmount ("Glitch Amount", Range(0, 1)) = 0.5
        _SliceSize ("Slice Size", Range(0.01, 0.5)) = 0.1
        _Displacement ("Displacement", Range(0.0, 0.1)) = 0.05
        _Speed ("Speed", Range(0.0, 4.0)) = 1.0
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
            float _GlitchAmount;
            float _SliceSize;
            float _Displacement;
            float _Speed;

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
                float sliceCount = 1.0 / _SliceSize;
                float slice = floor(uv.y * sliceCount);

                // 计算每个切片的位移量
                float timeFactor = _Time.y * _Speed / 10000;

                // 计算伪随机数基于切片位置和时间
                float slicePhase = slice + timeFactor;
                float pseudoRandom = frac(sin(slicePhase) * 43758.5453123);

                // 将伪随机数映射到[-1, 1]范围
                float randomValue = pseudoRandom * 2.0 - 1.0;

                // 计算最终的偏移量
                float randomOffset = _Displacement * randomValue;

                // 应用位移
                if (randomOffset < _GlitchAmount)
                {
                    uv.x += randomOffset;
                }

                fixed4 color = tex2D(_MainTex, uv);
                return color;
            }
    
            ENDCG   
        }
    }
    FallBack "Diffuse"
}