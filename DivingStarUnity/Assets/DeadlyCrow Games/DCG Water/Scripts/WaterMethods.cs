using UnityEngine;
using UnityEditor;
using Unity.Collections;
using Unity.Jobs;

public struct NoiseJob : IJobParallelFor
{
    public NativeArray<Vector3> v;

    public Noise_type nType;
    public Vector3 curPos;
    public float waveScale;
    public float waveSpeed;
    public float waveIntensity;
    public float heightOffset;
    public float t;

    public void Execute(int i)
    {
        var vertex = v[i];
        var x = (vertex.x + curPos.x) * waveScale + (t * waveSpeed * 20f);
        var z = (vertex.z + curPos.z) * waveScale + (t * waveSpeed * 20f);

        float tempNoiseValue = 0;

        float offset = 1f;

        switch (nType)
        {
            case Noise_type.Perlin:
                tempNoiseValue = (Mathf.PerlinNoise(x*0.01f,z*0.01f)-0.5f) * waveIntensity+ heightOffset;
                break;
            case Noise_type.SineX:
                tempNoiseValue = (Mathf.Sin(x * 0.015f) + offset) * waveIntensity * 0.5f + heightOffset;
                break;
            case Noise_type.SineZ:
                tempNoiseValue = (Mathf.Sin(z * 0.015f) + offset) * waveIntensity * 0.5f + heightOffset;
                break;
            case Noise_type.WorldRadial:
                float r = Mathf.Sqrt(Vector3.Dot(vertex+curPos, vertex+curPos));
                tempNoiseValue = (Mathf.Sin(waveScale * 0.005f * r + waveSpeed * t) + offset) * waveIntensity * 0.5f + heightOffset;
                break;
            case Noise_type.LocalRadial:
                float r2 = Mathf.Sqrt(Vector3.Dot(vertex, vertex));
                tempNoiseValue = (Mathf.Sin(waveScale * 0.005f * r2 + waveSpeed * t) + offset) * waveIntensity * 0.5f + heightOffset;
                break;
        }
        vertex.y += tempNoiseValue;
        v[i] = vertex;
    }
}

public static class WaterMethods
{
#if UNITY_EDITOR

    [MenuItem("GameObject/3D Object/DCG Water", false,10)]
    static void CreateHellfrostWater(UnityEditor.MenuCommand menuCommand)
    {
        int curIndex = Object.FindObjectsOfType<DCGWater>().Length + 1;
        string name = "DCG Water Instance " + curIndex;

        GameObject go = new GameObject(name);
        go.AddComponent<DCGWater>();
        go.GetComponent<BoxCollider>().isTrigger = true;
        go.layer = 4;
        go.tag = "Water";
        GameObjectUtility.SetParentAndAlign(go, menuCommand.context as GameObject);

        Undo.RegisterCreatedObjectUndo(go, "Create " + go.name);
        Selection.activeObject = go;
    }
#endif

    //noise functions

    public static float GetRadialNoise(float t, float speed, Vector2 v, float scale, float offset)
    {
        float tempNoise = Mathf.Sin(t * speed + ((v.x * v.x) + (v.y * v.y)) * (scale * 0.000013f)) + offset + 0.45f;
        return tempNoise;
    }

    //

    public static Mesh CreatePlane(int size, float distance)
    {
        int widthSegments = size;
        int lengthSegments = size;
        float width = distance;
        float length = distance;

        Mesh m = new Mesh();

        int hCount2 = widthSegments + 1;
        int vCount2 = lengthSegments + 1;
        int numTriangles = widthSegments * lengthSegments * 6;

        int numVertices = hCount2 * vCount2;

        Vector3[] vertices = new Vector3[numVertices];
        Vector2[] uvs = new Vector2[numVertices];
        int[] triangles = new int[numTriangles];
        Vector4[] tangents = new Vector4[numVertices];
        Vector4 tangent = new Vector4(1f, 0f, 0f, -1f);

        int index = 0;
        float uvFactorX = 1.0f / widthSegments;
        float uvFactorY = 1.0f / lengthSegments;
        float scaleX = width / widthSegments;
        float scaleY = length / lengthSegments;
        for (float y = 0.0f; y < vCount2; y++)
        {
            for (float x = 0.0f; x < hCount2; x++)
            {
                vertices[index] = new Vector3(x * scaleX - width / 2f, 0.0f, y * scaleY - length / 2f);
                tangents[index] = tangent;
                uvs[index++] = new Vector2(x * uvFactorX, y * uvFactorY);
            }
        }

        index = 0;
        for (int y = 0; y < lengthSegments; y++)
        {
            for (int x = 0; x < widthSegments; x++)
            {
                triangles[index] = (y * hCount2) + x;
                triangles[index + 1] = ((y + 1) * hCount2) + x;
                triangles[index + 2] = (y * hCount2) + x + 1;

                triangles[index + 3] = ((y + 1) * hCount2) + x;
                triangles[index + 4] = ((y + 1) * hCount2) + x + 1;
                triangles[index + 5] = (y * hCount2) + x + 1;
                index += 6;
            }
        }

        m.vertices = vertices;
        m.uv = uvs;
        m.triangles = triangles;
        m.tangents = tangents;

        m.RecalculateTangents();
        m.RecalculateNormals();
        
        return m;
    }
    
}

public enum Noise_type
{
   Perlin, SineX, SineZ, WorldRadial, LocalRadial
}

[System.Serializable]
public class WavesAttributes
{
    public Noise_type noiseType;
    [Range(0.01f, 20f)]
    public float waveScale = 0.1f;
    [Range(-20f, 20f)]
    public float waveSpeed = 0.6f;
    [Range(0.01f, 20f)]
    public float waveIntensity = 1f;
    [Range(-3f, 3f)]
    public float heightOffset = 0f;
}



