using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class ShadowsPlane : MonoBehaviour {

    public GameObject plane;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
        if (null != plane)
        {
            GetComponent<Renderer>().sharedMaterial.SetMatrix("_World2Receiver",
             plane.GetComponent<Renderer>().worldToLocalMatrix);
        }

    }
}
