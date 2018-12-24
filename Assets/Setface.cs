using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Setface : MonoBehaviour {

    public Material mat;
    public ComputeShader shader;

    // Use this for initialization
    void Start ()
    {
        RunShader();
    }

    void RunShader()
    {
        ////////////////////////////////////////
        //    RenderTexture
        ////////////////////////////////////////
        //1 新建RenderTexture
        RenderTexture tex = new RenderTexture(256, 256, 32); // 24
        //2 开启随机写入
        tex.enableRandomWrite = true;
        //3 创建RenderTexture
        tex.Create();
        //4 赋予材质
        mat.mainTexture = tex;
        ////////////////////////////////////////
        //    Compute Shader
        ////////////////////////////////////////
        //1 找到compute shader中所要使用的KernelID
        int k = shader.FindKernel("CSMain");
        //2 设置贴图    参数1=kid  参数2=shader中对应的buffer名 参数3=对应的texture, 如果要写入贴图，贴图必须是RenderTexture并enableRandomWrite
        shader.SetTexture(k, "Result", tex);
        //shader.SetTexture(0, "Result", tex);
        //3 运行shader  参数1=kid  参数2=线程组在x维度的数量 参数3=线程组在y维度的数量 参数4=线程组在z维度的数量
        shader.Dispatch(k, 256 / 8, 256 / 8, 1);
        //shader.Dispatch(0, 256 / 8, 256 / 8, 1);
    }

    // Update is called once per frame
    void Update ()
    {
        //RunShader();
    }
}
