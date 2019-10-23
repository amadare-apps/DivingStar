// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DCG/Water/Wet Lens(WIP)"
{
	Properties
	{
		[NoScaleOffset]_WetLensMap("Wet Lens Map", 2D) = "white" {}
		[NoScaleOffset]_Normal("Normal", 2D) = "bump" {}
		[Toggle]_InvertNormal("Invert Normal", Float) = 0
		_Tiling("Tiling", Range( 0 , 3)) = 1
		_Speed("Speed", Range( 0 , 1)) = 0.3
		_Intensity("Intensity", Range( 0 , 1)) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Overlay+0" "ForceNoShadowCasting" = "True" }
		Cull Back
		GrabPass{ }
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf StandardCustomLighting keepalpha noshadow exclude_path:deferred noambient novertexlights nolightmap  nodynlightmap nodirlightmap nofog nometa noforwardadd 
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPos;
		};

		struct SurfaceOutputCustomLightingCustom
		{
			half3 Albedo;
			half3 Normal;
			half3 Emission;
			half Metallic;
			half Smoothness;
			half Occlusion;
			half Alpha;
			Input SurfInput;
			UnityGIInput GIData;
		};

		uniform sampler2D _GrabTexture;
		uniform float _InvertNormal;
		uniform sampler2D _Normal;
		uniform float _Tiling;
		uniform sampler2D _WetLensMap;
		uniform float _Speed;
		uniform float _Intensity;


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


		inline half4 LightingStandardCustomLighting( inout SurfaceOutputCustomLightingCustom s, half3 viewDir, UnityGI gi )
		{
			UnityGIInput data = s.GIData;
			Input i = s.SurfInput;
			half4 c = 0;
			float3 _Vector0 = float3(0,0,1);
			float2 temp_cast_0 = (_Tiling).xx;
			float2 uv_TexCoord105 = i.uv_texcoord * temp_cast_0;
			float2 temp_cast_1 = (_Tiling).xx;
			float2 uv_TexCoord84 = i.uv_texcoord * temp_cast_1;
			float mulTime90 = _Time.y * 0.6;
			float2 appendResult93 = (float2(uv_TexCoord84.x , frac( ( uv_TexCoord84.y + ( _Speed * mulTime90 ) ) )));
			float3 lerpResult109 = lerp( _Vector0 , UnpackNormal( tex2D( _Normal, uv_TexCoord105 ) ) , saturate( ( ( tex2D( _WetLensMap, uv_TexCoord105 ).r - saturate( pow( tex2D( _WetLensMap, appendResult93 ).g , 8.0 ) ) ) * 5.0 ) ));
			float3 appendResult127 = (float3(-(lerpResult109).xy , 1.0));
			float3 lerpResult128 = lerp( _Vector0 , lerp(lerpResult109,appendResult127,_InvertNormal) , (0.0 + (_Intensity - 0.0) * (0.125 - 0.0) / (1.0 - 0.0)));
			float2 clampResult136 = clamp( (lerpResult128).xy , float2( -0.5,-0.5 ) , float2( 0.1,0.1 ) );
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float4 screenColor131 = tex2D( _GrabTexture, ( float4( clampResult136, 0.0 , 0.0 ) + ase_grabScreenPosNorm ).xy );
			c.rgb = screenColor131.rgb;
			c.a = 1;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
		}

		ENDCG
	}
	//CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15701
