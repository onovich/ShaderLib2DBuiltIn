Shader "Custom/Shader_Mandelbrot"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Mouse ("Mouse", Vector) = (0,0,0,0)
        _ScreenParams ("Screen Params", Vector) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            float4 _Mouse;

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

            float addend(float zRe, float zIm) 
            {
                return 1.0 - abs(sin(5.0 * atan2(zIm, zRe)));
            }

            float3 IterateMandelbrot(float2 c)
            {
                const float B = 1e15;
                const float n_skip = 2.0;
                float n = 0.0;
                float orbitToReal = 0.0;
                float prevOrbitToReal = 0.0;
                float2 z = c;

                for (int i = 0; i < 900; i++)
                {
                    z = float2(z.x * z.x - z.y * z.y, (2.0 * z.x * z.y)) + c;
                    if (n > n_skip) orbitToReal += addend(z.x, z.y);
                    if (dot(z, z) > B) break;
                    prevOrbitToReal = orbitToReal;
                    n += 1.0;
                }

                if (n < 900.0)
                {
                    orbitToReal /= n - n_skip;
                    prevOrbitToReal /= n - n_skip - 1.0;
                    float u = n + 1.0 + (log(2.0 * log(B) / log(dot(z, z))) / log(2.0));
                    float d = u - floor(u);
                    float average = d * orbitToReal + (1.0 - d) * prevOrbitToReal;
                    return float3(u, average, 0.0);
                }
                else
                {
                    return float3(0.0, 0.0, 0.0);
                }
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float2 uv = (i.uv * 2.0 - 1.0) * 2.3;
                uv.x -= 0.5;

                float3 background = float3(0.1, 0.1, 0.1);
                float2 mouse = _Mouse.xy / _ScreenParams.xy;
                float3 li = float3(-mouse.x * 2.3 - 0.5, mouse.y * 2.3, 1.0);
                float sc = sqrt((_Time.y + 200.0) / 2.0);

                float3 t = IterateMandelbrot(uv / pow(1.002, cos(_Time.y / 9.0 + 3.1415) * 3500.0 + 5500.0) * 100.0 + float2(0.4369387, 0.3765258));
                float l = log(2.0);
                float a = 1.0 * l;
                float b = 1.0 / (3.0 * sqrt(2.0)) * l;
                float c = 1.0 / (7.0 * pow(3.0, 1.0 / 8.0)) * l;
                float x = log(log(t.x)) / 0.05 + 18.0;

                fixed4 color = fixed4(
                    (1.0 - cos(a * x)) / 2.0,
                    (1.0 - cos(b * x)) / 2.0,
                    (1.0 - cos(c * x)) / 2.0,
                    1.0
                ) * 0.4 + 0.01;

                color.rgb += max((t.y * 1.0 - 0.4) * 2.0, -0.9) + (log(t.x) / 20.0) * 1.5;
                return color;
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}