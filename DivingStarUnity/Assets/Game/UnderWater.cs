using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UnderWater : MonoBehaviour
{
	[SerializeField] List<GameObject> Fishes;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

	public void Setup(){

		float y = -2f;

		while(true){
			float addY = UnityEngine.Random.Range(10f, 15f);
			y -= addY;

			var prefab = Fishes[Random.Range(0, Fishes.Count)];
			var fish = Instantiate(prefab, this.transform);
			fish.SetActive(true);

			var x = Random.Range(-10f, 10f);
			var z = Random.Range(-10f, 10f);
			var rotateY = Random.Range(0f, 360f);

			fish.transform.position = new Vector3(x, y, z);
			fish.transform.eulerAngles = new Vector3(0f, rotateY, 0f);

			if (y < -400f) break;
		}
	}
}
