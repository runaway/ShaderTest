using UnityEngine;
using System.Collections;
[ExecuteInEditMode]
public class ViewPlane : MonoBehaviour {
    public GameObject mirrorPlane;                      //镜子屏幕

    public bool estimateViewFrustum = true;
    public bool setNearClipPlane = false;               //是否设置近剪切平面

    public float nearClipDistanceOffset = -0.01f;       //近剪切平面的距离

    private Camera mirrorCamera;                        //镜像摄像机
    // Use this for initialization
    void Start () {
        mirrorCamera = GetComponent<Camera>();
	
	}
	
	// Update is called once per frame
	void Update () {

        if (null != mirrorPlane && null != mirrorCamera)
        {
            //世界坐标系的左下角
            Vector3 pa = mirrorPlane.transform.TransformPoint(new Vector3(-5.0f, 0.0f, -5.0f));

            //世界坐标系的右下角
            Vector3 pb = mirrorPlane.transform.TransformPoint(new Vector3(5.0f, 0.0f, -5.0f));

            //世界坐标系的左上角
            Vector3 pc = mirrorPlane.transform.TransformPoint(new Vector3(-5.0f, 0.0f, 5.0f));

            //镜像观察角度的世界坐标位置
            Vector3 pe = transform.position;

            //镜像摄像机的近剪切面的距离
            float n = mirrorCamera.nearClipPlane;

            //镜像摄像机的远剪切面的距离
            float f = mirrorCamera.farClipPlane;

            //从镜像摄像机到左下角
            Vector3 va = pa - pe;

            //从镜像摄像机到右下角
            Vector3 vb = pb - pe;

            //从镜像摄像机到左上角
            Vector3 vc = pc - pe;

            //屏幕的右侧旋转轴
            Vector3 vr = pb - pa;

            //屏幕的上侧旋转轴
            Vector3 vu = pc - pa;

            //屏幕的法线
            Vector3 vn;

            //到屏幕左边缘的距离
            float l;

            //到屏幕右边缘的距离
            float r;

            //到屏幕下边缘的距离
            float b;

            //到屏幕上边缘的距离
            float t;

            //从镜像摄像机到屏幕的距离
            float d;

            //如果看向镜子的背面
            if (Vector3.Dot(-Vector3.Cross(va, vc), vb) < 0.0f)
            {
                //
                vu = -vu;
                pa = pc;
                pb = pa + vr;
                pc = pa + vu;
                va = pa - pe;
                vb = pb - pe;
                vc = pc - pe;
            }

            vr.Normalize();
            vu.Normalize();

            //两个向量的叉乘，最后在取负，因为Unity是使用左手坐标系
            vn = -Vector3.Cross(vr, vu);

            vn.Normalize();

            d = -Vector3.Dot(va, vn);
            if (setNearClipPlane)
            {
                n = d + nearClipDistanceOffset;
                mirrorCamera.nearClipPlane = n;
            }
            l = Vector3.Dot(vr, va) * n / d;
            r = Vector3.Dot(vr, vb) * n / d;
            b = Vector3.Dot(vu, va) * n / d;
            t = Vector3.Dot(vu, vc) * n / d;

            //投影矩阵
            Matrix4x4 p = new Matrix4x4();
            p[0, 0] = 2.0f * n / (r - l);
            p[0, 1] = 0.0f;
            p[0, 2] = (r + l) / (r - l);
            p[0, 3] = 0.0f;

            p[1, 0] = 0.0f;
            p[1, 1] = 2.0f * n / (t - b);
            p[1, 2] = (t + b) / (t - b);
            p[1, 3] = 0.0f;

            p[2, 0] = 0.0f;
            p[2, 1] = 0.0f;
            p[2, 2] = (f + n) / (n - f);
            p[2, 3] = 2.0f * f * n / (n - f);

            p[3, 0] = 0.0f;
            p[3, 1] = 0.0f;
            p[3, 2] = -1.0f;
            p[3, 3] = 0.0f;

            //旋转矩阵
            Matrix4x4 rm = new Matrix4x4();
            rm[0, 0] = vr.x;
            rm[0, 1] = vr.y;
            rm[0, 2] = vr.z;
            rm[0, 3] = 0.0f;

            rm[1, 0] = vu.x;
            rm[1, 1] = vu.y;
            rm[1, 2] = vu.z;
            rm[1, 3] = 0.0f;

            rm[2, 0] = vn.x;
            rm[2, 1] = vn.y;
            rm[2, 2] = vn.z;
            rm[2, 3] = 0.0f;

            rm[3, 0] = 0.0f;
            rm[3, 1] = 0.0f;
            rm[3, 2] = 0.0f;
            rm[3, 3] = 1.0f;

            Matrix4x4 tm = new Matrix4x4();
            tm[0, 0] = 1.0f;
            tm[0, 1] = 0.0f;
            tm[0, 2] = 0.0f;
            tm[0, 3] = -pe.x;

            tm[1, 0] = 0.0f;
            tm[1, 1] = 1.0f;
            tm[1, 2] = 0.0f;
            tm[1, 3] = -pe.y;

            tm[2, 0] = 0.0f;
            tm[2, 1] = 0.0f;
            tm[2, 2] = 1.0f;
            tm[2, 3] = -pe.z;

            tm[3, 0] = 0.0f;
            tm[3, 1] = 0.0f;
            tm[3, 2] = 0.0f;
            tm[3, 3] = 1.0f;

            //矩阵组
            //
            mirrorCamera.projectionMatrix = p;
            mirrorCamera.worldToCameraMatrix = rm * tm;


            if (estimateViewFrustum)
            {
                //旋转摄像机
                Quaternion q = new Quaternion();
                q.SetLookRotation((0.5f * (pb + pc) - pe), vu);
                //聚焦到屏幕的中心点
                mirrorCamera.transform.rotation = q;

                //保守估计fieldOfView的值
                if (mirrorCamera.aspect >= 1.0)
                {
                    mirrorCamera.fieldOfView = Mathf.Rad2Deg *
                       Mathf.Atan(((pb - pa).magnitude + (pc - pa).magnitude)
                       / va.magnitude);
                }
                else
                {
                    //在摄像机角度考虑，保证视锥足够宽
                    mirrorCamera.fieldOfView =
                       Mathf.Rad2Deg / mirrorCamera.aspect *
                       Mathf.Atan(((pb - pa).magnitude + (pc - pa).magnitude)
                       / va.magnitude);
                }
            }
        }
	}
}
