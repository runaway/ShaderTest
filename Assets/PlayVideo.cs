using System.Collections;
using System.Collections.Generic;
using UnityEngine;



public class PlayVideo : MonoBehaviour {

    //电影纹理
    public MovieTexture movTexture;

    // Use this for initialization
    void Start () {

        ((MovieTexture)GetComponent<Renderer>().material.mainTexture).Play();


    }



    // Update is called once per frame
    void Update () {

    }
}
