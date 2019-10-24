using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class Jumper : MonoBehaviour
{
	enum State{
		Idle,
		PreCharge,
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

	public GameComtroller game;
	public GameObject Model;
	public GameObject HeadLight;
	public Trampoline Trampo;
	public TimingRings timingRings;
	public ParticleSystem TrailEffect;
	public ParticleSystem GrowEffect;
	public IncomingWater IncomingEffect;
	public ParticleSystem BoostEffect;

	public float DefaultDownForce = 150f;
	public float TapAddForceRate = 2f;
	public float RingAccelForceRate = 5f;
	public float WaterResistance = 20f;
	public float BoostRate = 10f;

	public float BoostTimeMax = 3f;
	public float UsedBoostTime = 0f;
	public float DangerRate = 0f;

	Animator anim;
	Rigidbody rBody;

	bool animTriggered;

	Vector3 initCameraJointAnchor;
	Vector3 initCameraAngle;

	JumpCamera jumpCamera;



	// Start is called before the first frame update
	void Start()
	{
		rBody = GetComponent<Rigidbody>();
		anim = GetComponentInChildren<Animator>();

		this.jumpCamera = game.JumpCamera;
		initCameraJointAnchor = this.jumpCamera.GetComponent<SpringJoint>().connectedAnchor;
		initCameraAngle = this.jumpCamera.transform.localEulerAngles;
		HeadLight.SetActive(false);
		TrailEffect.gameObject.SetActive(false);
	}

	void ChangeState(State state)
	{
		Debug.Log("Jumper.ChangeState() " + this.state + " to " + state);
		timeSinceStateChanged = 0f;
		this.state = state;
	}

	private void FixedUpdate()
	{
		timeSinceStateChanged += Time.fixedDeltaTime;

		bool boost = false;

		if (state == State.Idle || state == State.PreCharge) {

			// トランポリンに接している間
			if (this.transform.localPosition.y < 0f && rBody.velocity.y < 0f) {
				var downForce = Vector3.down * DefaultDownForce;
				rBody.AddForce(downForce);

				if (timeSinceStateChanged > 2f && state == State.Idle) {
					if (TouchController.Instance.GetTouchCount() == 1) {
						ChangeState(State.PreCharge);
						jumpCamera.ToCharge();
					}
				}else if(state == State.PreCharge){

					if (this.transform.localPosition.y < -0.003f && rBody.velocity.y > -1.8f) {
						Debug.Log("PreCharge velocity = " + rBody.velocity.y + " trans=" + this.transform.localPosition.y);
						ChangeState(State.Charge);
						rBody.velocity = Vector3.zero;
						rBody.useGravity = false;
						//HyperCasualGames.VibrationController.Triple();
						//jumpCamera.ToCharge();
						Trampo.ToCharge();

						TrailEffect.gameObject.SetActive(true);
					}
				}
			}

			//Debug.Log("velocityY="+rBody.velocity.y+" anim="+anim.GetCurrentAnimatorStateInfo(0).shortNameHash+" isName?"+ anim.GetCurrentAnimatorStateInfo(0).IsName("JumpAnim"));
			// 上昇し始めたらアニメーション開始
			if (rBody.velocity.y > 0f) {
				if (!animTriggered) {
					anim.SetTrigger("Jump");
					HyperCasualGames.VibrationController.Single1();
					animTriggered = true;
				}
			} else {
				animTriggered = false;
			}

			//if(state == State.Idle)
			{
				if (rBody.velocity.y < 0f) {
					this.timingRings.ShowAll();

					if (state == State.Idle) {
						if (this.transform.localPosition.y >= 0f) {
							game.jumpGauge.SetMaxPower((4f - this.transform.localPosition.y) / 4f);
							this.timingRings.SetRadius(1f + this.transform.localPosition.y);
						} else {
							game.jumpGauge.SetMaxPower(1f + this.transform.localPosition.y / 1.4f);
							this.timingRings.SetRadius(1f + this.transform.localPosition.y / 1.4f);
						}
					}
				} else {
					this.timingRings.HideAll();
				}
			}

		}else if(state == State.Charge){

			//var downForce = Vector3.down * DefaultDownForce;
			//rBody.AddForce(downForce);
			rBody.velocity = Vector3.zero;

			if (timeSinceStateChanged > 1f){
				//Debug.Break();
			}

			if (TouchController.Instance.GetTouchCount() != 1){
				ChangeState(State.Jump);
				jumpCamera.ToJump();
				Trampo.ToJump();
				game.ToJump();

				rBody.useGravity = true;
			}else{
				HyperCasualGames.VibrationController.Single1();
			}

		} else if(state == State.Jump){

			// ジャンプ後、降下し始めるちょい前に回転開始
			if (this.transform.localPosition.y > 0f && rBody.velocity.y < 0.1f) {

				ChangeState(State.Round);
				jumpCamera.ToRound();

				game.ToDescent();

				HyperCasualGames.VibrationController.Double0();
			}

		} else if (state == State.Round) {

			// chara angle
			var t1 = (timeSinceStateChanged - 0.0f) / 2.0f;
			if (t1 > 1f) t1 = 1f;

			if (t1 > 0f) {
				var from = Vector3.zero;
				var to = new Vector3(180f, 0f, 0f);
				var angle = Vector3.Lerp(from, to, t1);
				//				this.transform.eulerAngles = angle;
				//rBody.rotation = Quaternion.Euler(angle.x, angle.y, angle.z);
				Model.transform.eulerAngles = angle;
			}

			if (timeSinceStateChanged >= 2.0f) {
				ChangeState(State.Descent);
				jumpCamera.ToDescent();
				{
					var constraints = rBody.constraints;
					constraints &= ~RigidbodyConstraints.FreezePositionX;
					constraints &= ~RigidbodyConstraints.FreezePositionZ;
					rBody.constraints = constraints;
				}
				GrowEffect.Stop();
			}

		} else if (state == State.Descent) {

			var delta = TouchController.Instance.TouchDeltaFromStartPos();
			if (delta != Vector2.zero) {
				float moveRate = 0.0025f;
				var addPos = new Vector3(delta.x * moveRate, 0, delta.y * moveRate);
				if (addPos.x > 1f) addPos.x = 1f;
				if (addPos.z > 1f) addPos.z = 1f;
				if (addPos.x < -1f) addPos.x = -1f;
				if (addPos.z < -1f) addPos.z = -1f;
				//Debug.Log("add pos=" + addPos);
				var toPos = this.transform.position + addPos;
				if (toPos.x > 10f) toPos.x = 10f;
				if (toPos.z > 10f) toPos.z = 10f;
				if (toPos.x < -10f) toPos.x = -10f;
				if (toPos.z < -10f) toPos.z = -10f;
				this.transform.position = toPos;
			}

			if (this.transform.position.y < 0f) {
				ChangeState(State.Diving);
				jumpCamera.ToDiving();
				//HyperCasualGames.VibrationController.Triple();
				//HeadLight.SetActive(true);
				game.ToDiving();
				IncomingEffect.gameObject.SetActive(true);
			}

		}else if(state == State.Diving){
			// 水中

			// ブースト残量あり
			if(TouchController.Instance.GetTouchCount() == 1 && UsedBoostTime < BoostTimeMax){

				float used = Time.fixedDeltaTime;
				if (used + UsedBoostTime > BoostTimeMax) used = BoostTimeMax - UsedBoostTime;

				UsedBoostTime += used;

				rBody.AddForce(Vector3.down * BoostRate);

				var thisUsedRate = used / BoostTimeMax;//消費したゲージの
				DangerRate += thisUsedRate * 1.5f;//1.5倍デンジャーゲージがたまる

				boost = true;

				HyperCasualGames.VibrationController.Single1();

			} else {
				// 消費していない間はデンジャーゲージ回復
				float recovery = 2f * Time.fixedDeltaTime / BoostTimeMax;
				DangerRate -= recovery;
				if (DangerRate < 0f) DangerRate = 0f;
			}

			game.SetBoostGaugeRate((BoostTimeMax - UsedBoostTime) / BoostTimeMax, DangerRate);

			//Debug.Log("velocity="+rBody.velocity.y+" force="+ (Vector3.up * WaterResistance * (Mathf.Abs(rBody.velocity.y) + 0.1f)));
			rBody.AddForce(Vector3.up * (WaterResistance * Mathf.Abs(rBody.velocity.y) + 11.0f));

			if (rBody.velocity.y >= 0f) {

				ChangeState(State.Finish);
				rBody.isKinematic = true;
				game.ToRecord();

				HyperCasualGames.VibrationController.Triple();

			} else if(DangerRate >= 1f){

				ChangeState(State.Drown);
				jumpCamera.ToDrown();
				game.ToDrown();

				rBody.useGravity = false;
				rBody.velocity = Vector3.down * 2.0f;

				//GameObject.Destroy(this.jumpCamera.GetComponent<FixedJoint>());
				//GameObject.Destroy(this.jumpCamera.GetComponent<Rigidbody>());
				//game.JumpCamera.GetComponent<Rigidbody>().useGravity = false;
				//game.JumpCamera.GetComponent<Rigidbody>().velocity = Vector3.down * 1.0f;

				HyperCasualGames.VibrationController.Triple();
			}

		} else if(state == State.Crash){

			this.jumpCamera.transform.LookAt(this.transform);

		}else if(state == State.Drown){

		}

		// effect
		if (boost) {
			if (!BoostEffect.isPlaying) BoostEffect.Play();
			var emission = BoostEffect.emission;
			if (emission.rateOverTime.constant < 200f) {
				emission.rateOverTime = emission.rateOverTime.constant + 20f;
			}
		}else{
			var emission = BoostEffect.emission;
			emission.rateOverTime = 0f;
		}
	}

	private void OnCollisionEnter(Collision collision)
	{
		if(state == State.Idle){

			if(collision.collider.GetComponent<Trampoline>()){
				//HyperCasualGames.VibrationController.Single0();
			}

		} else if (state == State.Descent){
			ChangeState(State.Crash);

			rBody.constraints = RigidbodyConstraints.None;
			rBody.AddExplosionForce(100f, this.transform.position - Vector3.down * 2, 10f);

			var cameraBody = this.jumpCamera.GetComponent<Rigidbody>();
			cameraBody.isKinematic = true;
			GameObject.Destroy(cameraBody.GetComponent<FixedJoint>());

			HyperCasualGames.VibrationController.Triple();

			game.ToCrash();
		}
	}

	private void OnTriggerEnter(Collider other)
	{
		if(state == State.Descent){
			var ring = other.GetComponent<AccelRing>();
			if (ring) {
				ring.SetToSuccess();
				rBody.AddForce(Vector3.down * RingAccelForceRate, ForceMode.Impulse);
				HyperCasualGames.VibrationController.Double0();
			}
		}
	}

}
