using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class CustomRenderPassFeature : ScriptableRendererFeature {
    public Pass_Blur blurPass;
    public Pass_ScanLines scanLinesPass;

    public override void Create() {
        {
            if (blurPass != null) {
                return;
            }
            blurPass = new Pass_Blur();
        }
        {
            if (scanLinesPass != null) {
                return;
            }
            scanLinesPass = new Pass_ScanLines();
        }
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData) {
        {
            if (blurPass == null) {
                return;
            }
            renderer.EnqueuePass(blurPass);
        }
        {
            if (scanLinesPass == null) {
                return;
            }
            renderer.EnqueuePass(scanLinesPass);
        }
    }

    public override void SetupRenderPasses(ScriptableRenderer renderer, in RenderingData renderingData) {
        {
            base.SetupRenderPasses(renderer, renderingData);
            if (blurPass == null) {
                return;
            }
            blurPass.Setup(renderer.cameraColorTargetHandle);
        }
        {
            base.SetupRenderPasses(renderer, renderingData);
            if (scanLinesPass == null) {
                return;
            }
            scanLinesPass.Setup(renderer.cameraColorTargetHandle);
        }
    }
}


