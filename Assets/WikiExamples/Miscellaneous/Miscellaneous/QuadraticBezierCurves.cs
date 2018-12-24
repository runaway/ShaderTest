using UnityEngine;
using System.Collections;

public class QuadraticBezierCurves : MonoBehaviour {

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
     || controlPoints.Length < 3)
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
           (controlPoints.Length - 2));

        Vector3 p0;
        Vector3 p1;
        Vector3 p2;

        for (int j = 0; j < controlPoints.Length - 2; j++)
        {
            // check control points
            if (controlPoints[j] == null ||
               controlPoints[j + 1] == null ||
               controlPoints[j + 2] == null)
            {
                return;
            }
            // determine control points of segment
            p0 = 0.5f * (controlPoints[j].transform.position
               + controlPoints[j + 1].transform.position);
            p1 = controlPoints[j + 1].transform.position;
            p2 = 0.5f * (controlPoints[j + 1].transform.position
               + controlPoints[j + 2].transform.position);

            // set points of quadratic Bezier curve
            Vector3 position;
            float t;
            float pointStep = 1.0f / numberOfPoints;
            if (j == controlPoints.Length - 3)
            {
                pointStep = 1.0f / (numberOfPoints - 1.0f);
                // last point of last segment should reach p2
            }
            for (int i = 0; i < numberOfPoints; i++)
            {
                t = i * pointStep;
                position = (1.0f - t) * (1.0f - t) * p0
                   + 2.0f * (1.0f - t) * t * p1
                   + t * t * p2;
                lineRenderer.SetPosition(i + j * numberOfPoints,
                   position);
            }
        }
    }
    public void Test()
    {
        
    }
}
