// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DCG/Water/Underwater(WIP)"
{
	Properties
	{
		_Density("Density", Range( 0 , 1)) = 0.3
		_Tint("Tint", Color) = (0.5518868,0.9083078,1,0)
		_WaterEmission("Water Emission", Range( 0 , 1)) = 0.3
		[NoScaleOffset][Normal]_Normal("Normal", 2D) = "bump" {}
		_DistortionTiling("Distortion Tiling", Range( 0 , 6)) = 1
		_DistortionSpeed("Distortion Speed", Range( 0 , 6)) = 1
		_DistortionIntensity("Distortion Intensity", Range( 0 , 1)) = 0.33
		_ChromaticAberration("Chromatic Aberration", Range( 0 , 0.33)) = 0.1
		_ScatteringSpread("Scattering Spread", Range( 0 , 1)) = 0.3
		_ScatteringPower("Scattering Power", Range( 0 , 1)) = 0.4
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" "IgnoreProjector" = "True" }
		Cull Back
		GrabPass{ }
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float4 screenPos;
			float2 uv_texcoord;
			float3 worldPos;
			float3 viewDir;
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
		uniform sampler2D _Normal;
		uniform float _DistortionSpeed;
		uniform float _DistortionTiling;
		uniform float _DistortionIntensity;
		uniform sampler2D _CameraDepthTexture;
		uniform float _ChromaticAberration;
		uniform float4 _Tint;
		uniform float _WaterEmission;
		uniform float _Density;
		uniform float _ScatteringSpread;
		uniform float _ScatteringPower;


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
			#ifdef UNITY_PASS_FORWARDBASE
			float ase_lightAtten = data.atten;
			if( _LightColor0.a == 0)
			ase_lightAtten = 0;
			#else
			float3 ase_lightAttenRGB = gi.light.color / ( ( _LightColor0.rgb ) + 0.000001 );
			float ase_lightAtten = max( max( ase_lightAttenRGB.r, ase_lightAttenRGB.g ), ase_lightAttenRGB.b );
			#endif
			#if defined(HANDLE_SHADOWS_BLENDING_IN_GI)
			half bakedAtten = UnitySampleBakedOcclusion(data.lightmapUV.xy, data.worldPos);
			float zDist = dot(_WorldSpaceCameraPos - data.worldPos, UNITY_MATRIX_V[2].xyz);
			float fadeDist = UnityComputeShadowFadeDistance(data.worldPos, zDist);
			ase_lightAtten = UnityMixRealtimeAndBakedShadows(data.atten, bakedAtten, UnityComputeShadowFade(fadeDist));
			#endif
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float temp_output_8_0_g1 = _DistortionSpeed;
			float2 temp_cast_0 = (temp_output_8_0_g1).xx;
			float2 temp_cast_1 = (_DistortionTiling).xx;
			float2 uv_TexCoord29 = i.uv_texcoord * temp_cast_1;
			float2 panner1_g1 = ( 0.015 * _Time.y * temp_cast_0 + uv_TexCoord29);
			float2 temp_cast_2 = (-temp_output_8_0_g1).xx;
			float2 panner2_g1 = ( 0.015 * _Time.y * temp_cast_2 + ( ( uv_TexCoord29 * 0.8 ) + float2( 0.33,0.66 ) ));
			float3 lerpResult27 = lerp( UnpackNormal( tex2D( _Normal, panner1_g1 ) ) , UnpackNormal( tex2D( _Normal, panner2_g1 ) ) , 0.5);
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth53 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos ))));
			float distanceDepth53 = saturate( abs( ( screenDepth53 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( 6.0 ) ) );
			float clampResult80 = clamp( distanceDepth53 , 0.66 , 1.0 );
			float3 lerpResult30 = lerp( float3(0,0,1) , lerpResult27 , ( _DistortionIntensity * clampResult80 ));
			float4 temp_output_35_0 = ( ase_grabScreenPosNorm + float4( (lerpResult30).xy, 0.0 , 0.0 ) );
			float screenDepth44 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos ))));
			float distanceDepth44 = saturate( abs( ( screenDepth44 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( 9.0 ) ) );
			float clampResult46 = clamp( distanceDepth44 , 0.66 , 1.0 );
			float temp_output_45_0 = ( _ChromaticAberration * clampResult46 );
			float4 screenColor12 = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD( ( temp_output_35_0 + float4( ( float2( 0.1,0.1 ) * temp_output_45_0 ), 0.0 , 0.0 ) ) ) );
			float4 screenColor6 = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD( temp_output_35_0 ) );
			float4 screenColor13 = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD( ( temp_output_35_0 + float4( ( float2( -0.1,-0.1 ) * temp_output_45_0 ), 0.0 , 0.0 ) ) ) );
			float3 appendResult43 = (float3(screenColor12.r , screenColor6.g , screenColor13.b));
			float screenDepth2 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos ))));
			float distanceDepth2 = saturate( abs( ( screenDepth2 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( (200.0 + (_Density - 0.0) * (0.33 - 200.0) / (1.0 - 0.0)) ) ) );
			float4 lerpResult3 = lerp( ( float4( ( saturate( appendResult43 ) * 0.88 ) , 0.0 ) * _Tint ) , ( _Tint * _WaterEmission * 0.3 ) , distanceDepth2);
			float3 ase_worldPos = i.worldPos;
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult4_g3 = normalize( ( i.viewDir + ase_worldlightDir ) );
			float dotResult62 = dot( ase_worldlightDir , normalizeResult4_g3 );
			float clampResult73 = clamp( _ScatteringSpread , 0.3 , 1.0 );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			c.rgb = ( ( saturate( lerpResult3 ) + ( ( ( saturate( pow( ( 1.0 - dotResult62 ) , (36.0 + (_ScatteringSpread - 0.0) * (3.0 - 36.0) / (1.0 - 0.0)) ) ) * clampResult73 ) * ase_lightColor * ase_lightAtten * _Tint ) * _ScatteringPower ) ) * ase_lightColor * ase_lightAtten ).rgb;
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
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.screenPos = ComputeScreenPos( o.pos );
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.screenPos = IN.screenPos;
				SurfaceOutputCustomLightingCustom o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputCustomLightingCustom, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	//CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15701
2120;171;1710;867;1633.533;1853.056;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;33;-3923.907,-1813.18;Float;False;2075.253;1013.634;;19;22;29;21;23;25;24;26;19;16;28;17;18;27;32;31;30;53;54;80;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;22;-3873.907,-1731.849;Float;False;Property;_DistortionTiling;Distortion Tiling;5;0;Create;True;0;0;False;0;1;1.3;0;6;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-3598.286,-1441.589;Float;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;False;0;0.8;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;29;-3528.325,-1763.18;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;25;-3615.286,-1366.589;Float;False;Constant;_Vector0;Vector 0;5;0;Create;True;0;0;False;0;0.33,0.66;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-3326.286,-1554.589;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-3672.286,-1187.589;Float;False;Property;_DistortionSpeed;Distortion Speed;6;0;Create;True;0;0;False;0;1;6;0;6;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;24;-3321.286,-1446.589;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DepthFade;53;-2803.734,-906.0344;Float;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;6;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;16;-3266.302,-1274.91;Float;True;Property;_Normal;Normal;4;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;c41ceb0f1289bec4280ef41116759b31;c41ceb0f1289bec4280ef41116759b31;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.FunctionNode;19;-3118.867,-1674.989;Float;False;DualPanner;-1;;1;493d5f6edc56fb549b8eb8a84e9af86c;0;3;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT;0;False;2;FLOAT2;0;FLOAT2;9
Node;AmplifyShaderEditor.RangedFloatNode;28;-2433.895,-1145.509;Float;False;Constant;_Float2;Float 2;6;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-2791.548,-1019.846;Float;False;Property;_DistortionIntensity;Distortion Intensity;7;0;Create;True;0;0;False;0;0.33;0.05;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;17;-2765.292,-1446.319;Float;True;Property;_TextureSample0;Texture Sample 0;4;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;80;-2387.366,-938.0923;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.66;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;18;-2776.945,-1220.802;Float;True;Property;_TextureSample1;Texture Sample 1;4;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;27;-2383.723,-1346.255;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-2284.842,-1041.45;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;44;-2444.93,-269.3764;Float;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;9;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;31;-2618.335,-1628.063;Float;False;Constant;_Vector1;Vector 1;6;0;Create;True;0;0;False;0;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;42;-2303.85,-396.5356;Float;False;Property;_ChromaticAberration;Chromatic Aberration;8;0;Create;True;0;0;False;0;0.1;0.066;0;0.33;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;30;-2084.032,-1477.158;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;46;-2139.93,-225.3764;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.66;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;14;-1704.904,-1597.482;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;39;-2085.569,-631.7955;Float;False;Constant;_Vector3;Vector 3;7;0;Create;True;0;0;False;0;-0.1,-0.1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;38;-2094.057,-759.1265;Float;False;Constant;_Vector2;Vector 2;7;0;Create;True;0;0;False;0;0.1,0.1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-1889.93,-277.3764;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;34;-1780.259,-1260.334;Float;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1783.611,-549.3329;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-1790.887,-711.8317;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;35;-1291.199,-1385.288;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;58;-1011.692,-1767.786;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;36;-1616.264,-933.7532;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.FunctionNode;66;-1379.875,-1629.706;Float;False;Blinn-Phong Half Vector;-1;;3;91a149ac9d615be429126c95e20753ce;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;-1601.712,-601.4794;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DotProductOpNode;62;-782.7867,-1633.238;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;13;-1473.019,-650.3726;Float;False;Global;_GrabScreen2;Grab Screen 2;1;0;Create;True;0;0;False;0;Instance;6;False;True;1;0;FLOAT4;0,0,0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;70;-754.6343,-1461.245;Float;False;Property;_ScatteringSpread;Scattering Spread;9;0;Create;True;0;0;False;0;0.3;0.9;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;6;-1463.42,-986.8187;Float;False;Global;_GrabScreen0;Grab Screen 0;1;0;Create;True;0;0;False;0;Object;-1;False;True;1;0;FLOAT4;0,0,0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;12;-1479.019,-818.3726;Float;False;Global;_GrabScreen1;Grab Screen 1;1;0;Create;True;0;0;False;0;Instance;6;False;True;1;0;FLOAT4;0,0,0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;43;-1197.429,-756.384;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;64;-644.7869,-1631.238;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;71;-401.6342,-1234.245;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;36;False;4;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;-1467.833,24.62967;Float;False;Property;_Density;Density;1;0;Create;True;0;0;False;0;0.3;0.86;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-1147.775,-600.9496;Float;False;Constant;_Float3;Float 3;10;0;Create;True;0;0;False;0;0.88;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;69;-412.6342,-1716.246;Float;False;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;60;-996.9035,-805.6985;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;7;-938.0547,-457.9031;Float;False;Property;_Tint;Tint;2;0;Create;True;0;0;False;0;0.5518868,0.9083078,1,0;0.429245,0.8041291,1,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;73;-379.6344,-1493.245;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;11;-1028.794,-182.6094;Float;False;Constant;_Float0;Float 0;3;0;Create;True;0;0;False;0;0.3;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1153.794,-264.6094;Float;False;Property;_WaterEmission;Water Emission;3;0;Create;True;0;0;False;0;0.3;0.66;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;68;-428.7869,-1896.237;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;5;-1157,73;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;200;False;4;FLOAT;0.33;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;56;-816.7747,-652.9496;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LightColorNode;75;-153.6652,-1432.249;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-655.7943,-340.6094;Float;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-474.7943,-567.6094;Float;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DepthFade;2;-937,5;Float;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;33;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;76;-190.665,-1316.624;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-106.916,-1570.87;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;3;-395,-115;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0.01176471,0.02352941,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;190.8645,-1449.715;Float;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-4.093445,-970.693;Float;False;Property;_ScatteringPower;Scattering Power;10;0;Create;True;0;0;False;0;0.4;0.8;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;55;-193.8796,-158.242;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;390.9066,-1098.693;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;50;-298.5134,115.5878;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;51;-332.5134,241.5878;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;173.5106,-287.3153;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;83;-1083.533,-1561.056;Float;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;49;125.8967,-46.91299;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;52;381.3888,-268.744;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;DCG/Water/Underwater(WIP);False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;29;0;22;0
WireConnection;23;0;29;0
WireConnection;23;1;21;0
WireConnection;24;0;23;0
WireConnection;24;1;25;0
WireConnection;19;6;29;0
WireConnection;19;7;24;0
WireConnection;19;8;26;0
WireConnection;17;0;16;0
WireConnection;17;1;19;0
WireConnection;80;0;53;0
WireConnection;18;0;16;0
WireConnection;18;1;19;9
WireConnection;27;0;17;0
WireConnection;27;1;18;0
WireConnection;27;2;28;0
WireConnection;54;0;32;0
WireConnection;54;1;80;0
WireConnection;30;0;31;0
WireConnection;30;1;27;0
WireConnection;30;2;54;0
WireConnection;46;0;44;0
WireConnection;45;0;42;0
WireConnection;45;1;46;0
WireConnection;34;0;30;0
WireConnection;41;0;39;0
WireConnection;41;1;45;0
WireConnection;40;0;38;0
WireConnection;40;1;45;0
WireConnection;35;0;14;0
WireConnection;35;1;34;0
WireConnection;36;0;35;0
WireConnection;36;1;40;0
WireConnection;37;0;35;0
WireConnection;37;1;41;0
WireConnection;62;0;58;0
WireConnection;62;1;66;0
WireConnection;13;0;37;0
WireConnection;6;0;35;0
WireConnection;12;0;36;0
WireConnection;43;0;12;1
WireConnection;43;1;6;2
WireConnection;43;2;13;3
WireConnection;64;0;62;0
WireConnection;71;0;70;0
WireConnection;69;0;64;0
WireConnection;69;1;71;0
WireConnection;60;0;43;0
WireConnection;73;0;70;0
WireConnection;68;0;69;0
WireConnection;5;0;4;0
WireConnection;56;0;60;0
WireConnection;56;1;57;0
WireConnection;9;0;7;0
WireConnection;9;1;10;0
WireConnection;9;2;11;0
WireConnection;8;0;56;0
WireConnection;8;1;7;0
WireConnection;2;0;5;0
WireConnection;72;0;68;0
WireConnection;72;1;73;0
WireConnection;3;0;8;0
WireConnection;3;1;9;0
WireConnection;3;2;2;0
WireConnection;74;0;72;0
WireConnection;74;1;75;0
WireConnection;74;2;76;0
WireConnection;74;3;7;0
WireConnection;55;0;3;0
WireConnection;78;0;74;0
WireConnection;78;1;79;0
WireConnection;77;0;55;0
WireConnection;77;1;78;0
WireConnection;49;0;77;0
WireConnection;49;1;50;0
WireConnection;49;2;51;0
WireConnection;52;13;49;0
ASEEND*/
//CHKSM=F313F6B4F9CF484A29A1E29611D8DF473A4A60A7