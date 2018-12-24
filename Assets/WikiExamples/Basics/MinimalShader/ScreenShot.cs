using UnityEngine;
using System.Collections;

public class ScreenShot : MonoBehaviour {

	// Use this for initialization
	void Start () {
	
	}
	
	// Update is called once per frame
	void Update () {
        if(Input.GetKeyDown(KeyCode.Space))
        {
            ScreenCapture.CaptureScreenshot("Screenshot.png", 4096);
        }
	
	}
}
