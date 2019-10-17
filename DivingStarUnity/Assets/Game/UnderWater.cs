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

			//var x = Random.Range(-10f, 10f);
			//var z = Random.Range(-10f, 10f);
			var rotateY = Random.Range(0f, 360f);

			//fish.transform.position = new Vector3(x, y, z);
			//if (Random.Range(0, 1) == 0) {
			//	fish.transform.LookAt(new Vector3(fish.transform.position.x, 0f, fish.transform.position.z) * 2f);
			//}else{
			//	fish.transform.LookAt(new Vector3(fish.transform.position.x, 0f, fish.transform.position.z) * -1f);
			//}
			//fish.transform.eulerAngles = new Vector3(-30f, fish.transform.eulerAngles.y, 0f);
			//fish.transform.eulerAngles = new Vector3(-25f, rotateY, 0f);

			fish.transform.eulerAngles = new Vector3(-30f, rotateY, 0f);
			fish.transform.position = Vector3.up * y + (Random.Range(0, 1) == 1 ? 1 : -1) * fish.transform.forward * Random.Range(8f, 12f);

			if (y < -400f) break;
		}
	}
}
