Shader "Custom/Toon"
{
    Properties
    {
        _MainTex("Main Texture",2D) = "white"{}
        _BumpTex("Normal Texture",2D) = "bump"{}
        _SpecTex("SpecMap",2D) = "white"{}

    }
        SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        cull back
        //pass1
        CGPROGRAM
        #pragma surface surf _CustomCell noambient
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpTex,_SpecTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpTex, uv_SpecTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            float4 mainTex = tex2D(_MainTex, IN.uv_MainTex);
            float4 specTex = tex2D(_SpecTex, IN.uv_SpecTex);

            o.Normal = UnpackNormal(tex2D(_BumpTex, IN.uv_BumpTex));
            o.Albedo = mainTex.rgb;
            o.Gloss = specTex.a;
        }
        
        float4 Lighting_CustomCell(SurfaceOutput o, float3 lightDir,float3 viewDir, float atten) {

            float fNDotl = dot(o.Normal, lightDir) * 0.7 + 0.3;

            //diffuse
            if (fNDotl > 0.5)fNDotl = 1;
            else if (fNDotl > 0.3) fNDotl = 0.3;
            else fNDotl = 0.1;

            //specular
            float3 fHResult;
            float3 fH = normalize(lightDir + viewDir);
            float fH_Dot = saturate(dot(o.Normal, fH));
            fH_Dot = pow(fH_Dot, 10);

            if (fH_Dot > 0.8) fH_Dot = 1;
            else fH_Dot = 0;
            
            fHResult = fH_Dot * o.Gloss;

            float4 fResult;
            fResult.rgb = fNDotl * o.Albedo * _LightColor0.rgb * atten;
            fResult.a = o.Alpha;
            return fResult;
        }

        ENDCG

        cull front
        //pass2
        CGPROGRAM
        #pragma surface surf Standard vertex:vert
        #pragma target 3.0

        struct Input
        {
            float _Blank;
        };

        void vert(inout appdata_full v) {
            v.vertex.xyz += v.normal.xyz * 0.01;
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = 0;
        }
        ENDCG

    }
    FallBack "Diffuse"
}
