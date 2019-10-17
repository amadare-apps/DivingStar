using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class Jumper : MonoBehaviour
{
	enum State{
		Idle,
		Jump,
		Round,
		Descent,
		Diving,
		Finish,
		Crash,
		Drown,//溺れる
	}
	State state;
	float timeSinceStateChanged;

	public GameComtroller game;
	public GameObject Model;
	public GameObject HeadLight;
	public Trampoline Trampo;

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


	// Start is called before the first frame update
	void Start()
	{
		rBody = GetComponent<Rigidbody>();
		anim = GetComponentInChildren<Animator>();

		initCameraJointAnchor = game.JumpCamera.GetComponent<SpringJoint>().connectedAnchor;
		initCameraAngle = game.JumpCamera.transform.localEulerAngles;
		HeadLight.SetActive(false);
	}

	private void FixedUpdate()
	{
		timeSinceStateChanged += Time.fixedDeltaTime;

		if (state == State.Idle || state == State.Jump) {

			// トランポリンに接している間
			if (this.transform.localPosition.y < 0f && rBody.velocity.y < 0f) {
				var downForce = Vector3.down * DefaultDownForce;

				if (timeSinceStateChanged > 2f) {
					if (GetTouchCount() == 1) {
						downForce *= TapAddForceRate;
						if (state == State.Idle) {
							state = State.Jump;
							Trampo.JumpBoost = true;
							//game.ToJump();
						}
					}
				}
				rBody.AddForce(downForce);
			}

			//Debug.Log("velocityY="+rBody.velocity.y+" anim="+anim.GetCurrentAnimatorStateInfo(0).shortNameHash+" isName?"+ anim.GetCurrentAnimatorStateInfo(0).IsName("JumpAnim"));
			// 上昇し始めたらアニメーション開始
			if (rBody.velocity.y > 0f) {
				if (!animTriggered) {
					anim.SetTrigger("Jump");
					HyperCasualGames.VibrationController.Single2();
					animTriggered = true;
				}
			} else {
				animTriggered = false;
			}

			// ジャンプ後、降下し始めるちょい前に回転開始
			if (state == State.Jump) {
				if (this.transform.localPosition.y > 0f && rBody.velocity.y < 1f) {

					state = State.Round;
					timeSinceStateChanged = 0f;

					// いったんJoint切断
					GameObject.Destroy(game.JumpCamera.GetComponent<SpringJoint>());

					var cameraBody = game.JumpCamera.GetComponent<Rigidbody>();
					cameraBody.useGravity = false;
					//cameraBody.velocity = Vector3.zero;
					//cameraBody.angularVelocity = Vector3.zero;
					var constraints = cameraBody.constraints;
					constraints |= RigidbodyConstraints.FreezePositionY;
					constraints |= RigidbodyConstraints.FreezeRotationX;
					//cameraBody.constraints = constraints;

					game.ToDescent();
				}
			}

		} else if (state == State.Round) {

			// chara angle
			var t1 = (timeSinceStateChanged - 0.0f) / 0.8f;
			if (t1 > 1f) t1 = 1f;

			// camera angle
			var t2 = (timeSinceStateChanged - 0.00f) / 0.5f;
			if (t2 > 1f) t2 = 1f;

			// joint point
			var t3 = (timeSinceStateChanged - 0.0f) / 0.5f;
			if (t3 > 1f) t2 = 1f;


			if (t1 > 0f) {
				var from = Vector3.zero;
				var to = new Vector3(179f, 0f, 0f);
				var angle = Vector3.Lerp(from, to, t1);
				//				this.transform.eulerAngles = angle;
				//rBody.rotation = Quaternion.Euler(angle.x, angle.y, angle.z);
				Model.transform.eulerAngles = angle;
			}

			if (t2 > 0 && game.JumpCamera.transform.eulerAngles.x < 89f) {

				var lookAtPos = this.transform.position;
				game.JumpCamera.transform.LookAt(lookAtPos, game.JumpCamera.transform.up);
				if (game.JumpCamera.transform.eulerAngles.x > 89f) {
					game.JumpCamera.transform.eulerAngles = new Vector3(89f, 0f, 0f);
				}
				if (game.JumpCamera.transform.eulerAngles.y < 0f) {
					game.JumpCamera.transform.eulerAngles = new Vector3(game.JumpCamera.transform.eulerAngles.x, 0f, 0f);
				}

				//var toCameraAngle = new Vector3(82.05f, 0f, 0f);
				//var cameraAngle = Vector3.Lerp(initCameraAngle, toCameraAngle, t2);
				//game.JumpCamera.transform.eulerAngles = cameraAngle;

				//Debug.Log("t2=" + t2 + " anchor=" + anchor + " agole=" + cameraAngle);
			}

			if (t3 > 0f) {

				var joint = game.JumpCamera.GetComponent<FixedJoint>();
				if (!joint) {

					joint = game.JumpCamera.gameObject.AddComponent<FixedJoint>();
					joint.connectedBody = this.rBody;
					initCameraJointAnchor = joint.connectedAnchor;
					joint.autoConfigureConnectedAnchor = false;
					//joint.damper = 0.5f;
					//joint.spring = 10f;
					//joint.maxDistance = 0.2f;

					var cameraBody = game.JumpCamera.GetComponent<Rigidbody>();
					var constraints = cameraBody.constraints;
					//constraints &= ~RigidbodyConstraints.FreezePositionY;
					constraints |= RigidbodyConstraints.FreezeRotationX;
					cameraBody.constraints = constraints;
				}


				var toJointAnchor = new Vector3(0f, 6f, 0.2f);
				var anchor = Vector3.Lerp(initCameraJointAnchor, toJointAnchor, t3);
				joint.connectedAnchor = anchor;
				//game.JumpCamera.transform.localPosition = anchor;
			}


			//game.JumpCamera.transform.LookAt(this.transform);
			//if(game.JumpCamera.transform.eulerAngles.x > 82f){
			//	game.JumpCamera.transform.eulerAngles = new Vector3(82f, 0f, 0f);
			//}

			if (timeSinceStateChanged >= 1.5f) {
				state = State.Descent;
				{
					var constraints = rBody.constraints;
					constraints &= ~RigidbodyConstraints.FreezePositionX;
					constraints &= ~RigidbodyConstraints.FreezePositionZ;
					rBody.constraints = constraints;
					//					rBody.constraints = RigidbodyConstraints.None;
				}
				{
					var cameraBody = game.JumpCamera.GetComponent<Rigidbody>();
					var constraints = cameraBody.constraints;
					constraints &= ~RigidbodyConstraints.FreezePositionX;
					constraints &= ~RigidbodyConstraints.FreezePositionZ;
					cameraBody.constraints = constraints;
				}
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
				var toPos = rBody.position + addPos;
				if (toPos.x > 10f) toPos.x = 10f;
				if (toPos.z > 10f) toPos.z = 10f;
				if (toPos.x < -10f) toPos.x = -10f;
				if (toPos.z < -10f) toPos.z = -10f;
				rBody.position = toPos;
			}

			if (this.transform.position.y < 0f) {
				state = State.Diving;
				HyperCasualGames.VibrationController.Triple();
				HeadLight.SetActive(true);
				game.ToDiving();
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

			}else{
				// 消費していない間はデンジャーゲージ回復
				float recovery = 2f * Time.fixedDeltaTime / BoostTimeMax;
				DangerRate -= recovery;
				if (DangerRate < 0f) DangerRate = 0f;
			}

			game.SetBoostGaugeRate((BoostTimeMax - UsedBoostTime) / BoostTimeMax, DangerRate);

			rBody.AddForce(Vector3.up * WaterResistance);

			if (rBody.velocity.y >= 0f) {

				state = State.Finish;
				rBody.isKinematic = true;
				game.ToRecord();

			} else if(DangerRate >= 1f){

				state = State.Drown;
				game.ToDrown();

				rBody.useGravity = false;
				rBody.velocity = Vector3.down * 2.0f;

				GameObject.Destroy(game.JumpCamera.GetComponent<FixedJoint>());
				GameObject.Destroy(game.JumpCamera.GetComponent<Rigidbody>());
				//game.JumpCamera.GetComponent<Rigidbody>().useGravity = false;
				//game.JumpCamera.GetComponent<Rigidbody>().velocity = Vector3.down * 1.0f;
			}

		} else if(state == State.Crash){

			game.JumpCamera.transform.LookAt(this.transform);

		}else if(state == State.Drown){

		}


	}

	private void OnCollisionEnter(Collision collision)
	{
		if (state == State.Descent){
			state = State.Crash;

			rBody.constraints = RigidbodyConstraints.None;
			rBody.AddExplosionForce(100f, this.transform.position - Vector3.down * 2, 10f);

			var cameraBody = game.JumpCamera.GetComponent<Rigidbody>();
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


	// Update is called once per frame
	void Update()
	{
		if(GetTouchCount() == 1){
			var touch = GetTouch();
			if(touch.phase == TouchPhase.Began){
				this.touchStartPos = touch.position;
			}else if(touch.phase == TouchPhase.Ended || touch.phase == TouchPhase.Canceled){
				this.touchStartPos = Vector2.zero;
			}
		}
	}

	public Vector2 TouchDeltaFromStartPos(){
		if(GetTouchCount() == 1){
			var touch = GetTouch();
			if(touch.phase == TouchPhase.Moved || touch.phase == TouchPhase.Stationary){
				return touch.position - this.touchStartPos;
			}
		}
		return Vector2.zero;
	}

	public int GetTouchCount()
	{

		if (Application.isEditor) {
			if (EventSystem.current.IsPointerOverGameObject()) return 0;
			if (Input.GetMouseButtonDown(0)) return 1;
			if (Input.GetMouseButton(0)) return 1;
			if (Input.GetMouseButtonUp(0)) return 1;
			return 0;
		}

		if (Input.touchCount == 0) return 0;

		if (EventSystem.current.IsPointerOverGameObject(Input.GetTouch(0).fingerId)) {
			return 0;
		}

		return Input.touchCount;
	}

	Vector3 lastMousePos;
	Vector2 touchStartPos;

	public Touch GetTouch()
	{
		if (Application.isEditor) {
			Touch t = new Touch();
			if (Input.GetMouseButtonDown(0)) t.phase = TouchPhase.Began;
			else if (Input.GetMouseButtonUp(0)) t.phase = TouchPhase.Ended;
			else if (Input.GetMouseButton(0)) t.phase = TouchPhase.Moved;
			t.position = Input.mousePosition;
			t.deltaPosition = Input.mousePosition - lastMousePos;
			lastMousePos = Input.mousePosition;
			return t;
		}

		return Input.GetTouch(0);
	}

}
