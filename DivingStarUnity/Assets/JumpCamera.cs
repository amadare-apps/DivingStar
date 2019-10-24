using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class JumpCamera : MonoBehaviour
{
	enum State
	{
		Idle,
		Charge,
		Jump,
		Round,
		Descent,
		Diving,
		Finish,
		Crash,
		Drown,//溺れる
	}
	[SerializeField] State state;
	float timeSinceStateChanged;
	//Vector3 posAtStageChanged;
	Vector3 posDeltaAtStateChanged;//between jumper

	public ParticleSystem SyuTyuSen;


	Jumper jumper;
	Rigidbody jumperBody;
	Rigidbody cameraBody;

	public void Setup(Jumper jumper)
    {
		this.jumper = jumper;
		this.jumperBody = jumper.GetComponent<Rigidbody>();
		this.cameraBody = this.GetComponent<Rigidbody>();
		this.SyuTyuSen.Stop();
    }

	void ChangeState(State state){
		Debug.Log("Camera.ChangeState() " + this.state + " to " + state + " pos="+this.transform.position);
		timeSinceStateChanged = 0f;
		//posAtStageChanged = this.transform.position;
		posDeltaAtStateChanged =  this.transform.position - jumper.transform.position;
		this.state = state;
	}

	public void ToCharge(){
		Debug.Log("Camera.ToCharge before="+this.transform.position);
		//cameraBody.isKinematic = true;
		//cameraBody.useGravity = false;
		GameObject.Destroy(GetComponent<SpringJoint>());
		GameObject.Destroy(cameraBody);

		ChangeState(State.Charge);
		Debug.Log("Camera.ToCharge after=" + this.transform.position);
	}

	public void ToJump()
	{
		////cameraBody.velocity = Vector3.zero;
		////cameraBody.angularVelocity = Vector3.zero;
		//var constraints = cameraBody.constraints;
		//constraints |= RigidbodyConstraints.FreezePositionY;
		//constraints |= RigidbodyConstraints.FreezeRotationX;

		ChangeState(State.Jump);
	}


	public void ToRound(){
		ChangeState(State.Round);
	}

	public void ToDescent(){
		ChangeState(State.Descent);
		this.SyuTyuSen.Play();
	}

	public void ToDiving(){
		ChangeState(State.Diving);
	}

	public void ToDrown(){
		ChangeState(State.Drown);
	}


	private void FixedUpdate()
	{
		timeSinceStateChanged += Time.fixedDeltaTime;

		if(state == State.Idle){

			this.transform.LookAt(jumper.transform.position, this.transform.up);

		} else if(state == State.Charge){

			float t = timeSinceStateChanged > 0.5f ? 1f : timeSinceStateChanged / 0.5f;

			var toDiff = new Vector3(0f, 5.5f, -9.0f);
			toDiff = Vector3.Lerp(posDeltaAtStateChanged, toDiff, t);

			this.transform.position = jumper.transform.position + toDiff;
			this.transform.LookAt(jumper.transform.position, this.transform.up);
			Debug.Log("Camera.State.Charge lerp to=" + toDiff + " (at="+posDeltaAtStateChanged+")");

		} else if(state == State.Jump){

			float lerpTime = 1.0f;

			if (timeSinceStateChanged < lerpTime) {

				float t = timeSinceStateChanged > lerpTime ? 1f : timeSinceStateChanged / lerpTime;

				var toDiff = new Vector3(0f, -jumperBody.velocity.y * 0.2f, -8f);
				toDiff = Vector3.Lerp(posDeltaAtStateChanged, toDiff, t);
				//if (toDiff.y < - 20f) toDiff.y = - 20f;

				this.transform.position = jumper.transform.position + toDiff;
				Debug.Log("Camera.State.Jump lerp to="+ toDiff);

			} else {

				var toDiff = new Vector3(0f, -jumperBody.velocity.y * 0.2f, -8f);
				if (toDiff.y < - 15f) toDiff.y = - 15f;

				this.transform.position = jumper.transform.position + toDiff;
				Debug.Log("Camera.State.Jump to=" + toDiff);
			}

			this.transform.LookAt(jumper.transform.position, this.transform.up);

		}else if(state == State.Round){

			float t = timeSinceStateChanged > 1.8f ? 1f : timeSinceStateChanged / 1.8f;

			var toDiff = new Vector3(0f, 4f, 0f);
			toDiff = Vector3.Lerp(posDeltaAtStateChanged, toDiff, t);

			this.transform.position = jumper.transform.position + toDiff;
			this.transform.LookAt(jumper.transform.position, this.transform.up);
			Debug.Log("Camera.State.Round lerp to=" + toDiff + " (at=" + posDeltaAtStateChanged + ")");

		} else if(state == State.Descent){

			float t = timeSinceStateChanged > 1f ? 1f : timeSinceStateChanged / 1f;

			var toDiff = new Vector3(0f, 3f - jumperBody.velocity.y * 0.05f, 0f);
			toDiff = Vector3.Lerp(posDeltaAtStateChanged, toDiff, t);
			if (toDiff.y < 4f) toDiff.y = 4f;
			if (toDiff.y > 8f) toDiff.y = 8f;

			this.transform.position = jumper.transform.position + toDiff;
			this.transform.LookAt(jumper.transform.position, this.transform.up);
			Debug.Log("Camera.State.Descent lerp to=" + toDiff + " (at=" + posDeltaAtStateChanged + ")  vel=" + jumperBody.velocity.y);

		} else if(state == State.Diving){

			float t = timeSinceStateChanged > 1f ? 1f : timeSinceStateChanged / 1f;

			var toDiff = new Vector3(0f, 4f - jumperBody.velocity.y * 0.1f, 1f);
			toDiff = Vector3.Lerp(posDeltaAtStateChanged, toDiff, t);
			if (toDiff.y < 6f) toDiff.y = 6f;
			if (toDiff.y > 8f) toDiff.y = 8f;

			this.transform.position = jumper.transform.position + toDiff;
			this.transform.LookAt(jumper.transform.position, this.transform.up);
			Debug.Log("Camera.State.Diving lerp to=" + toDiff + " (at=" + posDeltaAtStateChanged + ")  vel=" + jumperBody.velocity.y);

		} else if(state == State.Drown){


		}


		// effect
		if(state == State.Descent){

			// 40~60
			var rate = jumperBody.velocity.y > -40f ? 0f : (-jumperBody.velocity.y+40f / 20f);
			if (rate > 1f) rate = 1f;

			var emission = SyuTyuSen.emission;
			emission.rateOverTime = 200f * rate;

		} else if(state == State.Diving){

			// 10~15
			var rate = jumperBody.velocity.y > -10f ? 0f : (-jumperBody.velocity.y+10f / 5f);
			if (rate > 1f) rate = 1f;

			var emission = SyuTyuSen.emission;
			emission.rateOverTime = 200f * rate;

		}else{
			var emission = SyuTyuSen.emission;
			emission.rateOverTime = 0f;
		}
	}
}
