using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class SoftShadowsofSpheres : MonoBehaviour {

    public GameObject occluder;
	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
        if(null!=occluder)
        {
            occluder.GetComponent<Renderer>().sharedMaterial.SetVector("_SpherePosition",occluder.transform.position);
            occluder.GetComponent<Renderer>().sharedMaterial.SetFloat("_SpherePosition", occluder.transform.localScale.x / 2.0f);
        }
	
	}
}