2777;83;1710;873;-1131.68;516.8057;1;True;True
Node;AmplifyShaderEditor.SimpleTimeNode;90;-358.9528,-884.3322;Float;False;1;0;FLOAT;0.6;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;111;-469.8921,-1237.39;Float;False;Property;_Tiling;Tiling;4;0;Create;True;0;0;False;0;1;1.3;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-481.9528,-1029.332;Float;False;Property;_Speed;Speed;5;0;Create;True;0;0;False;0;0.3;0.6;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;84;-496.4226,-921.6003;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-152.9528,-933.3322;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;92;-157.9528,-1045.332;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;89;-24.95276,-1033.332;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;81;-202.8791,-816.4799;Float;True;Property;_WetLensMap;Wet Lens Map;1;1;[NoScaleOffset];Create;True;0;0;False;0;11b1decd7a383864fa9c5fa481d77e4f;11b1decd7a383864fa9c5fa481d77e4f;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.DynamicAppendNode;93;-37.95276,-1141.332;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;82;250.4246,-829.0809;Float;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;102;645.0194,-729.5961;Float;True;2;0;FLOAT;0;False;1;FLOAT;8;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;105;-116.3938,-1389.027;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;104;652.1047,-843.4639;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;94;263.6442,-1056.332;Float;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;103;625.4041,-1092.929;Float;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;872.8449,-854.3976;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;107;1054.289,-852.4373;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;96;781.1024,-257.1466;Float;False;Constant;_Vector0;Vector 0;4;0;Create;True;0;0;False;0;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;95;674.8882,-482.8303;Float;True;Property;_Normal;Normal;2;1;[NoScaleOffset];Create;True;0;0;False;0;c0e655fec9f7745498db10bdac01f8fa;c0e655fec9f7745498db10bdac01f8fa;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;109;976.2819,-411.4752;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;114;1072.889,-251.8123;Float;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;120;1086.635,-150.3199;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;127;1325.425,-225.6938;Float;True;FLOAT3;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;116;1348.889,-769.8123;Float;False;Property;_Intensity;Intensity;6;0;Create;True;0;0;False;0;1;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;135;1633.625,-643.4406;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;0.125;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;121;1323.635,-485.3199;Float;True;Property;_InvertNormal;Invert Normal;3;0;Create;True;0;0;False;0;0;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;128;1644.458,-312.9954;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;132;1840.754,-317.9363;Float;True;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GrabScreenPosition;130;1566.72,213.6646;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;136;1768.68,-107.8057;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;-0.5,-0.5;False;2;FLOAT2;0.1,0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;133;1780.754,23.06366;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ScreenColorNode;131;2112.887,26.0296;Float;False;Global;_GrabScreen0;Grab Screen 0;8;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;123;2457.916,-346.0052;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;DCG/Water/Wet Lens(WIP);False;False;False;False;True;True;True;True;True;True;True;True;False;False;False;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;0;True;Transparent;;Overlay;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;False;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;84;0;111;0
WireConnection;91;0;85;0
WireConnection;91;1;90;0
WireConnection;92;0;84;2
WireConnection;92;1;91;0
WireConnection;89;0;92;0
WireConnection;93;0;84;1
WireConnection;93;1;89;0
WireConnection;82;0;81;0
WireConnection;82;1;93;0
WireConnection;102;0;82;2
WireConnection;105;0;111;0
WireConnection;104;0;102;0
WireConnection;94;0;81;0
WireConnection;94;1;105;0
WireConnection;103;0;94;1
WireConnection;103;1;104;0
WireConnection;106;0;103;0
WireConnection;107;0;106;0
WireConnection;95;1;105;0
WireConnection;109;0;96;0
WireConnection;109;1;95;0
WireConnection;109;2;107;0
WireConnection;114;0;109;0
WireConnection;120;0;114;0
WireConnection;127;0;120;0
WireConnection;135;0;116;0
WireConnection;121;0;109;0
WireConnection;121;1;127;0
WireConnection;128;0;96;0
WireConnection;128;1;121;0
WireConnection;128;2;135;0
WireConnection;132;0;128;0
WireConnection;136;0;132;0
WireConnection;133;0;136;0
WireConnection;133;1;130;0
WireConnection;131;0;133;0
WireConnection;123;13;131;0
ASEEND*/
//CHKSM=86BE4CC04F3908FA2DF44FBCCFB35779B296FB9F