using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//logcat | grep CppHobot
//logcat | grep HobotProcess
//logcat | grep "Camera ="

//  logcat |grep ARHud
public class DrawLine : MonoBehaviour {

    public Material mat;
    public Color col = Color.red;
    private Vector3 pos1, pos2;
    private bool IsReady = false;
    private ArrayList pointList;
    private ArrayList breakpointList;
    private int index = 0;
    // Use this for initialization
    void Start()
    {
        mat.color = col;
        pointList = new ArrayList();
        breakpointList = new ArrayList();
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {

            if (!IsReady)
            {
                pos1 = Input.mousePosition;
                pointList.Add(pos1);
            }

        }
        if (Input.GetMouseButtonUp(0))
        {
            pos2 = Input.mousePosition;
            IsReady = true;

            pointList.Add(pos2);
        }
        if (Input.GetMouseButtonUp(1))
        {
            breakpointList.Add(pointList.Count - 1);
        }
    }
    void OnPostRender()
    {
        if (IsReady)
        {
            GL.PushMatrix();
            mat.SetPass(0);
            GL.LoadOrtho();
            for (int i = 0; i < pointList.Count - 1; i++)
            {
                for (int j = 0; j < breakpointList.Count; j++)
                {
                    if (i == (int)(breakpointList[j]))
                    {
                        i++;
                    }
                }
                GL.Begin(GL.LINES);
                GL.Color(col);
                GL.Vertex3(((Vector3)pointList[i]).x / Screen.width, ((Vector3)pointList[i]).y / Screen.height, ((Vector3)pointList[i]).z);
                GL.Vertex3(((Vector3)pointList[i + 1]).x / Screen.width, ((Vector3)pointList[i + 1]).y / Screen.height, ((Vector3)pointList[i + 1]).z);
                GL.End();
            }
            GL.PopMatrix();
        }
    }
}
