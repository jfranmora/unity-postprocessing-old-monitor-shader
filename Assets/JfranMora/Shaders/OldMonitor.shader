Shader "Hidden/JfranMora/Scanlines"
{
    HLSLINCLUDE

    #include "Packages/com.unity.postprocessing/PostProcessing/Shaders/StdLib.hlsl"
    #include "Common.cginc"
    
    TEXTURE2D_SAMPLER2D(_MainTex, sampler_MainTex);
    float _MonitorBend;
    
    // x -> _SlowscanWidth
    // y -> _SlowscanSpeed
    // z -> _SlowscanDistortion
    // w -> _SlowscanIntensity
    float4 _SlowscanSettings;
    
    float _Scanline;
    float _ScanlineSpeed;    

	float scanline(float2 uv) 
    {
        return cos(_Scanline * uv.y * 0.7 - _Time.y * _ScanlineSpeed);
    }

    float slowscan(float2 uv) 
    {
        float r = cos(uv.y * 3.1415 + _Time.y * _SlowscanSettings.y);      // -1 --> 1
        r = clamp(r, 1 - _SlowscanSettings.x, 1);
        r = remap(r, 1 - _SlowscanSettings.x, 1, 0, 1);
        r = r*r*r*r*r;
        return r;
    }
    
    float2 crt(float2 coord, float bend)
    {
        // put in symmetrical coords
        coord = (coord - 0.5) * 2.0;    
        coord *= 0.5;	
        
        // deform coords
        coord.x *= 1.0 + pow((abs(coord.y) / bend), 2.0);
        coord.y *= 1.0 + pow((abs(coord.x) / bend), 2.0);
    
        // transform back to 0.0 - 1.0 space
        coord  = (coord / 1.0) + 0.5;
    
        return coord;
    }
    
    float2 scandistort(float2 uv) 
    {
        return float2(uv.x - slowscan(uv) * _SlowscanSettings.z, uv.y);
    }
    
    float4 frag(VaryingsDefault i) : SV_Target
    {   
        float2 uv = i.texcoord / 1;
        float2 crt_uv = crt(uv, _MonitorBend);
        float2 sd_uv = scandistort(crt_uv);
        float2 uv_dif = sd_uv - crt_uv;
        
        float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, sd_uv).xyzw;
        color.y = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, sd_uv + uv_dif).y;
        color.z = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, sd_uv - uv_dif).z;
            
        float4 scanline_color = float4(scanline(sd_uv), scanline(sd_uv), scanline(sd_uv), scanline(sd_uv));
        
        float4 result = lerp(color, color * scanline_color, .1f);
        result += _SlowscanSettings.w * float4(1,1,1,1) * slowscan(uv);  
        return result;
    }
	
	ENDHLSL
	
	SubShader
    {
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            HLSLPROGRAM
                #pragma vertex VertDefault
                #pragma fragment frag
            ENDHLSL
        }
    }
}