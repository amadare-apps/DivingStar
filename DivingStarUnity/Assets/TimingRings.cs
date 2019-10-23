using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TimingRings : MonoBehaviour
{
	public DrawCircle MoveRing;
	public List<DrawCircle> Rings;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

	public void SetRadius(float radius)
	{
		MoveRing.ChangeRadius(radius);
		foreach(var circle in Rings){
			if(circle.radius > radius){
				circle.HideStart();
			}
		}
	}

	public void HideAll(){
		this.gameObject.SetActive(false);
	}

	public void ShowAll()
	{
		this.gameObject.SetActive(true);
		foreach (var circle in Rings) {
			circle.Show();
		}
	}
}
