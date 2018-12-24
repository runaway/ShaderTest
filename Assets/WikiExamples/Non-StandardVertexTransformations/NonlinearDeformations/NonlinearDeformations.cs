using UnityEngine;
using System.Collections;

[ExecuteInEditMode]
public class NonlinearDeformations : MonoBehaviour
{
    public GameObject bone0;
    public GameObject bone1;

    void Update()
    {
        if (null != bone0)
        {
            GetComponent<Renderer>().sharedMaterial.SetMatrix("_Trafo0",
               bone0.GetComponent<Renderer>().localToWorldMatrix);
        }
        if (null != bone1)
        {
            GetComponent<Renderer>().sharedMaterial.SetMatrix("_Trafo1",
               bone1.GetComponent<Renderer>().localToWorldMatrix);
        }
        if (null != bone0 && null != bone1)
        {
            transform.position = 0.5f * (bone0.transform.position
               + bone1.transform.position);
            transform.rotation = bone0.transform.rotation;
        }
    }
}