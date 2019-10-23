using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class JumpGauge : MonoBehaviour
{
	public Image MaxGauge;
	public Image PowerGauge;

	// Start is called before the first frame update
	void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

	public void SetMaxPower(float rate){
		MaxGauge.rectTransform.sizeDelta = new Vector2(26f, 238f * rate);
	}

	public void SetPower(float rate){
		PowerGauge.fillAmount = rate;
	}
}
