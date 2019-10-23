using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class TouchController : SingletonMonoBehaviour<TouchController>
{

	Vector3 lastMousePos;
	Vector2 touchStartPos;

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
