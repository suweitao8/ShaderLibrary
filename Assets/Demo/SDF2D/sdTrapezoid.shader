Shader "Unlit/sdTrapezoid"
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
                float3 col = 0.;
                float2 p = i.uv - 0.5;
                p *= 3.;

                float ra = 0.2+0.15*sin(_Time.y*1.3+0.0);
                float rb = 0.2+0.15*sin(_Time.y*1.4+1.1);
                
	            float d = sdTrapezoid( p, 0.2, rb, 0.5 + 0.2 * sin(_Time.y));
                
                col = DebugSDF2D(d);
                
                return float4(col, 1.);
            }
            ENDCG
        }
    }
}
