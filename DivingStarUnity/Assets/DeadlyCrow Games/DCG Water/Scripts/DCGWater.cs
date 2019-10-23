using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using Unity.Collections;
using Unity.Jobs;

[AddComponentMenu("DCG/DCG Water")]
[RequireComponent(typeof(BoxCollider))]
[RequireComponent(typeof(MeshFilter))]
[RequireComponent(typeof(MeshRenderer))]

public class DCGWater : MonoBehaviour {

    [Range(2f, 2048f)]
    [Tooltip("This is the size of the mesh in units.")]
    public float meshSize = 64f;
    [Range(4,128)]
    [Tooltip("This property defines how dense and close are the vertices of the mesh, Be careful with the values, high values will impact your performance dramatically.")]
    public int vertexDensity = 64;
    [Tooltip("This value represents how deep is the water volume, also, sets the trigger zone area.")]
    [Range(1f, 100f)]
    public float waterDepth = 16f;
    [Tooltip("This value controls the offset of the water trigger regarding the height of the water mesh in the Y axis.")]
    [Range(0, 2f)]
    public float triggerOffset = 1f;

    [Tooltip("Here you have to input an asset file of type 'WavesPattern' which controls how the water behaves.")]
    public WaterProfile waterProfile;
    [Tooltip("Enabling collisions will allow the mesh to interact with buoyancy objects. Keep in mind that performance will decrease dramatically with collisions enabled.")]
    public bool enableCollision = false;
    MeshFilter mf;
    BoxCollider bc;

    private void Awake()
    {
        mf = GetComponent<MeshFilter>();
        bc = GetComponent<BoxCollider>();

        transform.tag = "Water";
        gameObject.layer = 4;
        bc.enabled = enableCollision;
    }
    private void Start()
    {
        CreateMesh();
        if (waterProfile)
        {
            GetComponent<MeshRenderer>().material = waterProfile.waterMaterial;
        }
        GetComponent<MeshRenderer>().shadowCastingMode =  UnityEngine.Rendering.ShadowCastingMode.Off;
        bc.enabled = enableCollision;

        UpdateWater();
    }
    private void Update()
    {
        if (waterProfile != null)
        {
            DeformMesh();
        }
    }

    private void DeformMesh()
    {
        var vertices = mf.mesh.vertices;

        ResetMeshHeight(vertices);

        ExecuteJob(vertices);

        mf.mesh.SetVertices(vertices.ToList());
        
        mf.mesh.RecalculateTangents();
        mf.mesh.RecalculateNormals();
        mf.mesh.RecalculateBounds();
    }

    private static void ResetMeshHeight(Vector3[] vertices)
    {
        for (int i = 0; i < vertices.Length; i++)
        {
            vertices[i].y = 0;
        }
    }

    private void ExecuteJob(Vector3[] vertices)
    {
        var jobHandles = new List<JobHandle>();
        var vertexArray = new NativeArray<Vector3>(vertices, Allocator.TempJob);

        for (int i = 0; i < waterProfile.wavesAttributes.Count; i++)
        {
            var job = new NoiseJob
            {
                v = vertexArray,
                nType = waterProfile.wavesAttributes[i].noiseType,
                curPos = transform.position,
                waveScale = waterProfile.wavesAttributes[i].waveScale,
                waveSpeed = waterProfile.wavesAttributes[i].waveSpeed,
                waveIntensity = waterProfile.wavesAttributes[i].waveIntensity,
                heightOffset = waterProfile.wavesAttributes[i].heightOffset,
                t = Time.timeSinceLevelLoad
            };

            if (i == 0)
            {
                jobHandles.Add(job.Schedule(vertices.Length, 250));
            }
            else
            {
                jobHandles.Add(job.Schedule(vertices.Length, 250, jobHandles[i - 1]));
            }
        }
        jobHandles.Last().Complete();

        vertexArray.CopyTo(vertices);
        vertexArray.Dispose();
    }
    public void CreateMesh()
    {
        if (mf)
        {
            Mesh tempMesh = WaterMethods.CreatePlane(vertexDensity, meshSize);
            mf.mesh = tempMesh;
           // mc.sharedMesh = mf.mesh;
        }

        UpdateWaterZone();
    }
    private void UpdateWaterZone()
    {
        if (enableCollision)
        {
            if (bc)
            {
                bc.isTrigger = true;
                bc.size = new Vector3(meshSize, waterDepth + triggerOffset, meshSize);
                bc.center = new Vector3(0, -(waterDepth / 2) + (triggerOffset/2), 0);
            }
            else
            {
                bc = GetComponent<BoxCollider>();
                bc.isTrigger = true;
                bc.size = new Vector3(meshSize, waterDepth + triggerOffset, meshSize);
                bc.center = new Vector3(0, -(waterDepth / 2) + (triggerOffset/2), 0);
            }
        }
    }
    public void UpdateWater()
    {
        CreateMesh();
        if (waterProfile)
        {
            GetComponent<MeshRenderer>().material = waterProfile.waterMaterial;
        }
        UpdateWaterZone();
    }

    public void UpdateWaterMaterial (bool isUnderWater)
    {
        if (waterProfile.backfaceMaterial)
        {
            GetComponent<MeshRenderer>().material = (isUnderWater) ? waterProfile.backfaceMaterial : waterProfile.waterMaterial;
        }
    }

    #if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        //water gizmo

        Gizmos.color = new Color(0.2f, 0.6f, 1f, 0.66f);

        Vector3 waterBox = new Vector3(meshSize, waterDepth, meshSize);
        Vector3 waterCenter = new Vector3(transform.position.x, transform.position.y - (waterDepth / 2), transform.position.z);

        if (!Application.isPlaying)
        {
            Gizmos.DrawCube(waterCenter, waterBox);
        }
        Gizmos.DrawWireCube(waterCenter, waterBox);

        // trigger gizmo
        if (triggerOffset > 0.025f)
        {
            Vector3 triggerBox = new Vector3(meshSize, triggerOffset, meshSize);
            Vector3 triggerCenter = new Vector3(transform.position.x, transform.position.y + (triggerOffset / 2), transform.position.z);
            Gizmos.color = new Color(0.25f, 1f, 0.4f, 0.25f);

            if (!Application.isPlaying)
            {
                Gizmos.DrawCube(triggerCenter, triggerBox);
            }
            Gizmos.DrawWireCube(triggerCenter, triggerBox);
        }

        Gizmos.DrawIcon(transform.position, "DCG/dcg_water.png", true);
    }
    #endif
}