Shader "Unlit/Shader_Gradient"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Tex1 ("Overlay Texture", 2D) = "white" {}
        _Tex2 ("Overlay Texture", 2D) = "white" {}
        _T ("T", Range(0, 1)) = 0.0
        [Enum(Replace,0, Multiply,1)] 
        _SrcBlend ("Src Blend", Float) = 0
        [Toggle]
        _Auto ("Auto", Float) = 0
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
            sampler2D _Tex1;
            sampler2D _Tex2;
            float _T;
            int _SrcBlend;
            int _Auto;

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

            inline fixed4 GetDissolvedColor(v2f i){
                fixed4 baseColor = tex2D(_MainTex, i.uv);
                fixed4 color1 = tex2D(_Tex1, i.uv);
                fixed4 color2 = tex2D(_Tex2, i.uv);

                if(_Auto == 1){
                    _T = (sin(_Time.y * 3.14159) + 1.0) / 2.0;
                }
                
                if(_SrcBlend == 1){
                    color1 = color1 * baseColor;
                    color2 = color2 * baseColor;
                }

                fixed4 finalColor = lerp(color1, color2, _T);
                return finalColor;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c = GetDissolvedColor(i);
                return c;
            }
            ENDCG
        }
    }
}