Shader "Unlit/sdArc"
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

                float time = _Time.y;
    float ta = (0.5+0.5*cos(time*0.52+2.0));
    float tb = (0.5+0.5*cos(time*0.31+2.0));
    float rb = 0.15*(0.5+0.5*cos(time*0.41+3.0));
	            float d = sdArc(p,0, 0.6, 1.0, 0.3);
                
                col = DebugSDF2D(d);
                return float4(col, 1.);
            }
            ENDCG
        }
    }
}
