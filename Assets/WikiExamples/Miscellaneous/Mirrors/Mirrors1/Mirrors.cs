using UnityEngine;
using System.Collections;
//[ExecuteInEditMode]
public class Mirrors : MonoBehaviour {

    public GameObject realObj;
    public GameObject mirrorPlane;
    public GameObject virturlObj;
    // Use this for initialization
    void Start () {
      //  realObj.GetComponent<Renderer>().material.SetColor("_Color", Color.red);//注意material和sharedMaterial的区别
       


    }
	
	// Update is called once per frame
	void Update () {
        if(null!=mirrorPlane)
        {
            //这句话决定了镜子里的物体是否看见
            virturlObj.GetComponent<Renderer>().sharedMaterial.SetMatrix("_WorldToMirror", mirrorPlane.GetComponent<Renderer>().worldToLocalMatrix);
            //下面一段代码决定了虚物体会跟着实物体动，而且不会改变虚实之间的位置和方向关系
            if(null!=realObj)
            {
                //将实物的颜色值赋给镜中的物体
                Color realColor = realObj.GetComponent<Renderer>().material.GetColor("_Color");
                virturlObj.GetComponent<Renderer>().material.SetColor("_Color", realColor);

                virturlObj.transform.position = realObj.transform.position;
                virturlObj.transform.rotation = realObj.transform.rotation;
                virturlObj.transform.localScale = -realObj.transform.localScale;
                //new Vector3(0.0f, 1.0f, 0.0f)为表面的法线方向,在这绕着镜子表面法向量旋转180度
                virturlObj.transform.RotateAround(realObj.transform.position, mirrorPlane.transform.TransformDirection(new Vector3(0.0f, 1.0f, 0.0f)), 180.0f);
                Vector3 positionInMirrorSpace =mirrorPlane.transform.InverseTransformPoint(realObj.transform.position);
                positionInMirrorSpace.y = -positionInMirrorSpace.y;
                virturlObj.transform.position = mirrorPlane.transform.TransformPoint(positionInMirrorSpace);
            }
        }
	
	}
}
