using UnityEngine;
using System.Collections;

[RequireComponent(typeof(LineRenderer))]
public class DrawCircle : MonoBehaviour
{
	Material ringMaterial;

	[Range(0.1f, 100f)]
	public float radius = 1.0f;

	[Range(3, 256)]
	public int numSegments = 64;

	void Start()
	{
		ringMaterial = GetComponent<LineRenderer>().material;
		//DoRenderer();
	}

	public void ChangeRadius(float radius){
		this.radius = radius;
		DoRenderer();
	}

	public void DoRenderer()
	{
		LineRenderer lineRenderer = gameObject.GetComponent<LineRenderer>();
		Color c1 = new Color(0.5f, 0.5f, 0.5f, 1);
//		lineRenderer.material = new Material(Shader.Find("Particles/Additive"));
		//lineRenderer.SetColors(c1, c1);
		//lineRenderer.SetWidth(0.5f, 0.5f);
		lineRenderer.positionCount = numSegments + 1;
		//lineRenderer.SetVertexCount(numSegments + 1);
		lineRenderer.useWorldSpace = false;

		float deltaTheta = (float)(2.0 * Mathf.PI) / numSegments;
		float theta = 0f;

		for (int i = 0; i < numSegments + 1; i++) {
			float x = radius * Mathf.Cos(theta);
			float z = radius * Mathf.Sin(theta);
			Vector3 pos = new Vector3(x, 0, z);
			lineRenderer.SetPosition(i, pos);
			theta += deltaTheta;
		}
	}

	[ContextMenu("Draw")]
	private void Draw()
	{
		DoRenderer();
	}

	public void HideStart(){
		//		this.gameObject.SetActive(false);
		if (isHide) return;
		isHide = true;
		hideTime = 0.2f;
	}

	bool isHide = false;
	float hideTime = 0f;

	private void Update()
	{
		if(isHide && hideTime > 0f){
			hideTime -= Time.deltaTime;
			if (hideTime < 0f) hideTime = 0f;

			var toColor = ringMaterial.color;
			toColor.a = Mathf.Lerp(1f, 0f, hideTime / 0.2f);
			ringMaterial.color = toColor;
		}
	}

	public void Show(){
		this.gameObject.SetActive(true);

		var toColor = ringMaterial.color;
		toColor.a = 1f;
		ringMaterial.color = toColor;

		isHide = false;
	}
}
