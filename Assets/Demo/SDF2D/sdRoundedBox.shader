Shader "Unlit/RounedCube2D"
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
                
                float2 si = float2(0.9,0.6);
                float4 ra = 0.3 + 0.2*cos( 2.0*_Time.y + float4(0,1,2,3) );

	            float d = sdRoundedBox( p, si, ra );

                col = 1.0 - sign(d) * float3(0.1,0.4,0.7);
	            col *= 1.0 - exp(-3.0*abs(d));
	            col *= 0.8 + 0.2*cos(150.0*d);
	            col = lerp( col, 1.0, 1.0-smoothstep(0.0,0.01,abs(d)) );
                
                return float4(col, 1.);
            }
            ENDCG
        }
    }
}
