using UnityEngine;  
using System.Collections;  
[ExecuteInEditMode]   
public class Polygon : MonoBehaviour {  
  
    public Material mat; //绑定材质  
    Vector3[] worldPos; //存储获取的3D坐标  
    Vector4[] screenPos; //存储待绘制的多边形顶点屏幕坐标  
    int maxPointNum=6;  //多边形顶点总数  
    int currentpointNum =0; //当前已经获得的顶点数  
    int pointNum2Shader =0; //传递顶点数量给shader  
    bool InSelection=true; //是否处于顶点获取过程  
  
    void Start () {  
        worldPos = new Vector3[maxPointNum];  
        screenPos = new Vector4[maxPointNum];  
    }  
      
  
    void Update () {  
        mat.SetVectorArray("Value",screenPos); //传递顶点屏幕位置信息给shader  
        mat.SetInt ("PointNum",pointNum2Shader); //传递顶点数量给shader  
  
        //使用摄像机发射一条射线，以获取要选择的3D位置  
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);    
        RaycastHit hit;    
        if (Physics.Raycast(ray, out hit, 100))    
        {    
            Debug.DrawLine(ray.origin, hit.point);                         
        }    
  
        //利用鼠标点击来获取位置信息  
        if (Input.GetMouseButtonDown (0)&& InSelection)   
        {  
            if (currentpointNum < maxPointNum)   
            {  
                currentpointNum++;  
                pointNum2Shader++;  
                worldPos[currentpointNum-1] = hit.point;  
                Vector3 v3 = Camera.main.WorldToScreenPoint (worldPos [currentpointNum-1]);  
                screenPos[currentpointNum-1] = new Vector4(v3.x,Screen.height-v3.y,v3.z,0);  
            }   
            else   
            {  
                InSelection = false;  
            }  
        }  
  
        //实时更新已选择的3D点的屏幕位置  
        for (int i = 0; i < maxPointNum; i++)   
        {  
            Vector3 v3 = Camera.main.WorldToScreenPoint (worldPos[i]);  
            screenPos[i] = new Vector4(v3.x,Screen.height-v3.y,v3.z,0);  
  
        }  
  
        //检测是否有3D点移动到了摄像机后面，如果有，则停止绘制  
        for (int i = 0; i < currentpointNum; i++)   
        {  
            if (Vector3.Dot(worldPos[i]- Camera.main.transform.position,Camera.main.transform.forward)<=0)   
            {  
                pointNum2Shader=0;  
                break;  
            }  
            pointNum2Shader= currentpointNum;  
        }  
    }  
  
    //抓取当前的渲染图像进行处理  
    void OnRenderImage(RenderTexture src, RenderTexture dest) {    
        Graphics.Blit(src, dest, mat);    
    }         
}  