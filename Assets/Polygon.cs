using UnityEngine;  
using System.Collections;  
[ExecuteInEditMode]   
public class Polygon : MonoBehaviour {  
  
    public Material mat; //�󶨲���  
    Vector3[] worldPos; //�洢��ȡ��3D����  
    Vector4[] screenPos; //�洢�����ƵĶ���ζ�����Ļ����  
    int maxPointNum=6;  //����ζ�������  
    int currentpointNum =0; //��ǰ�Ѿ���õĶ�����  
    int pointNum2Shader =0; //���ݶ���������shader  
    bool InSelection=true; //�Ƿ��ڶ����ȡ����  
  
    void Start () {  
        worldPos = new Vector3[maxPointNum];  
        screenPos = new Vector4[maxPointNum];  
    }  
      
  
    void Update () {  
        mat.SetVectorArray("Value",screenPos); //���ݶ�����Ļλ����Ϣ��shader  
        mat.SetInt ("PointNum",pointNum2Shader); //���ݶ���������shader  
  
        //ʹ�����������һ�����ߣ��Ի�ȡҪѡ���3Dλ��  
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);    
        RaycastHit hit;    
        if (Physics.Raycast(ray, out hit, 100))    
        {    
            Debug.DrawLine(ray.origin, hit.point);                         
        }    
  
        //�������������ȡλ����Ϣ  
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
  
        //ʵʱ������ѡ���3D�����Ļλ��  
        for (int i = 0; i < maxPointNum; i++)   
        {  
            Vector3 v3 = Camera.main.WorldToScreenPoint (worldPos[i]);  
            screenPos[i] = new Vector4(v3.x,Screen.height-v3.y,v3.z,0);  
  
        }  
  
        //����Ƿ���3D���ƶ�������������棬����У���ֹͣ����  
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
  
    //ץȡ��ǰ����Ⱦͼ����д���  
    void OnRenderImage(RenderTexture src, RenderTexture dest) {    
        Graphics.Blit(src, dest, mat);    
    }         
}  