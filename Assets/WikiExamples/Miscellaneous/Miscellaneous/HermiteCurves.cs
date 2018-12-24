using UnityEngine;
using System.Collections;

public class HermiteCurves : MonoBehaviour {
    public GameObject start;
    public GameObject startTangentPoint;
    public GameObject end;
    public GameObject endTangentPoint;

    public Color color = Color.white;
    public float width = 0.2f;
    public int numberOfPoints = 20;

    private LineRenderer lineRenderer;
	// Use this for initialization
	void Start () {

        lineRenderer = GetComponent<LineRenderer>();
        if(null==lineRenderer)
        {
            gameObject.AddComponent<LineRenderer>();
        }

        lineRenderer = GetComponent<LineRenderer>();
        lineRenderer.useWorldSpace = true;
        lineRenderer.material = new Material(Shader.Find("Particles/Additive"));
    }

    // Update is called once per frame
    void Update()
    {
        if (null == lineRenderer
      || null == start || null == startTangentPoint
      || null == end || null == endTangentPoint)
        {
            return; // no points specified
        }
        // update line renderer
        lineRenderer.SetColors(color, color);
        lineRenderer.SetWidth(width, width);
        if (numberOfPoints > 0)
        {
            lineRenderer.SetVertexCount(numberOfPoints);
        }

        Vector3 p0 = start.transform.position;
        Vector3 p1 = end.transform.position;

        Vector3 m0 = startTangentPoint.transform.position;
        Vector3 m1 = endTangentPoint.transform.position - end.transform.position;

        float t;
        Vector3 position;

        for (int i = 0; i < numberOfPoints; i++)
        {
            t = i / (numberOfPoints - 1.0f);
            position = (2.0f * t * t * t - 3.0f * t * t + 1.0f) * p0
               + (t * t * t - 2.0f * t * t + t) * m0
               + (-2.0f * t * t * t + 3.0f * t * t) * p1
               + (t * t * t - t * t) * m1;
            lineRenderer.SetPosition(i, position);
        }
    }
}
