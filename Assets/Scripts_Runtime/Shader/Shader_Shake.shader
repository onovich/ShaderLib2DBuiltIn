Shader "Custom/ShakeGlitch"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _ShakeAmount ("Shake Amount", Range(0.0, 10.0)) = 1.0
        _ShakeSpeed ("Shake Speed", Range(0.0, 10.0)) = 1.0
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
            float _ShakeAmount;
            float _ShakeSpeed;

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
                o.uv = v.uv;

                // 计算时间
                float time = _Time.y * _ShakeSpeed * 10;

                // 根据时间确定震动方向
                float stepSize = 1.0; // 步长
                float stepCount = 4.0; // 方向数量（上、下、左、右）

                // 计算偏移方向
                float directionIndex = floor(time % stepCount) / (stepCount - 1);
                float offsetRange = _ShakeAmount / 1000;
                float offset = offsetRange * (2.0 * frac(0.841 + directionIndex) - 1.0);

                float2 direction;
                if (directionIndex < 0.25)
                    direction = float2(1.0, 0.0); // 右
                else if (directionIndex < 0.5)
                    direction = float2(0.0, 1.0); // 上
                else if (directionIndex < 0.75)
                    direction = float2(-1.0, 0.0); // 左
                else
                    direction = float2(0.0, -1.0); // 下

                // 应用偏移到顶点坐标
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.vertex.xy += direction * offset;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 采样纹理
                fixed4 color = tex2D(_MainTex, i.uv);
                return color;
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}