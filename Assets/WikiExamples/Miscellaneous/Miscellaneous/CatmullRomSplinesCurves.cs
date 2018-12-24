using UnityEngine;
using System.Collections;

public class CatmullRomSplinesCurves : MonoBehaviour {

    public GameObject[] controlPoints;
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
        if (null == lineRenderer || controlPoints == null
      || controlPoints.Length < 2)
        {
            return; // not enough points specified
        }

        // update line renderer
        lineRenderer.SetColors(color, color);
        lineRenderer.SetWidth(width, width);
        if (numberOfPoints < 2)
        {
            numberOfPoints = 2;
        }
        lineRenderer.SetVertexCount(numberOfPoints *
           (controlPoints.Length - 1));

        Vector3 p0;
        Vector3 p1;
        Vector3 m0;
        Vector3 m1;

        for (int j = 0; j < controlPoints.Length - 1; j++)
        {
            // check control points
            if (controlPoints[j] == null ||
               controlPoints[j + 1] == null ||
               (j > 0 && controlPoints[j - 1] == null) ||
               (j < controlPoints.Length - 2 &&
               controlPoints[j + 2] == null))
            {
                return;
            }
            // determine control points of segment
            p0 = controlPoints[j].transform.position;
            p1 = controlPoints[j + 1].transform.position;
            if (j > 0)
            {
                m0 = 0.5f * (controlPoints[j + 1].transform.position
                - controlPoints[j - 1].transform.position);
            }
            else
            {
                m0 = controlPoints[j + 1].transform.position
                - controlPoints[j].transform.position;
            }
            if (j < controlPoints.Length - 2)
            {
                m1 = 0.5f * (controlPoints[j + 2].transform.position
                - controlPoints[j].transform.position);
            }
            else
            {
                m1 = controlPoints[j + 1].transform.position
                - controlPoints[j].transform.position;
            }
            Vector3 position;
            float t;
            float pointStep = 1.0f / numberOfPoints;
            if (j == controlPoints.Length - 2)
            {
                pointStep = 1.0f / (numberOfPoints - 1.0f);
                // last point of last segment should reach p1
            }
            for (int i = 0; i < numberOfPoints; i++)
            {
                t = i * pointStep;
                position = (2.0f * t * t * t - 3.0f * t * t + 1.0f) * p0
                   + (t * t * t - 2.0f * t * t + t) * m0
                   + (-2.0f * t * t * t + 3.0f * t * t) * p1
                   + (t * t * t - t * t) * m1;
                lineRenderer.SetPosition(i + j * numberOfPoints,
                   position);
            }
        }
    }
}
