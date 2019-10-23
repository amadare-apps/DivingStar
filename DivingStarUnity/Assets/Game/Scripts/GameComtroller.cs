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
		ShowRecord,
		Crash,
		Drown,
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
	public TextMeshProUGUI HeightLabel;

	public GameObject InWaterObj;
	public TextMeshProUGUI DepthLabel;
	public Image BoostGauge;
	public Image DangerGaugeYellow;
	public Image DangerGaugeRed;

	public GameObject InJumpObj;
	public JumpGauge jumpGauge;
	public TimingRings timingRings;

	public TextMeshProUGUI RecordLabel;
	public TextMeshProUGUI CrashLabel;
	public TextMeshProUGUI DrownLabel;

	public StrengthUI strengthUI;



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

		strengthUI.Setup(jumper, Trampo);

		SwitchToInitial();
	}

	// Update is called once per frame
	void Update()
	{
		timeSinceStateChanged += Time.deltaTime;

		if(state == State.InGame){

			SetHeightLabel();
			SetDepthLabel();

		}else if (state == State.ShowRecord || state == State.Crash || state == State.Drown) {

			if (timeSinceStateChanged > 2f) {
				if (TouchController.Instance.GetTouchCount() == 1) {
					Initialize();
					state = State.InGame;
				}
			}
		}
	}

	void SetDepthLabel(){
		int depth = jumper.transform.position.y < 0f ? Mathf.RoundToInt(Mathf.Abs(jumper.transform.position.y)) : 0;
		DepthLabel.SetText(string.Format("{0}m", depth));
	}

	int maxHeight = 0;
	void SetHeightLabel(){
		int height = jumper.transform.position.y > 0f ? Mathf.RoundToInt(Mathf.Abs(jumper.transform.position.y)) : 0;
		maxHeight = Mathf.Max(maxHeight, height);
		HeightLabel.SetText(string.Format("{0}m", maxHeight));
	}

	public void SwitchToInitial()
	{
		maxHeight = 0;
		HeightLabel.gameObject.SetActive(false);
		SetActiveTrampoline(true);
		SetActiveRings(false);
		InWaterObj.SetActive(false);

		RecordLabel.gameObject.SetActive(false);
		CrashLabel.gameObject.SetActive(false);
		DrownLabel.gameObject.SetActive(false);

		strengthUI.gameObject.SetActive(true);
	}

	public void ToJump(){
		HeightLabel.gameObject.SetActive(true);
		strengthUI.gameObject.SetActive(false);
		SetHeightLabel();
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
		DangerGaugeYellow.fillAmount = 0f;
		DangerGaugeRed.fillAmount = 0f;
	}

	public void SetBoostGaugeRate(float rate, float dangerRate){
		BoostGauge.fillAmount = rate;
		var yellow = (dangerRate > 0.82f ? 0.82f : dangerRate) / 0.82f;
		var red = (dangerRate < 0.82f ? 0f : dangerRate - 0.82f) / 0.18f;
		if (yellow < 0f) yellow = 0f;
		if (red < 0f) red = 0f;
		DangerGaugeYellow.fillAmount = yellow;
		DangerGaugeRed.fillAmount = red;
	}

	public void ToRecord()
	{
		this.state = State.ShowRecord;
		this.timeSinceStateChanged = 0f;

		int depth = jumper.transform.position.y < 0f ? Mathf.RoundToInt(Mathf.Abs(jumper.transform.position.y)) : 0;
		RecordLabel.SetText(string.Format("Record {0}m", depth));
		RecordLabel.gameObject.SetActive(true);
	}

	public void ToCrash()
	{
		this.state = State.Crash;
		this.timeSinceStateChanged = 0f;

		CrashLabel.gameObject.SetActive(true);
	}

	public void ToDrown()
	{
		this.state = State.Drown;
		this.timeSinceStateChanged = 0f;

		DrownLabel.gameObject.SetActive(true);
	}



	void SetActiveTrampoline(bool active){
		if(Trampo != null){
			TrampoObj.SetActive(active);
			Trampo.Reset();
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
