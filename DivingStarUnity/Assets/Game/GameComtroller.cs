using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using UnityEngine.UI;
using TMPro;

public class GameComtroller : MonoBehaviour
{
	public enum State
	{
		InGame,
		GameOver,
		GameOverNext,
	}
	public State state;
	float timeSinceStateChanged;


	[SerializeField] Jumper jumperOrg;
	[SerializeField] Camera JumpCameraOrg;
	public SpringJoint JumpCameraJoint;
	public GameObject TrampoObj;
	public Trampoline Trampo;

	public List<AccelRing> Rings;
	public UnderWater Ocean;

	public Camera JumpCamera;
	public Jumper jumper;

	// UI
	public GameObject InWaterObj;
	public TextMeshProUGUI DepthLabel;
	public Image BoostGauge;



    // Start is called before the first frame update
    void Awake()
    {
		TouchController.Instance.Initialize();

		Ocean.Setup();
		Initialize();
	}

	public void Initialize()
	{
		if(jumper != null) GameObject.Destroy(jumper.gameObject);
		if (JumpCamera != null) GameObject.Destroy(JumpCamera.gameObject);

		jumper = Instantiate(jumperOrg, jumperOrg.transform.parent);
		jumper.gameObject.SetActive(true);

		JumpCamera = Instantiate(JumpCameraOrg, JumpCameraOrg.transform.parent);
		JumpCamera.gameObject.SetActive(true);

		jumperOrg.gameObject.SetActive(false);
		JumpCameraOrg.gameObject.SetActive(false);

		JumpCamera.GetComponent<SpringJoint>().connectedBody = jumper.GetComponent<Rigidbody>();

		SwitchToInitial();
	}

	// Update is called once per frame
	void Update()
	{
		timeSinceStateChanged += Time.deltaTime;

		if(state == State.InGame){

			SetDepthLabel();

		}else if (state == State.GameOver) {

			if (timeSinceStateChanged > 2f) {
				state = State.GameOverNext;
			}

		}else if(state == State.GameOverNext){

			if(TouchController.Instance.GetTouchCount() == 1){
				Initialize();
				state = State.InGame;
			}
		}
	}

	void SetDepthLabel(){
		int depth = jumper.transform.position.y < 0f ? Mathf.RoundToInt(Mathf.Abs(jumper.transform.position.y)) : 0;
		DepthLabel.SetText(string.Format("{0}m", depth));
	}

	public void SwitchToInitial()
	{
		SetActiveTrampoline(true);
		SetActiveRings(false);
		InWaterObj.SetActive(false);
	}

	// 落下開始時にコール
	public void ToDescent(){
		SetActiveTrampoline(false);
		SetActiveRings(true);
		InWaterObj.SetActive(false);
	}

	public void ToDiving(){
		InWaterObj.SetActive(true);
		BoostGauge.fillAmount = 1f;
	}

	public void SetBoostGaugeRate(float rate){
		BoostGauge.fillAmount = rate;
	}

	public void ToGameOver(){
		this.state = State.GameOver;
		this.timeSinceStateChanged = 0f;
	}



	void SetActiveTrampoline(bool active){
		if(Trampo != null){
			TrampoObj.SetActive(active);
			Trampo.JumpBoost = false;
		}
	}

	void SetActiveRings(bool active){
		if (Rings != null) {
			foreach (var ring in Rings) {
				ring.gameObject.SetActive(active);
				ring.SetToDefault();
			}
		}
	}

}
