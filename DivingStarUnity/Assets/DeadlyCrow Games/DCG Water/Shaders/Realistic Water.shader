// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DCG/Water/Realistic Water"
{
	Properties
	{
		[HideInInspector]_ReflectionTex("ReflectionTex", 2D) = "black" {}
		_EdgeLength ( "Edge length", Range( 2, 50 ) ) = 2
		_TessPhongStrength( "Phong Tess Strength", Range( 0, 1 ) ) = 1
		_ShoreBlendDistance("Shore Blend Distance", Range( 0 , 3)) = 0.02
		[NoScaleOffset][Normal]_WaterNormal("Water Normal", 2D) = "bump" {}
		_NormalPower("Normal Power", Range( 0 , 1)) = 0
		_LargerWavesNormalPower("Larger Waves Normal Power", Range( 0 , 1)) = 1
		_Gloss("Gloss", Range( 0.01 , 1)) = 0.88
		_SpecularPower("Specular Power", Float) = 0.88
		_WaterTiling("Water Tiling", Range( 0.01 , 20)) = 0
		[Toggle]_InvertCoordinates("Invert Coordinates", Float) = 0
		_WaterSpeed("Water Speed", Range( 0.01 , 20)) = 0
		_WaterTint("Water Tint", Color) = (0.5235849,0.8924802,1,1)
		_ScatteringTint("Scattering Tint", Color) = (1,1,1,0)
		_Density("Density", Range( 0.1 , 1.5)) = 0.01
		_WaterEmission("Water Emission", Range( 0 , 1)) = 0.2
		_ScatteringIntensity("Scattering Intensity", Range( 0 , 6)) = 0.45
		_ScatteringOffset("Scattering Offset", Range( -6 , 6)) = -1
		[NoScaleOffset]_WaterHeight("Water Height", 2D) = "white" {}
		_Displacement("Displacement", Range( 0 , 10)) = 1
		_HeightOffset("Height Offset", Range( -5 , 5)) = 0
		[Toggle]_UseScriptReflection("Use Script Reflection", Float) = 1
		_ReflectionFresnel("Reflection Fresnel", Range( 1 , 10)) = 0
		_ReflectionDistortion("Reflection Distortion", Range( 0 , 0.5)) = 0.1
		_RefractionDistortion("Refraction Distortion", Range( 0 , 0.5)) = 0.1
		_RefractionChromaticAberration("Refraction Chromatic Aberration", Range( 0 , 0.15)) = 0
		[NoScaleOffset]_Foam("Foam", 2D) = "white" {}
		_FoamTiling("Foam Tiling", Range( 0.01 , 20)) = 2
		_FoamSpeed("Foam Speed", Range( 0 , 20)) = 2
		_FoamDistance("Foam Distance", Range( 0 , 6)) = 1.5
		_FoamIntensity("Foam Intensity", Range( 0 , 2)) = 0
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+150" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" }
		Cull Back
		ZWrite On
		Blend SrcAlpha OneMinusSrcAlpha
		
		GrabPass{ }
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "Tessellation.cginc"
		#pragma target 4.6
		#pragma surface surf StandardCustomLighting keepalpha vertex:vertexDataFunc tessellate:tessFunction tessphong:_TessPhongStrength 
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldRefl;
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

		uniform sampler2D _WaterHeight;
		uniform float _WaterSpeed;
		uniform float _InvertCoordinates;
		uniform float _WaterTiling;
		uniform float _LargerWavesNormalPower;
		uniform float _HeightOffset;
		uniform float _Displacement;
		uniform sampler2D _CameraDepthTexture;
		uniform float _ShoreBlendDistance;
		uniform float _UseScriptReflection;
		uniform sampler2D _WaterNormal;
		uniform float _NormalPower;
		uniform float _Gloss;
		uniform sampler2D _ReflectionTex;
		uniform float _ReflectionDistortion;
		uniform float _ReflectionFresnel;
		uniform float _ScatteringOffset;
		uniform float4 _ScatteringTint;
		uniform float _ScatteringIntensity;
		uniform float _WaterEmission;
		uniform sampler2D _Foam;
		uniform float _FoamSpeed;
		uniform float _FoamTiling;
		uniform float _FoamDistance;
		uniform float _FoamIntensity;
		uniform float _Density;
		uniform float4 _WaterTint;
		uniform sampler2D _GrabTexture;
		uniform float _RefractionDistortion;
		uniform float _RefractionChromaticAberration;
		uniform float _SpecularPower;
		uniform float _EdgeLength;
		uniform float _TessPhongStrength;


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


		float4 tessFunction( appdata_full v0, appdata_full v1, appdata_full v2 )
		{
			return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
		}

		void vertexDataFunc( inout appdata_full v )
		{
			float temp_output_8_0_g61 = _WaterSpeed;
			float2 temp_cast_0 = (temp_output_8_0_g61).xx;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult2_g59 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 ifLocalVar21_g59 = 0;
			if( lerp(0.0,1.0,_InvertCoordinates) <= 0.0 )
				ifLocalVar21_g59 = appendResult2_g59;
			else
				ifLocalVar21_g59 = ( 1.0 - appendResult2_g59 );
			float2 temp_output_7_0_g59 = ( ifLocalVar21_g59 * 0.0066 * _WaterTiling );
			float2 panner1_g61 = ( 0.015 * _Time.y * temp_cast_0 + temp_output_7_0_g59);
			float2 temp_output_568_0 = panner1_g61;
			float2 temp_cast_1 = (-temp_output_8_0_g61).xx;
			float2 panner2_g61 = ( 0.015 * _Time.y * temp_cast_1 + ( ( temp_output_7_0_g59 * 0.77 ) + float2( 0.33,0.66 ) ));
			float2 temp_output_568_9 = panner2_g61;
			float lerpResult496 = lerp( tex2Dlod( _WaterHeight, float4( temp_output_568_0, 0, 0.0) ).r , tex2Dlod( _WaterHeight, float4( temp_output_568_9, 0, 0.0) ).r , 0.5);
			float2 temp_output_486_0 = ( temp_output_568_0 * 0.15 );
			float2 temp_output_487_0 = ( temp_output_568_9 * 0.15 );
			float lerpResult559 = lerp( tex2Dlod( _WaterHeight, float4( temp_output_486_0, 0, 0.0) ).r , tex2Dlod( _WaterHeight, float4( temp_output_487_0, 0, 0.0) ).r , 0.5);
			float temp_output_498_0 = saturate( ( lerpResult496 + ( lerpResult559 * _LargerWavesNormalPower ) ) );
			float3 ase_worldNormal = UnityObjectToWorldNormal( v.normal );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			v.vertex.xyz += ( ( temp_output_498_0 + _HeightOffset ) * ase_normWorldNormal * _Displacement );
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
			float4 ase_screenPosNorm = ase_screenPos / ase_screenPos.w;
			ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
			float screenDepth100 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos ))));
			float distanceDepth100 = saturate( abs( ( screenDepth100 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _ShoreBlendDistance ) ) );
			float temp_output_8_0_g61 = _WaterSpeed;
			float2 temp_cast_0 = (temp_output_8_0_g61).xx;
			float3 ase_worldPos = i.worldPos;
			float2 appendResult2_g59 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 ifLocalVar21_g59 = 0;
			if( lerp(0.0,1.0,_InvertCoordinates) <= 0.0 )
				ifLocalVar21_g59 = appendResult2_g59;
			else
				ifLocalVar21_g59 = ( 1.0 - appendResult2_g59 );
			float2 temp_output_7_0_g59 = ( ifLocalVar21_g59 * 0.0066 * _WaterTiling );
			float2 panner1_g61 = ( 0.015 * _Time.y * temp_cast_0 + temp_output_7_0_g59);
			float2 temp_output_568_0 = panner1_g61;
			float2 temp_cast_1 = (-temp_output_8_0_g61).xx;
			float2 panner2_g61 = ( 0.015 * _Time.y * temp_cast_1 + ( ( temp_output_7_0_g59 * 0.77 ) + float2( 0.33,0.66 ) ));
			float2 temp_output_568_9 = panner2_g61;
			float3 lerpResult224 = lerp( UnpackNormal( tex2D( _WaterNormal, temp_output_568_0 ) ) , UnpackNormal( tex2D( _WaterNormal, temp_output_568_9 ) ) , 0.5);
			float2 temp_output_486_0 = ( temp_output_568_0 * 0.15 );
			float2 temp_output_487_0 = ( temp_output_568_9 * 0.15 );
			float3 lerpResult489 = lerp( UnpackNormal( tex2D( _WaterNormal, temp_output_486_0 ) ) , UnpackNormal( tex2D( _WaterNormal, temp_output_487_0 ) ) , 0.5);
			float3 lerpResult283 = lerp( float3(0,0,1) , ( lerpResult224 + ( lerpResult489 * _LargerWavesNormalPower ) ) , _NormalPower);
			float3 indirectNormal261 = WorldNormalVector( i , lerpResult283 );
			Unity_GlossyEnvironmentData g261 = UnityGlossyEnvironmentSetup( _Gloss, data.worldViewDir, indirectNormal261, float3(0,0,0));
			float3 indirectSpecular261 = UnityGI_IndirectSpecular( data, 1.0, indirectNormal261, g261 );
			float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( ase_screenPos );
			float4 ase_grabScreenPosNorm = ase_grabScreenPos / ase_grabScreenPos.w;
			float2 appendResult525 = (float2(ase_grabScreenPosNorm.r , ase_grabScreenPosNorm.g));
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float fresnelNdotV256 = dot( normalize( normalize( (WorldNormalVector( i , lerpResult283 )) ) ), ase_worldViewDir );
			float fresnelNode256 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV256, _ReflectionFresnel ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult4_g62 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult410 = dot( normalizeResult4_g62 , ase_worldlightDir );
			float dotResult409 = dot( ase_worldlightDir , normalize( (WorldNormalVector( i , lerpResult283 )) ) );
			float temp_output_424_0 = saturate( (-1.66 + (saturate( ( 1.0 - dotResult409 ) ) - 0.0) * (1.0 - -1.66) / (1.0 - 0.0)) );
			float4 transform412 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float4 temp_output_466_0 = ( _ScatteringTint * 0.33 );
			float lerpResult496 = lerp( tex2D( _WaterHeight, temp_output_568_0 ).r , tex2D( _WaterHeight, temp_output_568_9 ).r , 0.5);
			float lerpResult559 = lerp( tex2D( _WaterHeight, temp_output_486_0 ).r , tex2D( _WaterHeight, temp_output_487_0 ).r , 0.5);
			float temp_output_498_0 = saturate( ( lerpResult496 + ( lerpResult559 * _LargerWavesNormalPower ) ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float temp_output_8_0_g64 = _FoamSpeed;
			float2 temp_cast_3 = (temp_output_8_0_g64).xx;
			float2 appendResult2_g63 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 ifLocalVar21_g63 = 0;
			if( 0.0 <= 0.0 )
				ifLocalVar21_g63 = appendResult2_g63;
			else
				ifLocalVar21_g63 = ( 1.0 - appendResult2_g63 );
			float2 temp_output_7_0_g63 = ( ifLocalVar21_g63 * 0.0066 * ( _FoamTiling * 10.0 ) );
			float2 panner1_g64 = ( 0.015 * _Time.y * temp_cast_3 + temp_output_7_0_g63);
			float2 temp_cast_4 = (-temp_output_8_0_g64).xx;
			float2 panner2_g64 = ( 0.015 * _Time.y * temp_cast_4 + ( ( temp_output_7_0_g63 * 0.77 ) + float2( 0.33,0.66 ) ));
			float lerpResult74 = lerp( tex2D( _Foam, panner1_g64 ).r , tex2D( _Foam, panner2_g64 ).r , 0.5);
			float screenDepth75 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos ))));
			float distanceDepth75 = saturate( abs( ( screenDepth75 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _FoamDistance ) ) );
			float4 temp_cast_5 = (( lerpResult74 * ( 1.0 - distanceDepth75 ) * _FoamIntensity )).xxxx;
			float eyeDepth14_g65 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos ))));
			float4 ase_vertex4Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 ase_viewPos = UnityObjectToViewPos( ase_vertex4Pos );
			float ase_screenDepth = -ase_viewPos.z;
			float temp_output_2_0_g65 = ( ( eyeDepth14_g65 - ase_screenDepth ) * _Density );
			float4 appendResult3_g65 = (float4(temp_output_2_0_g65 , temp_output_2_0_g65 , temp_output_2_0_g65 , temp_output_2_0_g65));
			float4 temp_cast_6 = (-0.1).xxxx;
			float4 temp_cast_7 = (1.0).xxxx;
			float4 temp_cast_8 = (0.0).xxxx;
			float4 temp_cast_9 = (4.0).xxxx;
			float screenDepth515 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos ))));
			float distanceDepth515 = saturate( abs( ( screenDepth515 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( 3.0 ) ) );
			float clampResult562 = clamp( distanceDepth515 , 0.6 , 1.0 );
			float cameraDepthFade555 = (( ase_screenDepth -_ProjectionParams.y - 0.0 ) / 66.0);
			float clampResult552 = clamp( ( 1.0 - cameraDepthFade555 ) , 0.3 , 1.0 );
			float temp_output_548_0 = ( _RefractionChromaticAberration * clampResult552 );
			float4 screenColor538 = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD( ( ( float4( ( (lerpResult283).xy * _RefractionDistortion * clampResult562 ), 0.0 , 0.0 ) + ase_grabScreenPosNorm ) + float4( ( float2( -0.1,-0.1 ) * temp_output_548_0 ), 0.0 , 0.0 ) ) ) );
			float4 screenColor40 = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD( ( float4( ( (lerpResult283).xy * _RefractionDistortion * clampResult562 ), 0.0 , 0.0 ) + ase_grabScreenPosNorm ) ) );
			float4 screenColor539 = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD( ( ( float4( ( (lerpResult283).xy * _RefractionDistortion * clampResult562 ), 0.0 , 0.0 ) + ase_grabScreenPosNorm ) + float4( ( float2( 0.1,0.1 ) * temp_output_548_0 ), 0.0 , 0.0 ) ) ) );
			float3 appendResult547 = (float3(screenColor538.r , screenColor40.g , screenColor539.b));
			float4 blendOpSrc97 = temp_cast_5;
			float4 blendOpDest97 = ( pow( saturate( (temp_cast_7 + (appendResult3_g65 - temp_cast_6) * (temp_cast_8 - temp_cast_7) / (( _WaterTint * 7.0 ) - temp_cast_6)) ) , temp_cast_9 ) * float4( appendResult547 , 0.0 ) );
			float4 blendOpSrc467 = ( ( ( saturate( (-0.2 + (saturate( ( 1.0 - dotResult410 ) ) - 0.0) * (1.0 - -0.2) / (1.0 - 0.0)) ) * temp_output_424_0 * saturate( ( ase_worldPos.y - ( transform412.y + _ScatteringOffset ) ) ) * ( temp_output_466_0 * _ScatteringIntensity ) * saturate( temp_output_498_0 ) ) + ( temp_output_466_0 * _WaterEmission ) ) * ase_lightColor * ase_lightAtten );
			float4 blendOpDest467 = ( saturate( ( 1.0 - ( 1.0 - blendOpSrc97 ) * ( 1.0 - blendOpDest97 ) ) ));
			float4 blendOpSrc138 = ( lerp(float4( indirectSpecular261 , 0.0 ),tex2D( _ReflectionTex, ( ( (lerpResult283).xy * _ReflectionDistortion ) + appendResult525 ) ),_UseScriptReflection) * saturate( fresnelNode256 ) * ase_lightAtten );
			float4 blendOpDest138 = ( ( saturate( ( 1.0 - ( 1.0 - blendOpSrc467 ) * ( 1.0 - blendOpDest467 ) ) )) * ase_lightColor * ase_lightAtten );
			float dotResult389 = dot( ase_worldlightDir , normalize( WorldReflectionVector( i , lerpResult283 ) ) );
			float clampResult399 = clamp( _Gloss , 0.05 , 1.0 );
			c.rgb = ( ( saturate( ( 1.0 - ( 1.0 - blendOpSrc138 ) * ( 1.0 - blendOpDest138 ) ) )) + ( pow( saturate( dotResult389 ) , exp2( (1.0 + (_Gloss - 0.0) * (11.0 - 1.0) / (1.0 - 0.0)) ) ) * _SpecularPower * ase_lightColor * ase_lightAtten * clampResult399 ) ).rgb;
			c.a = distanceDepth100;
			return c;
		}

		inline void LightingStandardCustomLighting_GI( inout SurfaceOutputCustomLightingCustom s, UnityGIInput data, inout UnityGI gi )
		{
			s.GIData = data;
		}

		void surf( Input i , inout SurfaceOutputCustomLightingCustom o )
		{
			o.SurfInput = i;
			o.Normal = float3(0,0,1);
		}

		ENDCG
	}
	Fallback "Diffuse"
	//CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15701
