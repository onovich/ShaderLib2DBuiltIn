using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

public class Volume_Blur : VolumeComponent {

    public BoolParameter isEnable = new BoolParameter(false);
    public FloatParameter blurSize = new FloatParameter(1.0f);

}