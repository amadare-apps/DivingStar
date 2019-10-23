using UnityEngine;

[AddComponentMenu("DCG/DCG Caustics")]
[RequireComponent(typeof(Projector))]
[ExecuteInEditMode]
public class DCGCaustics : MonoBehaviour {

    public Material causticsMaterial;
    Projector pr;
    public DCGWater waterReference;

	private void Awake () {
        pr = GetComponent<Projector>();
        pr.orthographic = true;
        pr.material = causticsMaterial;
    }
    void Update () {
        if (waterReference)
        {
            if(transform.position.y != waterReference.transform.position.y)
            {
                transform.position = waterReference.transform.position;
            }
            if(transform.localEulerAngles.x != 90f)
            {
                transform.localEulerAngles = Vector3.right * 90f;
            }
            UpdateProjector();
        }
	}
    private void UpdateProjector()
    {
        if(pr.orthographicSize != waterReference.meshSize)
        {
            pr.orthographicSize = waterReference.meshSize;
        }

        if (pr.farClipPlane != waterReference.waterDepth)
        {
            pr.farClipPlane = waterReference.waterDepth;
        }
    }
}
