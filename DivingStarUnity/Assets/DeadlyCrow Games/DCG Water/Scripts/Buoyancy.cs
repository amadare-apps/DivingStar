using System.Collections;
using System.Collections.Generic;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif
[RequireComponent(typeof(Rigidbody))]
[AddComponentMenu("DCG/Buoyancy Object")]
public class Buoyancy : MonoBehaviour
{
	public float density = 500;
	public int slicesPerAxis = 2;
    bool isConcave = false;
	int voxelsLimit = 16;

    [Range(0.01f,0.5f)]
    public float sleepTime = 0.1f;
    [Range(0.5f, 2f)]
    public float forcePower = 1.2f;

    private const float DAMPFER = 0.1f;
	private const float WATER_DENSITY = 1000;

	private float voxelHalfHeight;
	private Vector3 localArchimedesForce;
	private List<Vector3> voxels;
	private bool isMeshCollider;
	private List<Vector3[]> forces;

    bool trigger = false;
    bool onWater = false;

    Transform currentWaterTransform;
    Mesh currentWaterMesh;
    Rigidbody rb;

	private void Start()
	{
        rb = GetComponent<Rigidbody>();
        forces = new List<Vector3[]>();
		var originalRotation = transform.rotation;
		var originalPosition = transform.position;
		transform.rotation = Quaternion.identity;
		transform.position = Vector3.zero;
		if (GetComponent<Collider>() == null)
		{
			gameObject.AddComponent<MeshCollider>();
			Debug.LogWarning(string.Format("[Buoyancy.cs] Object \"{0}\" had no collider. MeshCollider has been added.", name));
		}
		isMeshCollider = GetComponent<MeshCollider>() != null;
		var bounds = GetComponent<Collider>().bounds;
		if (bounds.size.x < bounds.size.y)
		{
			voxelHalfHeight = bounds.size.x;
		}
		else
		{
			voxelHalfHeight = bounds.size.y;
		}
		if (bounds.size.z < voxelHalfHeight)
		{
			voxelHalfHeight = bounds.size.z;
		}
		voxelHalfHeight /= 2 * slicesPerAxis;
		if (GetComponent<Rigidbody>() == null)
		{
			gameObject.AddComponent<Rigidbody>();
			Debug.LogWarning(string.Format("[Buoyancy.cs] Object \"{0}\" had no Rigidbody. Rigidbody has been added.", name));
		}
		GetComponent<Rigidbody>().centerOfMass = new Vector3(0, -bounds.extents.y * 0f, 0) + transform.InverseTransformPoint(bounds.center);
		voxels = SliceIntoVoxels(isMeshCollider && isConcave);
		transform.rotation = originalRotation;
		transform.position = originalPosition;
		float volume = rb.mass / density;
		WeldPoints(voxels, voxelsLimit);
		float archimedesForceMagnitude = WATER_DENSITY * Mathf.Abs(Physics.gravity.y) * volume;
		localArchimedesForce = new Vector3(0, archimedesForceMagnitude, 0) / voxels.Count;
	}

	
	private List<Vector3> SliceIntoVoxels(bool concave)
	{
		var points = new List<Vector3>(slicesPerAxis * slicesPerAxis * slicesPerAxis);
		if (concave)
		{
            var meshCol = GetComponent<MeshCollider>();
			var convexValue = meshCol.convex;
			meshCol.convex = false;
			var bounds = GetComponent<Collider>().bounds;
			for (int ix = 0; ix < slicesPerAxis; ix++)
			{
				for (int iy = 0; iy < slicesPerAxis; iy++)
				{
					for (int iz = 0; iz < slicesPerAxis; iz++)
					{
						float x = bounds.min.x + bounds.size.x / slicesPerAxis * (0.5f + ix);
						float y = bounds.min.y + bounds.size.y / slicesPerAxis * (0.5f + iy);
						float z = bounds.min.z + bounds.size.z / slicesPerAxis * (0.5f + iz);

						var p = transform.InverseTransformPoint(new Vector3(x, y, z));

						if (PointIsInsideMeshCollider(meshCol, p))
						{
							points.Add(p);
						}
					}
				}
			}
			if (points.Count == 0)
			{
				points.Add(bounds.center);
			}
			meshCol.convex = convexValue;
		}
		else
		{
			var bounds = GetComponent<Collider>().bounds;
			for (int ix = 0; ix < slicesPerAxis; ix++)
			{
				for (int iy = 0; iy < slicesPerAxis; iy++)
				{
					for (int iz = 0; iz < slicesPerAxis; iz++)
					{
						float x = bounds.min.x + bounds.size.x / slicesPerAxis * (0.5f + ix);
						float y = bounds.min.y + bounds.size.y / slicesPerAxis * (0.5f + iy);
						float z = bounds.min.z + bounds.size.z / slicesPerAxis * (0.5f + iz);

						var p = transform.InverseTransformPoint(new Vector3(x, y, z));

						points.Add(p);
					}
				}
			}
		}
		return points;
	}
    
	private static bool PointIsInsideMeshCollider(Collider c, Vector3 p)
	{
		Vector3[] directions = { Vector3.up, Vector3.down, Vector3.left, Vector3.right, Vector3.forward, Vector3.back };
		foreach (var ray in directions)
		{
			RaycastHit hit;
			if (c.Raycast(new Ray(p - ray * 1000, ray), out hit, 1000f) == false)
			{
				return false;
			}
		}
		return true;
	}
    
