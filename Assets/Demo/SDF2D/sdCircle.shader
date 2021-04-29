Shader "Unlit/Circle2D"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Assets/ShaderLibrary/SDF2D.cginc"

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
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                float4 col = 0.;
                float2 p = i.uv - 0.5;
                p *= 3.0;
                
                float d = sdCircle(p,0.5);
                col.rgb = 1. - sign(d) * float3(0.1,0.4,0.7);
                col.rgb *= 1.0 - exp(-5.0*abs(d));
                col *= 0.8 + 0.2*cos(150.0*d + 15.0 * _Time.y);
                col.rgb = lerp( 1.0, col.rgb, smoothstep(0.0,0.01,abs(d)) );
                
                return col;
            }
            ENDCG
        }
    }
}
