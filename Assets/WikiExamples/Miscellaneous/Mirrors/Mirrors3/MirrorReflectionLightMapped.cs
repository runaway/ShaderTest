using UnityEngine;
using System.Collections;

/// <summary>
/// 这个脚本更多的是处理斜投影矩阵，并且非常和标准资源库里面的ReflectionRenderTexture 
/// 脚本非常相似，在这里去除了ReflectionRenderTexture 脚本的各种混乱的依赖关系
/// </summary>
public class MirrorReflectionLightMapped : MonoBehaviour {

    public int renderTextureSize = 1024;      //渲染到镜子上的贴图尺寸大小
    public float clipPlaneOffset = 0.01f;
    public bool disablePixelLights = true;

    private RenderTexture renderTexture;
    private int restorePixelLightCount;
    private Camera mirrorCamera;                //

    private Camera mainCam;
    // Use this for initialization
    void Start () {

        if(!SystemInfo.supportsRenderTextures)
        {
            Debug.LogError("不能使用RenderTexture！");
            return;
        }
        //初始化RenderTexture
        renderTexture = new RenderTexture(renderTextureSize, renderTextureSize,16);
        //为2的倍数
        renderTexture.isPowerOfTwo = true;

        mirrorCamera = GetComponent<Camera>();
        if (null == mirrorCamera)
        {
            mirrorCamera = gameObject.AddComponent<Camera>();
        }
        mainCam = Camera.main;


        //设置成和主摄像机如下一样的参数
        mirrorCamera.targetTexture = renderTexture;
        mirrorCamera.clearFlags = mainCam.clearFlags;
        mirrorCamera.backgroundColor = mainCam.backgroundColor;
        mirrorCamera.nearClipPlane = mainCam.nearClipPlane;
        mirrorCamera.farClipPlane = mainCam.farClipPlane;
        mirrorCamera.fieldOfView = mainCam.fieldOfView;

        //设置这个材质球里面的_ReflectionTex为此renderTexture
        GetComponent<Renderer>().sharedMaterial.SetTexture("_ReflectionTex", renderTexture);

    }
	void OnDisable()
    {
        Destroy(renderTexture);
    }
	// Update is called once per frame
	void Update () {

        //初始化一个计算矩阵，TRS参数从左到右分别为，位移、旋转和缩放， Quaternion.identity就是不旋转
        Matrix4x4 scaleOffset = Matrix4x4.TRS(new Vector3(0.5f, 0.5f, 0.5f), Quaternion.identity, new Vector3(0.5f, 0.5f, 0.5f));
        //设置该镜像摄像机的投影矩阵，该矩阵和主摄像机的投影矩阵有关
        GetComponent<Renderer>().sharedMaterial.SetMatrix("_ProjMatrix", scaleOffset *mainCam.projectionMatrix * mainCam.worldToCameraMatrix *transform.localToWorldMatrix);

    }
    void LateUpdate()
    {
        //先确认能不能进行反射或者折射
        if(!SystemInfo.supportsRenderTextures)
        {
            mirrorCamera.enabled = false;
        }
        else if(mirrorCamera.targetTexture==null)
        {
            Debug.LogError("镜子没有Render Texture，不能进行反射！");
            mirrorCamera.enabled = false;
        }
        else
        {
            mirrorCamera.enabled = true;
        }
    }
    /// <summary>
    /// 该函数是在摄像机组件上运行，在摄像机剔除屏幕之前运行
    /// 该函数可以决定哪个物体可以被该摄像机可见，因为这个函数可以修改摄像机的可视参数
    /// </summary>
    void OnPreCull()
    {
       if(null!=mirrorCamera)
        {
            //得到镜子的镜面在世界坐标系中的位置和法线
            Vector3 pos = transform.position;
            Vector3 normal = transform.up;

            //在镜子周围反射
            float d = -Vector3.Dot(normal, pos) - clipPlaneOffset;
            Vector4 reflectionPlane = new Vector4(normal.x, normal.y, normal.z, d);

            Matrix4x4 reflection = CalculateReflectionMatrix(reflectionPlane);
            mirrorCamera.worldToCameraMatrix = mainCam.worldToCameraMatrix * reflection;

            Vector4  clipPlane = CameraSpacePlane(pos, normal);
            mirrorCamera.projectionMatrix= CalculateObliqueMatrix(mainCam.projectionMatrix, clipPlane);
        }
       else
        {
            mirrorCamera.ResetProjectionMatrix();
        }
    }
    void OnPreRender()
    {
        //设置背面剔除为true
        GL.invertCulling = true;

        if (disablePixelLights)
        {
            restorePixelLightCount = QualitySettings.pixelLightCount;
            QualitySettings.pixelLightCount = 0;
        }
    }

