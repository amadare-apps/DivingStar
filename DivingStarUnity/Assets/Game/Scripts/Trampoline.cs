using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Trampoline : MonoBehaviour
{
	enum State{
		Idle,
		Charge,
		Jump,
	}
	State state;
	float timeSinceStateChanged;

	public GameComtroller game;

	public float SpringRate = 40000f;
	public float ResistanceRate = 10f;
	public float SpringForceRate = 9.5f;

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
		ChangeState(State.Idle);
	}

	void ChangeState(State state)
	{
		Debug.Log("Tram.ChangeState() "+this.state+" to "+state);
		timeSinceStateChanged = 0f;
		this.state = state;
	}

	public void ToCharge(){
		ChangeState(State.Charge);

		rBody.velocity = Vector3.zero;
		rBody.useGravity = false;
	}

	public void ToJump(){
		ChangeState(State.Jump);

		rBody.useGravity = true;
	}

	private void FixedUpdate()
	{
		if (state == State.Idle) {

			// spring
			var springForce = Vector3.down * this.transform.localPosition.y * SpringRate;
			var resistanceForce = Vector3.down * rBody.velocity.y * ResistanceRate;
			//Debug.Log("y="+this.transform.localPosition.y+" velocity="+rBody.velocity+" sprint="+springForce+" resistance="+resistanceForce);

			//if (JumpBoost && rBody.velocity.y > 0f) {
			//	springForce *= SpringForceRate;
			//}

			rBody.AddForce(springForce + resistanceForce);

			//if (state == State.PreCharge) {
			//	Debug.Log("TimeScale = 0.1f velocity = " + rBody.velocity.y + " trans=" + this.transform.localPosition.y);
			//	if (this.transform.localPosition.y < -0.003f && rBody.velocity.y > -1.0f) {
			//		ChangeState(State.Charge);
			//		rBody.velocity = Vector3.zero;
			//		//HyperCasualGames.VibrationController.Triple();
			//	}
			//}


			//if (this.transform.localPosition.y < 0f) {
			//	rBody.AddForce(Vector3.up * Mathf.Abs(this.transform.localPosition.y) * 20000f);
			//} else if (this.transform.localPosition.y > 0f && rBody.velocity.y > 0f) {
			//	rBody.AddForce(Vector3.down * Mathf.Abs(this.transform.localPosition.y) * 200000f);
			//}

		}else if(state == State.Charge){

			rBody.velocity = Vector3.zero;

		}else if(state == State.Jump){

			var springForce = Vector3.down * this.transform.localPosition.y * SpringRate;
			var resistanceForce = Vector3.down * rBody.velocity.y * ResistanceRate;
			//Debug.Log("y="+this.transform.localPosition.y+" velocity="+rBody.velocity+" sprint="+springForce+" resistance="+resistanceForce);

			springForce *= SpringForceRate;

			rBody.AddForce(springForce + resistanceForce);
		}

		this.velocity = rBody.velocity.y;
	}
	public float velocity;

}
