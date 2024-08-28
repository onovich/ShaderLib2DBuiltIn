Shader "Unlit/Shader_ScanLines"
{

    Properties 
    {
        _MainTex("_Color", 2D) = "white" {}
        _LineWidth("Line Width", Range(0,10)) = 4
        _LineColor ("Line Color", Color) = (1,1,1,0.5)
        [Toggle]
        _Auto("Auto",int) = 0
        _AutoSpeed("Speed", Range(0,0.2)) = 0.2
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
            #pragma fragmentoption ARB_precision_hint_fastest
            #include "UnityCG.cginc"
            // #pragma target 3.0

            uniform sampler2D _MainTex;
            uniform float _LineWidth;
            uniform float _AutoSpeed;
            uniform int _Auto;
            uniform float4 _LineColor;

            struct v2f 
            {
                float4 pos      : POSITION;
                float2 uv       : TEXCOORD0;
                float4 scr_pos : TEXCOORD1;
            };
    
            v2f vert(appdata_img v) 
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = MultiplyUV(UNITY_MATRIX_TEXTURE0, v.texcoord);
                o.scr_pos = ComputeScreenPos(o.pos);
                
                return o;
            }
    
            half4 frag(v2f i) : COLOR 
            {
                // 读取纹理颜色
                half4 color = tex2D(_MainTex, i.uv);
                
                // 计算行宽和偏移
                fixed lineSize = _ScreenParams.y * 0.005;
                float displacement = ((_Time.y * 1000.0) * _AutoSpeed) % _ScreenParams.y;
                
                // 计算扫描线位置
                float lineOffset;
                if (_Auto == 1) {
                    lineOffset = displacement + (i.scr_pos.y * _ScreenParams.y / i.scr_pos.w);
                } else {
                    displacement = _ScreenParams.y;
                    lineOffset = displacement + (i.scr_pos.y * _ScreenParams.y / i.scr_pos.w);
                }
                
                // 计算行宽度
                float lineWidthInPixels = _LineWidth * lineSize;
                
                // 计算扫描线是否显示
                float ps = lineOffset;
                bool isLineVisible = ((int)(ps / floor(lineWidthInPixels)) % 2 == 0);
                
                // 返回最终颜色
                float4 finalColor = isLineVisible ? color : color * _LineColor;
                return finalColor;
            }
    
            ENDCG   
        }
    }
    FallBack "Diffuse"
}