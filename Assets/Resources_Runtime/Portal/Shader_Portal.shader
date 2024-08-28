Shader "Custom/Shader_Portal"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Mask("Mask", 2D) = "white" {}
        _Color ("Colour", Color) = (1,0,0,1)
        _Strength ("Strength", float) = 1.0
        _Brightness ("Brightness", float) = 1.0
        _Speed ("Speed", float) = 1.0
        _Densitity ("Densitity", float) = 1.0
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
            sampler2D _Mask;
            float4 _Color;
            float _Brightness;
            float _Strength;
            float _Densitity;
            float _Speed;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float2 Unity_Twirl_float(float2 UV, float2 Center, float Strength, float2 Offset)
            {
                float2 delta = UV - Center;
                float angle = Strength * length(delta);
                float x = cos(angle) * delta.x - sin(angle) * delta.y;
                float y = sin(angle) * delta.x + cos(angle) * delta.y;
                return float2(x + Center.x + Offset.x, y + Center.y + Offset.y);
            }

            inline float2 unity_voronoi_noise_randomVector (float2 UV, float offset)
            {
                float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
                UV = frac(sin(mul(UV, m)) * 46839.32);
                return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
            }

            float Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity)
            {
                float2 g = floor(UV * CellDensity);
                float2 f = frac(UV * CellDensity);
                float t = 8.0;
                float3 res = float3(8.0, 0.0, 0.0);
                float Out = 0.0;
                float Cells = 0.0;
                for(int y=-1; y<=1; y++)
                {
                    for(int x=-1; x<=1; x++)
                    {
                        float2 lattice = float2(x,y);
                        float2 offset = unity_voronoi_noise_randomVector(lattice + g, AngleOffset);
                        float d = distance(lattice + offset, f);
                        if(d < res.x)
                        {
                            res = float3(d, offset.x, offset.y);
                            Out = res.x;
                            Cells = res.y;
                        }
                    }
                }
                return Out;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 offset = float2(_Time.y * _Speed, _Time.y * _Speed);
                float2 uv = Unity_Twirl_float(i.uv, float2(0.5, 0.5), _Strength, offset);
                float vo = Unity_Voronoi_float(uv, 2.0, _Densitity);
                float4 b = float4(pow(vo, _Brightness), pow(vo, _Brightness), pow(vo, _Brightness), pow(vo, _Brightness));
                float4 baseColor = tex2D(_MainTex, i.uv);
                float4 maskColor = tex2D(_Mask, i.uv);
                float4 a = baseColor * maskColor;
                float4 c = a * b * _Color;
                return c;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}