2017;134;1710;939;-596.3937;2851.982;1.198731;True;True
Node;AmplifyShaderEditor.CommentaryNode;288;-3094.875,297.8904;Float;False;689.1088;400.7664;;3;483;244;251;Water Scale & Speed;1,1,1,1;0;0
Node;AmplifyShaderEditor.ToggleSwitchNode;483;-3049.982,470.4386;Float;False;Property;_InvertCoordinates;Invert Coordinates;14;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;244;-3040.238,371.2808;Float;False;Property;_WaterTiling;Water Tiling;13;0;Create;True;0;0;False;0;0;0.5;0.01;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;251;-3059.238,599.2813;Float;False;Property;_WaterSpeed;Water Speed;15;0;Create;True;0;0;False;0;0;0.77;0.01;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;566;-2733.239,376.2808;Float;False;WorldSpaceCoordDual;-1;;59;39024daf4a9269e428da367a6e63e26b;0;2;15;FLOAT;0;False;20;FLOAT;0;False;2;FLOAT2;0;FLOAT2;16
Node;AmplifyShaderEditor.CommentaryNode;237;-2186.385,-71.90498;Float;False;2150.382;1903.55;;29;498;497;496;495;494;218;257;283;285;284;490;491;224;489;492;221;220;484;485;225;486;493;487;488;557;558;559;560;561;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.FunctionNode;568;-2740.239,506.2808;Float;False;DualPanner;-1;;61;493d5f6edc56fb549b8eb8a84e9af86c;0;3;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT;0;False;2;FLOAT2;0;FLOAT2;9
Node;AmplifyShaderEditor.RangedFloatNode;488;-2023.731,578.6703;Float;False;Constant;_Float3;Float 3;26;0;Create;True;0;0;False;0;0.15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;486;-1916.389,443.8825;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;493;-2070.808,54.06643;Float;True;Property;_WaterNormal;Water Normal;8;2;[NoScaleOffset];[Normal];Create;True;0;0;False;0;None;b429e7be19ccbbb49b6e14b80e122225;True;bump;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;487;-1870.567,667.8104;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;225;-1255.822,353.5075;Float;False;Constant;_Float5;Float 5;18;0;Create;True;0;0;False;0;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;485;-1518.896,644.3807;Float;True;Property;_TextureSample5;Texture Sample 5;27;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;484;-1523.494,409.633;Float;True;Property;_TextureSample4;Texture Sample 4;26;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;221;-1591.906,179.0956;Float;True;Property;_TextureSample3;Texture Sample 3;19;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;220;-1594.906,-21.90481;Float;True;Property;_TextureSample2;Texture Sample 2;18;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;489;-1200.337,574.5708;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;492;-1168.842,757.9928;Float;False;Property;_LargerWavesNormalPower;Larger Waves Normal Power;10;0;Create;True;0;0;False;0;1;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;491;-921.3226,602.5972;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;224;-1248.98,46.33558;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;285;-672.0679,442.4046;Float;False;Property;_NormalPower;Normal Power;9;0;Create;True;0;0;False;0;0;0.33;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;284;-782.068,128.4046;Float;False;Constant;_Vector4;Vector 4;19;0;Create;True;0;0;False;0;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;490;-1062.337,214.5708;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;283;-419.068,279.4046;Float;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;257;-373.724,18.74167;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;446;274.723,-262.2243;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;447;1312.006,-327.4563;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;449;1428.241,-737.4153;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TexturePropertyNode;218;-2086.377,921.2697;Float;True;Property;_WaterHeight;Water Height;22;1;[NoScaleOffset];Create;True;0;0;False;0;None;74d354dfa5867ab4e9d848560fd72aff;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SamplerNode;557;-1529.634,1340.369;Float;True;Property;_TextureSample8;Texture Sample 8;31;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;405;1036.2,-3278.17;Float;False;2030.1;1587.32;;35;466;468;434;432;431;433;430;429;427;426;501;428;425;424;419;499;420;421;423;415;417;418;416;411;413;412;414;409;410;408;406;407;509;514;572;Scattering;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;519;-572.1488,-856.8724;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WireNode;448;1363.841,-1595.032;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;558;-1519.412,1584.412;Float;True;Property;_TextureSample9;Texture Sample 9;32;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;494;-1531.054,886.8716;Float;True;Property;_TextureSample6;Texture Sample 6;27;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RelayNode;406;1065.749,-2782.058;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;559;-1084.803,1274.947;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;495;-1527.533,1085.825;Float;True;Property;_TextureSample7;Texture Sample 7;28;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;531;-859.4904,-948.7469;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FunctionNode;407;1230.965,-3185.27;Float;False;Blinn-Phong Half Vector;-1;;62;91a149ac9d615be429126c95e20753ce;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;63;-2018.133,-2394.594;Float;False;1016.65;599.8369;;7;45;43;44;515;517;518;562;Refr. Distortion;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;37;-939.4305,-2474.15;Float;False;1881.077;1101.943;;27;554;396;138;41;467;259;35;97;34;547;372;27;20;538;40;539;541;540;537;546;545;543;548;544;542;552;555;Water Tint;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;520;-2002.011,-1006.143;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;560;-771.5997,1284.774;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;572;1149.743,-2925.515;Float;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;408;1118.112,-3100.04;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LerpOp;496;-901.1315,950.5914;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;409;1393.796,-3028.524;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;561;-662.9598,1104.35;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;515;-1949.99,-1905.091;Float;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;3;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;555;-911.5554,-1560.449;Float;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;66;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;532;-2207.433,-1812.952;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;410;1618.847,-3205.933;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;414;1539.141,-3014.005;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;379;-752.4885,-3666.031;Float;False;691.0181;324.9148;;3;87;88;502;Foam Scale & Speed;1,1,1,1;0;0
Node;AmplifyShaderEditor.RelayNode;497;-625.1472,906.7549;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;518;-1772.378,-2320.189;Float;False;True;True;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;562;-1608.299,-1915.072;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.6;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;411;1244.964,-2402.513;Float;False;Property;_ScatteringOffset;Scattering Offset;21;0;Create;True;0;0;False;0;-1;-0.4;-6;6;0;1;FLOAT;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;412;1222.804,-2610.828;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;533;-389.334,-202.3597;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;413;1773.265,-3195.637;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;554;-655.3098,-1557.184;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1990.228,-2126.719;Float;False;Property;_RefractionDistortion;Refraction Distortion;28;0;Create;True;0;0;False;0;0.1;0.1;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;534;-1815.817,-206.6363;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;416;1235.193,-2759.849;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;415;1742.976,-2969.96;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;417;1573.964,-2524.514;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GrabScreenPosition;517;-1247.377,-2025.191;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;418;1936.167,-3195.092;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;514;1300.137,-2266.193;Float;False;Property;_ScatteringTint;Scattering Tint;17;0;Create;True;0;0;False;0;1,1,1,0;0.5411765,0.7863346,1,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;498;-385.7113,965.1077;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;552;-430.5173,-1555.517;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-1476.05,-2332.462;Float;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;509;1702.302,-2116.541;Float;False;Constant;_Float7;Float 7;29;0;Create;True;0;0;False;0;0.33;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-747.2164,-3615.031;Float;False;Property;_FoamTiling;Foam Tiling;31;0;Create;True;0;0;False;0;2;2;0.01;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;397;192.5452,-109.9731;Float;False;1135.416;532.038;;13;392;394;393;391;399;385;384;386;390;389;398;229;388;Highlights;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;542;-876.5122,-1686.421;Float;False;Property;_RefractionChromaticAberration;Refraction Chromatic Aberration;29;0;Create;True;0;0;False;0;0;0.033;0;0.15;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;423;1554.768,-2838.786;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1.66;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;229;211.7076,91.97601;Float;False;Property;_Gloss;Gloss;11;0;Create;True;0;0;False;0;0.88;0.93;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;502;-550.1062,-3537.255;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;535;-1830.121,-651.2194;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;499;2515.832,-2181.936;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;421;1955.88,-3108.308;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.2;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;543;-897.5122,-1988.421;Float;False;Constant;_Vector0;Vector 0;31;0;Create;True;0;0;False;0;-0.1,-0.1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleSubtractOpNode;420;1572.276,-2644.096;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-1154.071,-2283.381;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;544;-894.5122,-1850.421;Float;False;Constant;_Vector1;Vector 1;31;0;Create;True;0;0;False;0;0.1,0.1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;419;1966.554,-2347.074;Float;False;Property;_ScatteringIntensity;Scattering Intensity;20;0;Create;True;0;0;False;0;0.45;2;0;6;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;548;-447.5173,-1658.517;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;466;1699.848,-2340.628;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.1922837;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;530;-1692.282,-779.8632;Float;False;1113.819;544.2731;;6;522;524;525;526;521;527;Refl. Distortion;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;461;519.8566,-250.1776;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;546;-697.5122,-1979.421;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GrabScreenPosition;521;-1212.432,-442.5899;Float;False;0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;565;-356.2034,-3612.767;Float;False;WorldSpaceCoordDual;-1;;63;39024daf4a9269e428da367a6e63e26b;0;2;15;FLOAT;0;False;20;FLOAT;0;False;2;FLOAT2;0;FLOAT2;16
Node;AmplifyShaderEditor.ComponentMaskNode;522;-1424.432,-717.59;Float;False;True;True;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;424;2007.365,-2801.275;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-727.4885,-3438.544;Float;False;Property;_FoamSpeed;Foam Speed;32;0;Create;True;0;0;False;0;2;3;0;20;0;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;537;-849.7288,-2103.744;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SaturateNode;428;2005.218,-2710.324;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;96;-749.8057,-3230.795;Float;False;1432.24;640.6575;;9;99;76;75;80;95;74;65;66;64;Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;545;-681.5122,-1816.421;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;426;2016.89,-2903.67;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;427;2005.958,-2588.923;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;425;2019.289,-2222.107;Float;False;Property;_WaterEmission;Water Emission;19;0;Create;True;0;0;False;0;0.2;0.4;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;527;-1642.282,-524.1192;Float;False;Property;_ReflectionDistortion;Reflection Distortion;27;0;Create;True;0;0;False;0;0.1;0.4;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;501;2692.25,-2269.446;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;430;2323.38,-2764.074;Float;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;524;-1128.104,-729.8632;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;429;2343.289,-2262.107;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;383;309.0595,-931.492;Float;False;913.3109;658.754;;9;255;382;274;262;256;253;261;273;474;Reflection;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldReflectionVector;398;259.5839,199.8168;Float;False;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WireNode;460;272.1812,-318.5464;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;64;-659.2963,-3045.815;Float;True;Property;_Foam;Foam;30;1;[NoScaleOffset];Create;True;0;0;False;0;None;eea040e2c1ceead419a87ff09049839b;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.WireNode;445;245.3466,-254.8803;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;76;-585.908,-2791.355;Float;False;Property;_FoamDistance;Foam Distance;33;0;Create;True;0;0;False;0;1.5;1;0;6;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;567;-315.5082,-3481.558;Float;False;DualPanner;-1;;64;493d5f6edc56fb549b8eb8a84e9af86c;0;3;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT;0;False;2;FLOAT2;0;FLOAT2;9
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;388;242.5452,-59.97314;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;541;-518.5122,-1824.421;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;540;-548.5122,-1998.421;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.DynamicAppendNode;525;-918.2202,-510.0368;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TFHCRemapNode;384;532.1852,55.0239;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;11;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;40;-498.6755,-2279.506;Float;False;Global;_GrabScreen0;Grab Screen 0;3;0;Create;True;0;0;False;0;Object;-1;False;True;1;0;FLOAT4;0,0,0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;526;-806.126,-680.7813;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;462;252.8315,-727.4689;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-857.5915,-2211.413;Float;False;Property;_Density;Density;18;0;Create;True;0;0;False;0;0.01;0.33;0.1;1.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;65;-282.8455,-2963.224;Float;True;Property;_TextureSample0;Texture Sample 0;6;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;389;523.5451,-50.97314;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;474;406.9076,-360.0485;Float;False;Property;_ReflectionFresnel;Reflection Fresnel;26;0;Create;True;0;0;False;0;0;7;1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;538;-409.744,-2102.767;Float;False;Global;_GrabScreen2;Grab Screen 2;3;0;Create;True;0;0;False;0;Instance;40;False;True;1;0;FLOAT4;0,0,0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;75;-226.2859,-2753.806;Float;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;20;-877.9736,-2403.452;Float;False;Property;_WaterTint;Water Tint;16;0;Create;True;0;0;False;0;0.5235849,0.8924802,1,1;0.854902,0.9618228,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;431;2532.568,-2731.442;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;432;2303.055,-2418.378;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;273;360.06,-519.2019;Float;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.LightColorNode;433;2363.957,-2574.065;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;66;-282.4117,-3161.57;Float;True;Property;_TextureSample1;Texture Sample 1;7;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;539;-337.9198,-1903.242;Float;False;Global;_GrabScreen3;Grab Screen 3;3;0;Create;True;0;0;False;0;Instance;40;False;True;1;0;FLOAT4;0,0,0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.FunctionNode;372;-557.144,-2373.757;Float;False;WaterDepthColoring;-1;;65;b2855d2069d92e144a4d6c165a40bc19;0;2;16;COLOR;1,1,1,1;False;15;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.FresnelNode;256;590.1468,-518.366;Float;False;Standard;WorldNormal;ViewDir;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;547;-140.5122,-2128.421;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;390;688.5455,-43.97314;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;74;69.37602,-3157.613;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Exp2OpNode;385;727.4502,41.27928;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;80;129.6276,-2913.527;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;434;2705.506,-2704.222;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;253;372.3521,-742.8816;Float;True;Property;_ReflectionTex;ReflectionTex;0;1;[HideInInspector];Create;True;0;0;False;0;None;;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;99;131.7749,-2810.392;Float;False;Property;_FoamIntensity;Foam Intensity;34;0;Create;True;0;0;False;0;0;1.33;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;261;394.116,-881.4919;Float;False;Tangent;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.PowerNode;386;872.4502,-43.72063;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-205.5021,-2323.384;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;495.2658,-3081.574;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;399;525.3071,219.2684;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.05;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;393;730.9525,147.1227;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;394;717.9523,282.1226;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;382;835.0687,-423.7381;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;391;911.5221,65.28246;Float;False;Property;_SpecularPower;Specular Power;12;0;Create;True;0;0;False;0;0.88;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;274;836.8724,-525.8198;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;262;786.0113,-799.1893;Float;True;Property;_UseScriptReflection;Use Script Reflection;25;0;Create;True;0;0;False;0;1;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;468;2843.706,-2189.549;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;255;1037.846,-553.2842;Float;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;238;205.6891,1106.116;Float;False;773.049;506.8568;;5;235;231;234;475;476;Displacement;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;392;1149.952,-29.87744;Float;False;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;97;7.984648,-2351.431;Float;False;Screen;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;470;2137.077,-1651.929;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;444;952.5482,-953.3397;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;467;296.3393,-2359.288;Float;False;Screen;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;475;253.435,1171.103;Float;False;Property;_HeightOffset;Height Offset;24;0;Create;True;0;0;False;0;0;-0.36;-5;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;441;1330.045,-308.8134;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;35;114.9346,-2071.323;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;259;119.5604,-1914.587;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;294.1274,-2160.897;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;443;642.46,-993.89;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;440;1270.119,-952.2135;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;476;592.7443,1212.392;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;235;244.689,1521.971;Float;False;Property;_Displacement;Displacement;23;0;Create;True;0;0;False;0;1;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;234;251.258,1315.298;Float;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.BlendOpsNode;138;510.69,-2164.531;Float;False;Screen;True;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;158;981.3688,595.4454;Float;False;719.3131;193;;2;100;101;Shore Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.WireNode;439;1028.844,-979.0217;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;231;722.739,1282.115;Float;True;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;396;776.6075,-2170.434;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;438;1021.188,427.0078;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;101;1031.369,656.3514;Float;False;Property;_ShoreBlendDistance;Shore Blend Distance;7;0;Create;True;0;0;False;0;0.02;0.3;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;437;1484.948,343.3046;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DepthFade;100;1409.682,645.4454;Float;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;571;1749.817,303.7979;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RelayNode;569;1772.024,95.90395;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;570;1757.196,196.9757;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;556;1624.504,493.2502;Float;False;Constant;_Float1;Float 1;31;0;Create;True;0;0;False;0;0.88;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1994.573,348.4147;Float;False;True;6;Float;ASEMaterialInspector;0;0;CustomLighting;DCG/Water/Realistic Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;False;False;False;False;Back;1;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;150;True;Transparent;;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;1;False;-1;1;False;-1;1;False;-1;7;False;-1;3;False;-1;2;False;-1;2;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;True;2;2;10;25;True;1;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;-1;2;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;566;15;244;0
WireConnection;566;20;483;0
WireConnection;568;6;566;0
WireConnection;568;7;566;16
WireConnection;568;8;251;0
WireConnection;486;0;568;0
WireConnection;486;1;488;0
WireConnection;487;0;568;9
WireConnection;487;1;488;0
WireConnection;485;0;493;0
WireConnection;485;1;487;0
WireConnection;484;0;493;0
WireConnection;484;1;486;0
WireConnection;221;0;493;0
WireConnection;221;1;568;9
WireConnection;220;0;493;0
WireConnection;220;1;568;0
WireConnection;489;0;484;0
WireConnection;489;1;485;0
WireConnection;489;2;225;0
WireConnection;491;0;489;0
WireConnection;491;1;492;0
WireConnection;224;0;220;0
WireConnection;224;1;221;0
WireConnection;224;2;225;0
WireConnection;490;0;224;0
WireConnection;490;1;491;0
WireConnection;283;0;284;0
WireConnection;283;1;490;0
WireConnection;283;2;285;0
WireConnection;257;0;283;0
WireConnection;446;0;257;0
WireConnection;447;0;446;0
WireConnection;449;0;447;0
WireConnection;557;0;218;0
WireConnection;557;1;486;0
WireConnection;519;0;257;0
WireConnection;448;0;449;0
WireConnection;558;0;218;0
WireConnection;558;1;487;0
WireConnection;494;0;218;0
WireConnection;494;1;568;0
WireConnection;406;0;448;0
WireConnection;559;0;557;1
WireConnection;559;1;558;1
WireConnection;559;2;225;0
WireConnection;495;0;218;0
WireConnection;495;1;568;9
WireConnection;531;0;519;0
WireConnection;520;0;531;0
WireConnection;560;0;559;0
WireConnection;560;1;492;0
WireConnection;572;0;406;0
WireConnection;496;0;494;1
WireConnection;496;1;495;1
WireConnection;496;2;225;0
WireConnection;409;0;408;0
WireConnection;409;1;572;0
WireConnection;561;0;496;0
WireConnection;561;1;560;0
WireConnection;532;0;520;0
WireConnection;410;0;407;0
WireConnection;410;1;408;0
WireConnection;414;0;409;0
WireConnection;497;0;561;0
WireConnection;518;0;532;0
WireConnection;562;0;515;0
WireConnection;533;0;257;0
WireConnection;413;0;410;0
WireConnection;554;0;555;0
WireConnection;534;0;533;0
WireConnection;415;0;414;0
WireConnection;417;0;412;2
WireConnection;417;1;411;0
WireConnection;418;0;413;0
WireConnection;498;0;497;0
WireConnection;552;0;554;0
WireConnection;43;0;518;0
WireConnection;43;1;44;0
WireConnection;43;2;562;0
WireConnection;423;0;415;0
WireConnection;502;0;87;0
WireConnection;535;0;534;0
WireConnection;499;0;498;0
WireConnection;421;0;418;0
WireConnection;420;0;416;2
WireConnection;420;1;417;0
WireConnection;45;0;43;0
WireConnection;45;1;517;0
WireConnection;548;0;542;0
WireConnection;548;1;552;0
WireConnection;466;0;514;0
WireConnection;466;1;509;0
WireConnection;461;0;229;0
WireConnection;546;0;543;0
WireConnection;546;1;548;0
WireConnection;565;15;502;0
WireConnection;522;0;535;0
WireConnection;424;0;423;0
WireConnection;537;0;45;0
WireConnection;428;0;420;0
WireConnection;545;0;544;0
WireConnection;545;1;548;0
WireConnection;426;0;421;0
WireConnection;427;0;466;0
WireConnection;427;1;419;0
WireConnection;501;0;499;0
WireConnection;430;0;426;0
WireConnection;430;1;424;0
WireConnection;430;2;428;0
WireConnection;430;3;427;0
WireConnection;430;4;501;0
WireConnection;524;0;522;0
WireConnection;524;1;527;0
WireConnection;429;0;466;0
WireConnection;429;1;425;0
WireConnection;398;0;257;0
WireConnection;460;0;461;0
WireConnection;445;0;257;0
WireConnection;567;6;565;0
WireConnection;567;7;565;16
WireConnection;567;8;88;0
WireConnection;541;0;537;0
WireConnection;541;1;545;0
WireConnection;540;0;537;0
WireConnection;540;1;546;0
WireConnection;525;0;521;1
WireConnection;525;1;521;2
WireConnection;384;0;229;0
WireConnection;40;0;537;0
WireConnection;526;0;524;0
WireConnection;526;1;525;0
WireConnection;462;0;460;0
WireConnection;65;0;64;0
WireConnection;65;1;567;9
WireConnection;389;0;388;0
WireConnection;389;1;398;0
WireConnection;538;0;540;0
WireConnection;75;0;76;0
WireConnection;431;0;430;0
WireConnection;431;1;429;0
WireConnection;273;0;445;0
WireConnection;66;0;64;0
WireConnection;66;1;567;0
WireConnection;539;0;541;0
WireConnection;372;16;20;0
WireConnection;372;15;27;0
WireConnection;256;0;273;0
WireConnection;256;3;474;0
WireConnection;547;0;538;1
WireConnection;547;1;40;2
WireConnection;547;2;539;3
WireConnection;390;0;389;0
WireConnection;74;0;66;1
WireConnection;74;1;65;1
WireConnection;385;0;384;0
WireConnection;80;0;75;0
WireConnection;434;0;431;0
WireConnection;434;1;433;0
WireConnection;434;2;432;0
WireConnection;253;1;526;0
WireConnection;261;0;257;0
WireConnection;261;1;462;0
WireConnection;386;0;390;0
WireConnection;386;1;385;0
WireConnection;34;0;372;0
WireConnection;34;1;547;0
WireConnection;95;0;74;0
WireConnection;95;1;80;0
WireConnection;95;2;99;0
WireConnection;399;0;229;0
WireConnection;274;0;256;0
WireConnection;262;0;261;0
WireConnection;262;1;253;0
WireConnection;468;0;434;0
WireConnection;255;0;262;0
WireConnection;255;1;274;0
WireConnection;255;2;382;0
WireConnection;392;0;386;0
WireConnection;392;1;391;0
WireConnection;392;2;393;0
WireConnection;392;3;394;0
WireConnection;392;4;399;0
WireConnection;97;0;95;0
WireConnection;97;1;34;0
WireConnection;470;0;468;0
WireConnection;444;0;255;0
WireConnection;467;0;470;0
WireConnection;467;1;97;0
WireConnection;441;0;392;0
WireConnection;41;0;467;0
WireConnection;41;1;35;0
WireConnection;41;2;259;0
WireConnection;443;0;444;0
WireConnection;440;0;441;0
WireConnection;476;0;498;0
WireConnection;476;1;475;0
WireConnection;138;0;443;0
WireConnection;138;1;41;0
WireConnection;439;0;440;0
WireConnection;231;0;476;0
WireConnection;231;1;234;0
WireConnection;231;2;235;0
WireConnection;396;0;138;0
WireConnection;396;1;439;0
WireConnection;438;0;231;0
WireConnection;437;0;438;0
WireConnection;100;0;101;0
WireConnection;571;0;257;0
WireConnection;569;0;424;0
WireConnection;570;0;396;0
WireConnection;0;9;100;0
WireConnection;0;13;570;0
WireConnection;0;11;437;0
ASEEND*/
//CHKSM=91058F93C008C679D7F4FA092C122A31DB7962F2