using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AccelRing : MonoBehaviour
{
	public Material DefaultMaterial;
	public Material SuccessMaterial;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

	public void SetToDefault(){
		GetComponent<Renderer>().sharedMaterial = DefaultMaterial;
	}

	public void SetToSuccess(){
		GetComponent<Renderer>().sharedMaterial = SuccessMaterial;
	}
}