	private static void FindClosestPoints(IList<Vector3> list, out int firstIndex, out int secondIndex)
	{
		float minDistance = float.MaxValue, maxDistance = float.MinValue;
		firstIndex = 0;
		secondIndex = 1;
		for (int i = 0; i < list.Count - 1; i++)
		{
			for (int j = i + 1; j < list.Count; j++)
			{
				float distance = Vector3.Distance(list[i], list[j]);
				if (distance < minDistance)
				{
					minDistance = distance;
					firstIndex = i;
					secondIndex = j;
				}
				if (distance > maxDistance)
				{
					maxDistance = distance;
				}
			}
		}
	}

	private static void WeldPoints(IList<Vector3> list, int targetCount)
	{
		if (list.Count <= 2 || targetCount < 2)
		{
			return;
		}
		while (list.Count > targetCount)
		{
			int first, second;
			FindClosestPoints(list, out first, out second);
			var mixed = (list[first] + list[second]) * 0.5f;
			list.RemoveAt(second); 
			list.RemoveAt(first);
			list.Add(mixed);
		}
	}

	private float GetWaterLevel(float x, float z)
	{
        RaycastHit hit;
        int layerMask = 1 << 4;
        if (Physics.Raycast(new Vector3(x, 1000f, z), Vector3.down, out hit,1200f, layerMask))
        {
            return hit.point.y;
        }
        return -1000;
	}

    private void GetCurrentWater()
    {
        RaycastHit hit;
        int layerMask = 1 << 4;
        if (Physics.Raycast(transform.position + (Vector3.up * 100f), Vector3.down, out hit, 1200f, layerMask))
        {
            currentWaterTransform = hit.transform;
            currentWaterMesh = currentWaterTransform.gameObject.GetComponent<MeshFilter>().mesh;
        }
    }

    private void ClearCurrentWater()
    {
        currentWaterMesh = null;
        currentWaterTransform = null;
    }

    private float ClosestVertexHeight(Vector3 buoyPos)
    {
        float bestTarget = -10000f;
        if (currentWaterTransform != null)
        {
            float closestDistanceSqr = Mathf.Infinity;
            Vector3 currentPosition = buoyPos;
            foreach (var vertex in currentWaterMesh.vertices)
            {
                Vector3 fixedVert = vertex + currentWaterTransform.position;
                Vector3 directionToTarget = fixedVert - currentPosition;
                float dSqrToTarget = directionToTarget.sqrMagnitude;
                if (dSqrToTarget < closestDistanceSqr)
                {
                    closestDistanceSqr = dSqrToTarget;
                    bestTarget = fixedVert.y;
                }
            }
        }
        return bestTarget;
    }

    private void FixedUpdate()
    {
        if (!trigger && onWater)
        {
            trigger = true;
            StartCoroutine(IntervalDelay());
            forces.Clear();
            
            for (int i = 0; i < voxels.Count; i++)
            {
                var wp = transform.TransformPoint(voxels[i]);
                //  float waterLevel = GetWaterLevel(wp.x, wp.z);
                float waterLevel = ClosestVertexHeight(wp);

                if (wp.y - voxelHalfHeight < waterLevel)
                {
                    float k = (waterLevel - wp.y) / (2 * voxelHalfHeight) + 0.5f;
                    if (k > 1)
                    {
                        k = 1f;
                    }
                    else if (k < 0)
                    {
                        k = 0f;
                    }
                    var velocity = rb.GetPointVelocity(wp);
                    var localDampingForce = -velocity * DAMPFER * rb.mass;
                    var force = localDampingForce + Mathf.Sqrt(k) * localArchimedesForce;

                    Vector3 foreceToApply = (force * forcePower * Time.deltaTime * 20f)/sleepTime;

                    rb.AddForceAtPosition(foreceToApply, wp);

                    forces.Add(new[] { wp, force * forcePower});
                }
            }
        }
    }

    IEnumerator IntervalDelay()
    {
        yield return new WaitForSeconds(sleepTime);
        trigger = false;
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.tag == "Water")
        {
            onWater = true;
            GetCurrentWater();
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Water")
        {
            onWater = false;
            ClearCurrentWater();
        }
    }
    private void OnCollisionEnter(Collision collision)
    {
        if (collision.collider.tag == "Water")
        {
            onWater = true;
            GetCurrentWater();
        }
    }
    private void OnCollisionExit(Collision collision)
    {
        if (collision.collider.tag == "Water")
        {
            onWater = false;
            ClearCurrentWater();
        }
    }


#if UNITY_EDITOR
    private void OnDrawGizmos()
	{
        Gizmos.DrawIcon(transform.position, "DCG/dcg_buoy.png", true);
        if (voxels == null || forces == null)
		{
			return;
		}
		const float gizmoSize = 0.05f;
		Gizmos.color = Color.yellow;
		foreach (var p in voxels)
		{
			Gizmos.DrawCube(transform.TransformPoint(p), new Vector3(gizmoSize, gizmoSize, gizmoSize));
		}
        Color linesColor = new Color(0.6f, 0.1f, 0.1f, 1f);
        Gizmos.color = linesColor;
		foreach (var force in forces)
		{
			Gizmos.DrawCube(force[0], new Vector3(gizmoSize, gizmoSize, gizmoSize));
			Gizmos.DrawLine(force[0], force[0] + force[1] / rb.mass);
		}
    }
    #endif
}