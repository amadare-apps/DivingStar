using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Trampoline : MonoBehaviour
{
	public float SpringRate = 0.1f;
	public float ResistanceRate = 0.02f;

	Rigidbody rBody;

    // Start is called before the first frame update
    void Start()
    {
		rBody = GetComponent<Rigidbody>();
    }

	// Update is called once per frame
	void Update(){

	}

	private void FixedUpdate()
	{
		// spring
		var springForce = Vector3.down * this.transform.localPosition.y * SpringRate;
		var resistanceForce = Vector3.down * rBody.velocity.y * ResistanceRate;
		//Debug.Log("y="+this.transform.localPosition.y+" velocity="+rBody.velocity+" sprint="+springForce+" resistance="+resistanceForce);

		rBody.AddForce(springForce + resistanceForce);

		//if (this.transform.localPosition.y < 0f) {
		//	rBody.AddForce(Vector3.up * Mathf.Abs(this.transform.localPosition.y) * 20000f);
		//} else if (this.transform.localPosition.y > 0f && rBody.velocity.y > 0f) {
		//	rBody.AddForce(Vector3.down * Mathf.Abs(this.transform.localPosition.y) * 200000f);
		//}

	}

}
