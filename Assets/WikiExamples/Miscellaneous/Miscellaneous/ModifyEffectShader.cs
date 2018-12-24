using UnityEngine;
using System.Collections;

public class ModifyEffectShader : MonoBehaviour {
    public GameObject otherObj;
	// Use this for initialization
	void Start () {
        if(otherObj != null)
        {
            GetComponent<Renderer>().sharedMaterial.SetVector("_Point", otherObj.transform.position);
        }
	
	}
	
	// Update is called once per frame
	void Update () {
	
	}
}
