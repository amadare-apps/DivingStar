// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DCG/Water/Simple Distortion"
{
	Properties
	{
		[NoScaleOffset][Normal]_WaterNormal("Water Normal", 2D) = "bump" {}
		_NormalPower("Normal Power", Range( 0 , 1)) = 0.3
		_WaterTiling("Water Tiling", Range( 0.01 , 20)) = 0
		_WaterSpeed("Water Speed", Range( 0.01 , 20)) = 0
		_RefractionDistortion("Refraction Distortion", Range( 0 , 0.5)) = 0.1
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Front
		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha
		
		GrabPass{ }
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows noshadow exclude_path:deferred noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
		};

		uniform sampler2D _GrabTexture;
		uniform sampler2D _WaterNormal;
		uniform float _WaterSpeed;
		uniform float _WaterTiling;
		uniform float _NormalPower;
		uniform float _RefractionDistortion;


		inline float4 ASE_ComputeGrabScreenPos( float4 pos )
		{
			#if UNITY_UV_STARTS_AT_TOP
			float scale = -1.0;
			#else
			float scale = 1.0;
			#endif
			float4 o = pos;
			o.y = pos.w * 0.5f;
			o.y = ( pos.y - o.y ) * _ProjectionParams.x * scale + o.y;
			return o;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float temp_output_8_0_g46 = _WaterSpeed;
			float2 temp_cast_0 = (temp_output_8_0_g46).xx;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult2_g45 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 ifLocalVar21_g45 = 0;
			if( 0.0 <= 0.0 )
				ifLocalVar21_g45 = appendResult2_g45;
			else
				ifLocalVar21_g45 = ( 1.0 - appendResult2_g45 );
			float2 temp_output_7_0_g45 = ( ifLocalVar21_g45 * 0.01 * _WaterTiling );
			float2 panner1_g46 = ( 0.025 * _Time.y * temp_cast_0 + temp_output_7_0_g45);
			float2 temp_cast_1 = (-temp_output_8_0_g46).xx;
			float2 panner2_g46 = ( 0.025 * _Time.y * temp_cast_1 + ( ( temp_output_7_0_g45 * 0.77 ) + float2( 0.33,0.66 ) ));
			float3 lerpResult224 = lerp( UnpackNormal( tex2D( _WaterNormal, panner1_g46 ) ) , UnpackNormal( tex2D( _WaterNormal, panner2_g46 ) ) , 0.5);
			float3 lerpResult283 = lerp( float3(0,0,1) , lerpResult224 , _NormalPower);
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor576 = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD( ( float4( ( (lerpResult283).xy * _RefractionDistortion ), 0.0 , 0.0 ) + ase_grabScreenPosNorm ) ) );
			o.Albedo = screenColor576.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	//CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15701
1974;125;1710;813;477.0129;19.38226;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;288;-3094.875,297.8904;Float;False;689.1088;400.7664;;4;244;482;376;251;Water Scale & Speed;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;244;-3040.238,371.2808;Float;False;Property;_WaterTiling;Water Tiling;3;0;Create;True;0;0;False;0;0;1;0.01;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;482;-2733.239,376.2808;Float;False;WorldSpaceCoordDual;-1;;45;39024daf4a9269e428da367a6e63e26b;0;2;15;FLOAT;0;False;20;FLOAT;0;False;2;FLOAT2;0;FLOAT2;16
Node;AmplifyShaderEditor.CommentaryNode;237;-2265.282,251.5756;Float;False;1503.061;593.7805;;9;257;283;284;224;285;221;220;493;581;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;251;-3059.238,599.2813;Float;False;Property;_WaterSpeed;Water Speed;4;0;Create;True;0;0;False;0;0;2;0.01;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;493;-2149.705,377.547;Float;True;Property;_WaterNormal;Water Normal;0;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;b429e7be19ccbbb49b6e14b80e122225;b429e7be19ccbbb49b6e14b80e122225;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FunctionNode;376;-2740.239,506.2808;Float;False;DualPanner;-1;;46;493d5f6edc56fb549b8eb8a84e9af86c;0;3;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT;0;False;2;FLOAT2;0;FLOAT2;9
Node;AmplifyShaderEditor.SamplerNode;221;-1670.803,502.5762;Float;True;Property;_TextureSample3;Texture Sample 3;19;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;220;-1673.803,301.5758;Float;True;Property;_TextureSample2;Texture Sample 2;18;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;581;-1270.897,694.2803;Float;False;Constant;_Float1;Float 1;7;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;224;-1350.826,506.4681;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;285;-1652.242,732.5045;Float;False;Property;_NormalPower;Normal Power;1;0;Create;True;0;0;False;0;0.3;0.3;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;284;-1347.069,329.8371;Float;False;Constant;_Vector4;Vector 4;19;0;Create;True;0;0;False;0;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;283;-1146.8,485.0092;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;63;-668.0993,245.1729;Float;False;636.2994;528.6482;;5;517;45;44;43;518;Refr. Distortion;1,1,1,1;0;0
Node;AmplifyShaderEditor.RelayNode;257;-927.1046,483.5203;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-639.1942,421.0488;Float;False;Property;_RefractionDistortion;Refraction Distortion;5;0;Create;True;0;0;False;0;0.1;0.17;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;518;-647.3439,298.5786;Float;False;True;True;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GrabScreenPosition;517;-619.343,516.5778;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-340.016,302.3054;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;580;39.79628,225.8842;Float;False;429.2048;387.45;;1;576;Screen Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-179.0367,303.3867;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;576;132.0885,328.0401;Float;False;Global;_GrabScreen0;Grab Screen 0;3;0;Create;True;0;0;True;0;Object;-1;False;True;1;0;FLOAT4;0,0,0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;576.1409,350.5142;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;DCG/Water/Simple Distortion;False;False;False;False;True;True;True;True;True;True;True;True;False;False;True;False;False;False;False;False;Front;1;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;AlphaTest;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;1;False;-1;1;False;-1;1;False;-1;7;False;-1;3;False;-1;2;False;-1;2;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;50;10;25;True;1;False;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;2;0;-1;-1;0;False;0;0;False;-1;0;0;False;-1;0;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;482;15;244;0
WireConnection;376;6;482;0
WireConnection;376;7;482;16
WireConnection;376;8;251;0
WireConnection;221;0;493;0
WireConnection;221;1;376;9
WireConnection;220;0;493;0
WireConnection;220;1;376;0
WireConnection;224;0;220;0
WireConnection;224;1;221;0
WireConnection;224;2;581;0
WireConnection;283;0;284;0
WireConnection;283;1;224;0
WireConnection;283;2;285;0
WireConnection;257;0;283;0
WireConnection;518;0;257;0
WireConnection;43;0;518;0
WireConnection;43;1;44;0
WireConnection;45;0;43;0
WireConnection;45;1;517;0
WireConnection;576;0;45;0
WireConnection;0;0;576;0
ASEEND*/
//CHKSM=3ECDDBFA1F5187FBAC20CE0CD7CD4C69545E0363