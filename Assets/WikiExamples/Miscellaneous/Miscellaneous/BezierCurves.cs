using UnityEngine;
using System.Collections;
public class BezierCurves : MonoBehaviour {
    public GameObject start;
    public GameObject middle;
    public GameObject end;

    public Color color = Color.white;
    public float width = 0.2f;
    public int numberOfPoints = 20;

	// Use this for initialization
	void Start () {
        LineRenderer lineRenderer = GetComponent<LineRenderer>();
        lineRenderer.useWorldSpace = true;
        lineRenderer.material = new Material(Shader.Find("Particles/Additive"));
	
	}
	
	// Update is called once per frame
	void Update () {
        LineRenderer lineRenderer = GetComponent<LineRenderer>();
        if(null==lineRenderer||null==start||null==middle||null==end)
        {
            return;
        }

        lineRenderer.SetColors(color, color);
        lineRenderer.SetWidth(width, width);
        if(numberOfPoints>0)
        {
            lineRenderer.SetVertexCount(numberOfPoints);
        }

        Vector3 p0 = start.transform.position;
        Vector3 p1 = middle.transform.position;
        Vector3 p2 = end.transform.position;

        float t;
        Vector3 position ;
        for (int i = 0; i < numberOfPoints; i++)
        {
            t = i / (numberOfPoints - 1.0f);
            //贝塞尔二次曲线方程：B(t)=(1-t)^2*P_0+2(1-t)t*P_1+t^2*P_2
            position = (1.0f - t) * (1.0f - t) * p0
        + 2.0f * (1.0f - t) * t * p1
        + t * t * p2;
            lineRenderer.SetPosition(i, position);
        }
	
	}
}