    /// <summary>
    /// 当该摄像机完成渲染之后执行
    /// </summary>
    void OnPostRender()
    {
        //不进行背面剔除
        GL.invertCulling = false;
        if (disablePixelLights)
        {
            QualitySettings.pixelLightCount = restorePixelLightCount;
        }
    }

    /// <summary>
    /// 给定镜子的位置或者法线向量在摄像机空间进行计算
    /// </summary>
    /// <param name="pos"></param>
    /// <param name="normal"></param>
    /// <returns></returns>
    Vector4 CameraSpacePlane(Vector3 pos, Vector3 normal)
    {
        //计算偏移位置
        Vector3 offsetPos = pos + normal * clipPlaneOffset;
        //得到投影矩阵
        Matrix4x4 m = mirrorCamera.worldToCameraMatrix;
        //计算偏移位置在摄像机空间的位置
        Vector3 cpos = m.MultiplyPoint(offsetPos);
        //计算法线方向在摄像机空间的方向，并归一化
        Vector3 cnormal = m.MultiplyVector(normal).normalized;

        //用一个四维向量来表示，xyz表示方向，w表示位移
        Vector4 v = new Vector4(cnormal.x, cnormal.y, cnormal.z,-Vector3.Dot(cpos,cnormal));
        return v;

    }

    float sgn(float a)
    {
        if(a>0)
        {
            return 1.0f;
        }
        if(a<0)
        {
            return -1.0f;
        }
        return 0;
    }
    /// <summary>
    /// 调整投影矩阵
    /// </summary>
    /// <param name="projection">投影矩阵</param>
    /// <param name="clipPlane">近剪切平面</param>
    /// <returns></returns>
    Matrix4x4 CalculateObliqueMatrix(Matrix4x4 projection,Vector4 clipPlane)
    {
        Vector4 q = new Vector4();
        q.x = (sgn(clipPlane.x) + projection[8]) / projection[0];
        q.y = (sgn(clipPlane.y) + projection[9]) / projection[5];
        q.z = -1.0f;
        q.w = (1.0f + projection[10]) / projection[14];

        Vector4  c = clipPlane * (2.0f / (Vector4.Dot(clipPlane, q)));
        projection[2] = c.x;
        projection[6] = c.y;
        projection[10] = c.z + 1.0f;
        projection[14] = c.w;

        return projection;

    }
    /// <summary>
    /// 通过给定的向量计算反射矩阵
    /// </summary>
    /// <param name="plane"></param>
    /// <returns></returns>
    Matrix4x4 CalculateReflectionMatrix(Vector4 plane)
    {
        Matrix4x4 reflectionMat = new Matrix4x4();

        reflectionMat.m00 = (1 - 2 * plane[0] * plane[0]);
        reflectionMat.m01 = (-2 * plane[0] * plane[1]);
        reflectionMat.m02 = (-2 * plane[0] * plane[2]);
        reflectionMat.m03 = (-2 * plane[3] * plane[0]);

        reflectionMat.m10 = (-2 * plane[1] * plane[0]);
        reflectionMat.m11 = (1 - 2 * plane[1] * plane[1]);
        reflectionMat.m12 = (-2 * plane[1] * plane[2]);
        reflectionMat.m13 = (-2 * plane[3] * plane[1]);

        reflectionMat.m20 = (-2 * plane[2] * plane[0]);
        reflectionMat.m21 = (-2 * plane[2] * plane[1]);
        reflectionMat.m22 = (1 - 2 * plane[2] * plane[2]);
        reflectionMat.m23 = (-2 * plane[3] * plane[2]);

        reflectionMat.m30 = 0;
        reflectionMat.m31 = 0;
        reflectionMat.m32 = 0;
        reflectionMat.m33 = 1;
        return reflectionMat;
    }
}
