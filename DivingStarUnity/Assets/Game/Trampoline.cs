using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Trampoline : MonoBehaviour
{
	public GameComtroller game;

	public float SpringRate = 40000f;
	public float ResistanceRate = 10f;

	public bool JumpBoost;
	bool slow;

	Rigidbody rBody;

    // Start is called before the first frame update
    void Start()
    {
		rBody = GetComponent<Rigidbody>();
    }

	// Update is called once per frame
	void Update(){

	}

	public void Reset()
	{
		JumpBoost = false;
		slow = false;
	}

	private void FixedUpdate()
	{
		// spring
		var springForce = Vector3.down * this.transform.localPosition.y * SpringRate;
		var resistanceForce = Vector3.down * rBody.velocity.y * ResistanceRate;
		//Debug.Log("y="+this.transform.localPosition.y+" velocity="+rBody.velocity+" sprint="+springForce+" resistance="+resistanceForce);

		if(JumpBoost && rBody.velocity.y > 0f){
			springForce *= 9.5f;
		}

		if(JumpBoost && !slow) {
			if(Time.timeScale < 1f){
				Time.timeScale = 1f;
				slow = true;
				game.ToJump();
			} else if(this.transform.localPosition.y < -0.004f && rBody.velocity.y > -1.2f) {
				Debug.Log("TimeScale = 0.1f velocity = "+rBody.velocity.y+" trans="+this.transform.localPosition.y);
				Time.timeScale = 0.05f;
			}
		}

		rBody.AddForce(springForce + resistanceForce);

		//if (this.transform.localPosition.y < 0f) {
		//	rBody.AddForce(Vector3.up * Mathf.Abs(this.transform.localPosition.y) * 20000f);
		//} else if (this.transform.localPosition.y > 0f && rBody.velocity.y > 0f) {
		//	rBody.AddForce(Vector3.down * Mathf.Abs(this.transform.localPosition.y) * 200000f);
		//}

	}

}
