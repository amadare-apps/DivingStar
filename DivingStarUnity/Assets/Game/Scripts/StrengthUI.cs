using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class StrengthUI : MonoBehaviour
{

	public TextMeshProUGUI JumpPowerLabel;
	public TextMeshProUGUI BoostPowerLabel;
	public TextMeshProUGUI BoostTimeLabel;

	public float JumpPower;
	public float BoostPower;
	public float BoostTime;

	Jumper jumper;
	Trampoline trampoline;
	bool initialized = false;

	public void Setup(Jumper jumper, Trampoline trampoline){

		this.jumper = jumper;
		this.trampoline = trampoline;

		if (!initialized) {
			this.JumpPower = trampoline.SpringForceRate;
			this.BoostPower = jumper.BoostRate;
			this.BoostTime = jumper.BoostTimeMax;
			initialized = true;
			RefreshLabels();
		} else {
			ApplyParam();
		}
	}

	void ApplyParam(){
		this.trampoline.SpringForceRate = this.JumpPower;
		this.jumper.BoostRate = this.BoostPower;
		this.jumper.BoostTimeMax = this.BoostTime;
		RefreshLabels();
	}

    // Update is called once per frame
    void RefreshLabels()
    {
		JumpPowerLabel.SetText(string.Format("JumpPower {0:0.0}", this.JumpPower));
		BoostPowerLabel.SetText(string.Format("BoostPower {0:0}", this.BoostPower));
		BoostTimeLabel.SetText(string.Format("BoostTime {0:0}s", this.BoostTime));
	}

	public void OnTapJumpMinus()
	{
		JumpPower -= 0.5f;
		if (JumpPower < 1f) JumpPower = 1f;
		ApplyParam();
	}
	public void OnTapJumpPlus()
	{
		JumpPower += 0.5f;
		ApplyParam();
	}
	public void OnTapBoostPowerMinus()
	{
		BoostPower -= 1f;
		if (BoostPower < 10f) BoostPower = 10f;
		ApplyParam();
	}
	public void OnTapBoostPowerPlus()
	{
		BoostPower += 1f;
		ApplyParam();
	}
	public void OnTapBoostTimeMinus()
	{
		BoostTime -= 1f;
		if (BoostTime < 3f) BoostTime = 3f;
		ApplyParam();
	}
	public void OnTapBoostTimePlus()
	{
		BoostTime += 1f;
		ApplyParam();
	}
}
