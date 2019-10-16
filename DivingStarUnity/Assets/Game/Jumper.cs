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
		Landing,
	}
	State state;
	float timeSinceStateChanged;

	public GameComtroller game;
	public float DefaultDownForce = 10f;
	public float TapAddForceRate = 2f;

	Animator anim;
	Rigidbody rBody;

	bool animTriggered;

	Vector3 initCameraJointAnchor;
	Vector3 initCameraAngle;


	// Start is called before the first frame update
	void Start()
	{
		rBody = GetComponent<Rigidbody>();
		anim = GetComponent<Animator>();

		initCameraJointAnchor = game.JumpCameraJoint.connectedAnchor;
		initCameraAngle = game.JumpCamera.transform.localEulerAngles;
	}

	// Update is called once per frame
	void Update()
    {
        
    }

	private void FixedUpdate()
	{
		if (state == State.Idle || state == State.Jump) {

			// トランポリンに接している間
			if (this.transform.localPosition.y < 0f && rBody.velocity.y < 0f) {
				var downForce = Vector3.down * DefaultDownForce;

				if (GetTouchCount() == 1) {
					downForce *= TapAddForceRate;
					state = State.Jump;
				}
				rBody.AddForce(downForce);
			}

			//Debug.Log("velocityY="+rBody.velocity.y+" anim="+anim.GetCurrentAnimatorStateInfo(0).shortNameHash+" isName?"+ anim.GetCurrentAnimatorStateInfo(0).IsName("JumpAnim"));
			// 上昇し始めたらアニメーション開始
			if (rBody.velocity.y > 0f) {
				if (!animTriggered) {
					anim.SetTrigger("Jump");
					animTriggered = true;
				}
			} else {
				animTriggered = false;
			}

			// ジャンプ後、降下し始めるちょい前に回転開始
			if (state == State.Jump) {
				if (this.transform.localPosition.y > 0f && rBody.velocity.y < 5f) {

					state = State.Round;
					timeSinceStateChanged = 0f;
					game.TranmpolineObj.SetActive(false);

					GameObject.Destroy(game.JumpCameraJoint);

					var cameraBody = game.JumpCamera.GetComponent<Rigidbody>();
					//cameraBody.velocity = Vector3.zero;
					//cameraBody.angularVelocity = Vector3.zero;
					var constraints = cameraBody.constraints;
					constraints |= RigidbodyConstraints.FreezePositionY;
					constraints |= RigidbodyConstraints.FreezeRotationX;
					//cameraBody.constraints = constraints;
				}
			}

		}else if(state == State.Round){

			timeSinceStateChanged += Time.fixedDeltaTime;

			var t1 = (timeSinceStateChanged) / 0.5f;
			if (t1 > 1f) t1 = 1f;

			var t2 = (timeSinceStateChanged - 0.35f) / 0.5f;
			if (t2 > 1f) t2 = 1f;

			var t3 = (timeSinceStateChanged - 0.4f) / 0.5f;
			if (t3 > 1f) t2 = 1f;


			if (t1 > 0f) {
				var from = Vector3.zero;
				var to = new Vector3(175f, 0f, 0f);
				var angle = Vector3.Lerp(from, to, t1);
				this.transform.eulerAngles = angle;
			}

			if (t2 > 0) {

				game.JumpCamera.transform.LookAt(this.transform);
				if(game.JumpCamera.transform.eulerAngles.x > 88f){
					game.JumpCamera.transform.eulerAngles = new Vector3(88f, 0f, 0f);
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

					var cameraBody = game.JumpCamera.GetComponent<Rigidbody>();
					var constraints = cameraBody.constraints;
					//constraints &= ~RigidbodyConstraints.FreezePositionY;
					constraints |= RigidbodyConstraints.FreezeRotationX;
					cameraBody.constraints = constraints;
				}


				var toJointAnchor = new Vector3(0f, -8f, -0.43f);
				var anchor = Vector3.Lerp(initCameraJointAnchor, toJointAnchor, t3);
				joint.connectedAnchor = anchor;
				//game.JumpCamera.transform.localPosition = anchor;
			}


			//game.JumpCamera.transform.LookAt(this.transform);
			//if(game.JumpCamera.transform.eulerAngles.x > 82f){
			//	game.JumpCamera.transform.eulerAngles = new Vector3(82f, 0f, 0f);
			//}

			if (timeSinceStateChanged >= 2.5f) {
				state = State.Descent;
			}

		}else if(state == State.Descent){

			if(GetTouchCount() == 1){
				var touch = GetTouch();
			}
		}


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
