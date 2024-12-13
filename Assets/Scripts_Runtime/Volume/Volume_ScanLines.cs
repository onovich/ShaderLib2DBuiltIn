using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class Volume_ScanLines : VolumeComponent {

    public BoolParameter isEnable = new BoolParameter(false);
    public FloatParameter lineWidth = new FloatParameter(4f);
    public ColorParameter lineColor = new ColorParameter(new Color(1f, 1f, 1f, 0.5f));
    public BoolParameter isAuto = new BoolParameter(false);
    public FloatParameter autoSpeed = new FloatParameter(0.2f);

}