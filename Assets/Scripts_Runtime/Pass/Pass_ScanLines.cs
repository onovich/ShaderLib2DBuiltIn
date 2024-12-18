using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[Serializable]
public class Pass_ScanLines : ScriptableRenderPass {

    [SerializeField] Shader shader;
    Material material;
    string renderTag;
    int mainTexID;
    int tempTexID;
    RenderTargetIdentifier currentTarget;
    RenderTextureDescriptor cameraTextureDescriptor;
    Volume_ScanLines volume;

    public void Setup(RenderTargetIdentifier rt) {
        renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
        material = CoreUtils.CreateEngineMaterial(shader);
        renderTag = "ScanLinesRender";
        mainTexID = Shader.PropertyToID("_MainTex");
        tempTexID = Shader.PropertyToID("_TempText");
        currentTarget = rt;
    }

    public override void Configure(CommandBuffer cmd, RenderTextureDescriptor cameraTextureDescriptor) {
        this.cameraTextureDescriptor = cameraTextureDescriptor;
    }

    public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData) {
        bool isEnablePP = renderingData.cameraData.postProcessEnabled;
        if (!isEnablePP) {
            return;
        }

        if (material == null) {
            return;
        }

        var stack = VolumeManager.instance.stack;
        volume = stack.GetComponent<Volume_ScanLines>();
        volume.active = volume.isEnable.value;
        if (!volume.isEnable.value) {
            return;
        }

        material.SetFloat("_LineWidth", volume.lineWidth.value);
        material.SetColor("_LineColor", volume.lineColor.value);
        material.SetInt("_IsAuto", volume.isAuto.value ? 1 : 0);
        material.SetFloat("_AutoSpeed", volume.autoSpeed.value);

        var cameraData = renderingData.cameraData;
        var camera = cameraData.camera;
        var cmd = CommandBufferPool.Get(renderTag);
        var src = currentTarget;
        var dst = tempTexID;

        cmd.SetGlobalTexture(mainTexID, src);
        cmd.GetTemporaryRT(dst, cameraTextureDescriptor);
        cmd.Blit(src, dst);
        cmd.Blit(dst, src, material, 0);
        context.ExecuteCommandBuffer(cmd);
        CommandBufferPool.Release(cmd);
    }

}