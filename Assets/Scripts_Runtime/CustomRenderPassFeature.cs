using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CustomRenderPassFeature : ScriptableRendererFeature {
    public Pass_Blur blurPass;
    public Pass_ScanLines scanLinesPass;

    public override void Create() {
        {
            if (blurPass == null) {
                blurPass = new Pass_Blur();
            }
        }
        {
            if (scanLinesPass == null) {
                scanLinesPass = new Pass_ScanLines();
            }
        }
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData) {
        {
            if (blurPass != null) {
                renderer.EnqueuePass(blurPass);
            }
        }
        {
            if (scanLinesPass != null) {
                renderer.EnqueuePass(scanLinesPass);
            }
        }
    }

    public override void SetupRenderPasses(ScriptableRenderer renderer, in RenderingData renderingData) {
        {
            base.SetupRenderPasses(renderer, renderingData);
            if (blurPass != null) {
                blurPass.Setup(renderer.cameraColorTargetHandle);
            }
        }
        {
            base.SetupRenderPasses(renderer, renderingData);
            if (scanLinesPass != null) {
                scanLinesPass.Setup(renderer.cameraColorTargetHandle);
            }
        }
    }
}


