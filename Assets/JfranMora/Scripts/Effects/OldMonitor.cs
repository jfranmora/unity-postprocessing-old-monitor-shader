using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(OldMonitorRenderer), PostProcessEvent.AfterStack, "JfranMora/OldMonitor")]
public class OldMonitor : PostProcessEffectSettings
{
    [Header("Monitor")] 
    [Range(2f, 10f)] public FloatParameter monitorBend = new FloatParameter() {value = 2f};
    
    [Header("Slowscan")]    
    [Range(0, .1f)] public FloatParameter slowscanIntensity = new FloatParameter() {value = .1f};
    [Range(-1, 1f)] public FloatParameter slowscanDistortion = new FloatParameter() {value = .5f};
    
    [Header("Scanlines")]
    public FloatParameter scanline = new FloatParameter(){value = 600f};
    public FloatParameter scanlineSpeed = new FloatParameter() {value = 10f};
}

public sealed class OldMonitorRenderer : PostProcessEffectRenderer<OldMonitor>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/JfranMora/Scanlines"));
        sheet.properties.SetFloat("_MonitorBend", settings.monitorBend);
        sheet.properties.SetFloat("_SlowscanIntensity", settings.slowscanIntensity);
        sheet.properties.SetFloat("_SlowscanDistortion", settings.slowscanDistortion * .015f);
        sheet.properties.SetFloat("_Scanline", settings.scanline);
        sheet.properties.SetFloat("_ScanlineSpeed", settings.scanlineSpeed);		
        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);        
    }
}
