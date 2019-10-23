using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DCGUnderWater : MonoBehaviour {

    public GameObject underWaterObj, wetLensObj;
    float curIntensity = 0f;
    public bool changeWaterMaterial = true;

    MeshRenderer wetLensRenderer, underWaterRenderer;
   // bool inWater;

    private void Awake()
    {
        underWaterRenderer = underWaterObj.GetComponent<MeshRenderer>();
        wetLensRenderer = wetLensObj.GetComponent<MeshRenderer>();
        wetLensRenderer.material.SetFloat("_Intensity", curIntensity);
    }

    private void Update()
    {
        if(curIntensity > 0)
        {
            curIntensity -= Time.deltaTime * 0.33f;
            wetLensRenderer.material.SetFloat("_Intensity", curIntensity);
        }
        else
        {
            if (wetLensObj.activeInHierarchy)
            {
                curIntensity = 0;
                wetLensRenderer.material.SetFloat("_Intensity", curIntensity);
                wetLensObj.SetActive(false);
            }
        }
    }

    private void OnTriggerEnter(Collider o)
    {
        if(o.tag == "Water")
        {
            //inWater = true;
            curIntensity = 0;
            wetLensObj.SetActive(false);
            underWaterObj.SetActive(true);
            
            ChangeUnderWaterTint(o.GetComponent<MeshRenderer>());
            if (changeWaterMaterial)
            {
                o.GetComponent<DCGWater>().UpdateWaterMaterial(true);
            }
        }
    }

    private void OnTriggerExit(Collider o)
    {
        if (o.tag == "Water")
        {
            //inWater = false;
            curIntensity = 1;
            wetLensObj.SetActive(true);
            underWaterObj.SetActive(false);
            if (changeWaterMaterial)
            {
                o.GetComponent<DCGWater>().UpdateWaterMaterial(false);
            }
        }
    }
    private void ChangeUnderWaterTint(MeshRenderer currentWater)
    {
        Color filterColor = new Color(1,1,0.95f,1);
        underWaterRenderer.material.SetColor("_Tint", currentWater.material.GetColor("_ScatteringTint") * filterColor);
    }
}
