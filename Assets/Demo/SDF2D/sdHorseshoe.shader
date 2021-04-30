Shader "Unlit/sdHorseshoe"
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

                float2  w = float2(0.750,0.25)*(0.5+0.5*cos(_Time.y*float2(0.7,1.1)+float2(0.0,3.0)));
                
	            float d = sdHorseshoe( p, float2(cos(1),sin(1)), 1, float2(1,0.3));
                col = DebugSDF2D(d);
                
                return float4(col, 1.);
            }
            ENDCG
        }
    }
}
