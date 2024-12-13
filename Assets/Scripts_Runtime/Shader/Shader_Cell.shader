Shader "Custom/Shader_Cell"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor ("BaseColor", Color) = (1,0,0,1)
        _RippleSpeed ("RippleSpeed", Range(0, 10)) = 2.0
        _RippleDensity ("RippleDensity", Float) = 2.0
        _RippleSlimness ("RippleSlimness", Range(0, 10)) = 2.0
        _RippleColor ("RippleColor", Color) = (1,0,0,1)
    }
    
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            
            // Properties
            sampler2D _MainTex;
            fixed4 _BaseColor;
            fixed _RippleSpeed;
            fixed _RippleDensity;
            fixed _RippleSlimness;
            fixed4 _RippleColor;
            fixed _WaveSpeed;

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

            // Tiling
            float2 Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset)
            {
                return UV * Tiling + Offset;
            }

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            // Voronoi
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

            // RadialShear
            float2 Unity_RadialShear_float(float2 UV, float2 Center, float Strength, float2 Offset)
            {
                float2 delta = UV - Center;
                float delta2 = dot(delta.xy, delta.xy);
                float2 delta_offset = delta2 * Strength;
                return UV + float2(delta.y, -delta.x) * delta_offset + Offset;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed2 vorUV = Unity_RadialShear_float(i.uv, fixed2(0.5, 0.5), fixed2(1, 1), fixed2(0, 0));
                fixed rippleSpeed = _Time * _RippleSpeed * 100;

                fixed v = Unity_Voronoi_float(vorUV, rippleSpeed, _RippleDensity);
                fixed c = pow(v, _RippleSlimness);
                fixed4 finalColor =  c * _RippleColor + _BaseColor;

                return finalColor;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}