using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(DCGWater))]
public class DCGWaterEditor : Editor {

    public SerializedProperty
    meshSize, vertexDensity, waterProfile, enableCollision, waterDepth, triggerOffset
    ;
    private Color softGreen, softBlue, pinkishRed;
    Texture2D logoTex, backroundTex;

    void OnEnable()
    {
        meshSize = serializedObject.FindProperty("meshSize");
        vertexDensity = serializedObject.FindProperty("vertexDensity");
        waterDepth = serializedObject.FindProperty("waterDepth");
        waterProfile = serializedObject.FindProperty("waterProfile");
        enableCollision = serializedObject.FindProperty("enableCollision");
        triggerOffset = serializedObject.FindProperty("triggerOffset");

        logoTex = (Texture2D)EditorGUIUtility.Load("Assets/DeadlyCrow Games/DCG Water/Editor/img/dcg_label.png");
        backroundTex = (Texture2D)EditorGUIUtility.Load("Assets/DeadlyCrow Games/DCG Water/Editor/img/dcg_bg.png");

        softGreen = new Color(0.33f, 1f, 0.33f, 1f);
        softBlue = new Color(0.5f, 0.8f, 1f, 1f);
        pinkishRed = new Color(1f, 0.3f, 0.46f, 1f);
    }

    public override void OnInspectorGUI()
    {
        
        serializedObject.Update();

        GUI.color = pinkishRed;
        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);
        GUI.color = Color.white;

        DrawBackground();
        DrawLogo();

        EditorGUILayout.Space();
        
        GUI.color = softBlue;
        EditorGUILayout.PropertyField(meshSize, new GUIContent("Water Mesh Size"));
        EditorGUILayout.PropertyField(vertexDensity, new GUIContent("Vertex Density"));
        EditorGUILayout.PropertyField(waterDepth, new GUIContent("Water Depth"));
        EditorGUILayout.PropertyField(triggerOffset, new GUIContent("Trigger Offset"));
        GUI.color = Color.white;
        EditorGUILayout.Space();
        
        if (GUILayout.Button("Update Settings"))
        {
            DCGWater water = target as DCGWater;
            water.UpdateWater();
        }
        EditorGUILayout.Space();
        DrawUILine(Color.gray);
        EditorGUILayout.Space();
        EditorGUILayout.PropertyField(waterProfile, new GUIContent("Water Profile"));
        EditorGUILayout.Space();
        DrawUILine(Color.gray);
        EditorGUILayout.Space();
        if (enableCollision.boolValue)
        {
            GUI.color = softGreen;
            EditorGUILayout.PropertyField(enableCollision, new GUIContent("Collision Enabled"));
            GUI.color = Color.white;

            if (vertexDensity.intValue > 32)
            {
                EditorGUILayout.HelpBox("Keep in mind that high values of 'Vertex Density' will decrease the performance exponentially.", MessageType.Warning);
            }
        }
        else
        {
            GUI.color = pinkishRed;
            EditorGUILayout.PropertyField(enableCollision, new GUIContent("Collision Disabled"));
            GUI.color = Color.white;
            EditorGUILayout.HelpBox("If collision is not enabled you won't be able to use buoyancy or interact with the water.", MessageType.Info);
        }

        EditorGUILayout.Space();
        DrawUILine(Color.gray);
        GUI.color = pinkishRed;
        EditorGUILayout.LabelField("DCG Water Pro v1.0", EditorStyles.centeredGreyMiniLabel);
        EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

        serializedObject.ApplyModifiedProperties();
    }
    public static void DrawUILine(Color color, int thickness = 2, int padding = 10)
    {
        Rect r = EditorGUILayout.GetControlRect(GUILayout.Height(padding + thickness));
        r.height = thickness;
        r.y += padding / 2;
        r.x -= 2;
        r.width += 6;
        EditorGUI.DrawRect(r, color);
    }
    private void DrawLogo()
    {
        Rect rect = GUILayoutUtility.GetLastRect();
        GUI.DrawTexture(new Rect(0, rect.yMin + 20, EditorGUIUtility.currentViewWidth, 130), logoTex, ScaleMode.ScaleToFit);
        GUILayout.Space(145);
    }
    private void DrawBackground()
    {
        Rect rect = GUILayoutUtility.GetLastRect();
        GUI.color = new Color(0.6f, 0.6f, 0.6f, 1f);
        //GUI.DrawTexture(new Rect(0f, rect.yMin - (EditorGUIUtility.currentViewWidth / 2) - 18f, Screen.width, Mathf.Clamp(EditorGUIUtility.currentViewWidth * 1.6f,500, 700f)), backroundTex);
        GUI.DrawTexture(new Rect(0, rect.yMin, EditorGUIUtility.currentViewWidth, 550), backroundTex);
        GUI.color = Color.white;
    }
}
