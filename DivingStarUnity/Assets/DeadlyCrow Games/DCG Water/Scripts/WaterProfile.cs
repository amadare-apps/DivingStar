using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "New Water Profile", menuName ="DCG/Water Profile")]
public class WaterProfile : ScriptableObject {
    public Material waterMaterial;
    public Material backfaceMaterial;
    public List<WavesAttributes> wavesAttributes;
}