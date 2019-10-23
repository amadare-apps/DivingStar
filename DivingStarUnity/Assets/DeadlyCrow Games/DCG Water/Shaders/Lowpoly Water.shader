// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DCG/Water/Lowpoly Water"
{
	Properties
	{
		_ShoreBlendDistance("Shore Blend Distance", Range( 0 , 3)) = 0.02
		_WaterTint("Water Tint", Color) = (0.5235849,0.8924802,1,1)
		_ScatteringTint("Scattering Tint", Color) = (0.5235849,0.8924802,1,1)
		_Density("Density", Range( 0.01 , 1)) = 0.01
		_WaterEmission("Water Emission", Range( 0 , 1)) = 0.2
		_ScatteringIntensity("Scattering Intensity", Range( 0 , 6)) = 0.45
		_ScatteringOffset("Scattering Offset", Range( -6 , 6)) = -1
		[Toggle]_UseSpecularGloss("Use Specular Gloss", Float) = 1
		_Gloss("Gloss", Range( 0 , 1)) = 0.88
		_ReflectionFresnel("Reflection Fresnel", Range( 0.1 , 10)) = 6
		[Toggle]_HardDistortion("Hard Distortion", Float) = 0
		_Distortion("Distortion", Range( 0 , 0.66)) = 0.1
		_RefractionChromaticAberration("Refraction Chromatic Aberration", Range( 0 , 0.15)) = 0
		[NoScaleOffset]_Foam("Foam", 2D) = "white" {}
		_FoamDistance("Foam Distance", Range( 0 , 6)) = 1.5
		_FoamSpeed("Foam Speed", Range( 0 , 10)) = 2
		_FoamScale("Foam Scale", Range( 0.01 , 10)) = 2
		_FoamIntensity("Foam Intensity", Range( 0 , 2)) = 0
		_DisplacementNoisePower("Displacement Noise Power", Range( 0 , 1)) = 0.3
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "AlphaTest+150" "IgnoreProjector" = "True" "ForceNoShadowCasting" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		GrabPass{ }
		CGPROGRAM
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#pragma target 4.6
		#pragma surface surf StandardCustomLighting keepalpha vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			float4 screenPos;
			INTERNAL_DATA
			float3 worldNormal;
			float eyeDepth;
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

		uniform float _DisplacementNoisePower;
		uniform float _ScatteringOffset;
		uniform float4 _ScatteringTint;
		uniform float _ScatteringIntensity;
		uniform float _WaterEmission;
		uniform sampler2D _CameraDepthTexture;
		uniform float _ShoreBlendDistance;
		uniform float _ReflectionFresnel;
		uniform float _Gloss;
		uniform sampler2D _Foam;
		uniform float _FoamSpeed;
		uniform float _FoamScale;
		uniform float _FoamDistance;
		uniform float _FoamIntensity;
		uniform float _Density;
		uniform float4 _WaterTint;
		uniform sampler2D _GrabTexture;
		uniform float _HardDistortion;
		uniform float _Distortion;
		uniform float _RefractionChromaticAberration;
		uniform float _UseSpecularGloss;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float temp_output_8_0_g13 = 22.0;
			float2 temp_cast_0 = (temp_output_8_0_g13).xx;
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float2 appendResult2_g12 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 ifLocalVar21_g12 = 0;
			if( 0.0 <= 0.0 )
				ifLocalVar21_g12 = appendResult2_g12;
			else
				ifLocalVar21_g12 = ( 1.0 - appendResult2_g12 );
			float2 temp_output_7_0_g12 = ( ifLocalVar21_g12 * 0.0066 * 12.0 );
			float2 panner1_g13 = ( 0.015 * _Time.y * temp_cast_0 + temp_output_7_0_g12);
			float simplePerlin2D218 = snoise( panner1_g13 );
			float2 temp_cast_1 = (-temp_output_8_0_g13).xx;
			float2 panner2_g13 = ( 0.015 * _Time.y * temp_cast_1 + ( ( temp_output_7_0_g12 * 0.77 ) + float2( 0.33,0.66 ) ));
			float simplePerlin2D219 = snoise( panner2_g13 );
			float lerpResult222 = lerp( simplePerlin2D218 , simplePerlin2D219 , 0.5);
			v.vertex.xyz += ( lerpResult222 * float3(0,1,0) * _DisplacementNoisePower );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
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
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float3 normalizeResult115 = normalize( cross( ddy( ase_worldPos ) , ddx( ase_worldPos ) ) );
			float fresnelNdotV103 = dot( normalize( normalizeResult115 ), ase_worldViewDir );
			float fresnelNode103 = ( 0.0 + 1.0 * pow( 1.0 - fresnelNdotV103, _ReflectionFresnel ) );
			float3 indirectNormal135 = normalizeResult115;
			Unity_GlossyEnvironmentData g135 = UnityGlossyEnvironmentSetup( _Gloss, data.worldViewDir, indirectNormal135, float3(0,0,0));
			float3 indirectSpecular135 = UnityGI_IndirectSpecular( data, 1.0, indirectNormal135, g135 );
			float2 temp_cast_2 = (_FoamSpeed).xx;
			float2 appendResult68 = (float2(ase_worldPos.x , ase_worldPos.z));
			float2 temp_output_69_0 = ( appendResult68 * 0.1 * _FoamScale );
			float2 panner71 = ( 0.1 * _Time.y * temp_cast_2 + temp_output_69_0);
			float2 temp_cast_3 = (( _FoamSpeed * -1.0 )).xx;
			float2 panner72 = ( 0.1 * _Time.y * temp_cast_3 + ( ( temp_output_69_0 * float2( 0.8,0.8 ) ) + float2( 0.33,0.66 ) ));
			float lerpResult74 = lerp( tex2D( _Foam, panner71 ).r , tex2D( _Foam, panner72 ).r , 0.5);
			float screenDepth78 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos ))));
			float distanceDepth78 = saturate( abs( ( screenDepth78 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( ( _FoamDistance * 0.25 ) ) ) );
			float screenDepth75 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos ))));
			float distanceDepth75 = saturate( abs( ( screenDepth75 - LinearEyeDepth( ase_screenPosNorm.z ) ) / ( _FoamDistance ) ) );
			float4 temp_cast_4 = (( saturate( ( (-2.0 + (( lerpResult74 + ( 1.0 - distanceDepth78 ) ) - 0.0) * (10.0 - -2.0) / (1.0 - 0.0)) * 33.0 ) ) * ( 1.0 - distanceDepth75 ) * _FoamIntensity )).xxxx;
			float eyeDepth14_g11 = LinearEyeDepth(UNITY_SAMPLE_DEPTH(tex2Dproj(_CameraDepthTexture,UNITY_PROJ_COORD( ase_screenPos ))));
			float temp_output_2_0_g11 = ( ( eyeDepth14_g11 - i.eyeDepth ) * _Density );
			float4 appendResult3_g11 = (float4(temp_output_2_0_g11 , temp_output_2_0_g11 , temp_output_2_0_g11 , temp_output_2_0_g11));
			float4 temp_cast_5 = (-0.1).xxxx;
			float4 temp_cast_6 = (1.0).xxxx;
			float4 temp_cast_7 = (0.0).xxxx;
			float4 temp_cast_8 = (4.0).xxxx;
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float2 appendResult55 = (float2(ase_normWorldNormal.x , ase_normWorldNormal.y));
			float2 temp_output_43_0 = ( lerp(appendResult55,(normalizeResult115).xy,_HardDistortion) * _Distortion );
			float cameraDepthFade229 = (( i.eyeDepth -_ProjectionParams.y - 0.0 ) / 66.0);
			float clampResult231 = clamp( ( 1.0 - cameraDepthFade229 ) , 0.3 , 1.0 );
			float temp_output_233_0 = ( _RefractionChromaticAberration * clampResult231 );
			float4 screenColor241 = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD( ( ( float4( ( temp_output_43_0 + ( (0.0 + (_Distortion - 0.005) * (1.0 - 0.0) / (0.66 - 0.005)) * float2( 0,-0.66 ) ) ), 0.0 , 0.0 ) + ase_screenPosNorm ) + float4( ( float2( -0.1,-0.1 ) * temp_output_233_0 ), 0.0 , 0.0 ) ) ) );
			float4 screenColor40 = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD( ( float4( ( temp_output_43_0 + ( (0.0 + (_Distortion - 0.005) * (1.0 - 0.0) / (0.66 - 0.005)) * float2( 0,-0.66 ) ) ), 0.0 , 0.0 ) + ase_screenPosNorm ) ) );
			float4 screenColor240 = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD( ( ( float4( ( temp_output_43_0 + ( (0.0 + (_Distortion - 0.005) * (1.0 - 0.0) / (0.66 - 0.005)) * float2( 0,-0.66 ) ) ), 0.0 , 0.0 ) + ase_screenPosNorm ) + float4( ( float2( 0.1,0.1 ) * temp_output_233_0 ), 0.0 , 0.0 ) ) ) );
			float3 appendResult243 = (float3(screenColor241.r , screenColor40.g , screenColor240.b));
			float4 blendOpSrc97 = temp_cast_4;
			float4 blendOpDest97 = ( pow( saturate( (temp_cast_6 + (appendResult3_g11 - temp_cast_5) * (temp_cast_7 - temp_cast_6) / (( _WaterTint * 7.0 ) - temp_cast_5)) ) , temp_cast_8 ) * float4( appendResult243 , 0.0 ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float dotResult13 = dot( ase_worldlightDir , normalizeResult115 );
			float clampResult39 = clamp( dotResult13 , 0.25 , 1.0 );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 blendOpSrc138 = float4( ( fresnelNode103 * indirectSpecular135 ) , 0.0 );
			float4 blendOpDest138 = ( ( ( saturate( ( 1.0 - ( 1.0 - blendOpSrc97 ) * ( 1.0 - blendOpDest97 ) ) )) * clampResult39 ) * ase_lightColor * ase_lightAtten );
			float3 normalizeResult4_g10 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult146 = dot( normalizeResult4_g10 , normalizeResult115 );
			float clampResult180 = clamp( _Gloss , 0.0025 , 100.0 );
			c.rgb = ( ( saturate( ( 1.0 - ( 1.0 - blendOpSrc138 ) * ( 1.0 - blendOpDest138 ) ) )) + ( ( pow( saturate( dotResult146 ) , exp2( (1.0 + (_Gloss - 0.0) * (11.0 - 1.0) / (1.0 - 0.0)) ) ) * clampResult180 ) * ase_lightColor * ase_lightAtten * lerp(0.0,1.0,_UseSpecularGloss) ) ).rgb;
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
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = Unity_SafeNormalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult4_g1 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult200 = dot( normalizeResult4_g1 , ase_worldlightDir );
			float4 transform187 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float4 temp_output_21_0 = ( _ScatteringTint * 0.33 );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			o.Emission = ( ( ( saturate( (-0.2 + (saturate( ( 1.0 - dotResult200 ) ) - 0.0) * (1.0 - -0.2) / (1.0 - 0.0)) ) * saturate( ( ase_worldPos.y - ( transform187.y + _ScatteringOffset ) ) ) * ( temp_output_21_0 * _ScatteringIntensity ) ) + ( temp_output_21_0 * _WaterEmission ) ) * ase_lightColor * 1 ).rgb;
		}

		ENDCG
	}
	Fallback "Diffuse"
	//CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15701
2017;164;1710;909;526.5422;241.3215;1;True;True
Node;AmplifyShaderEditor.CommentaryNode;141;-3389.414,237.3027;Float;False;986.3467;266.9377;;6;3;2;1;4;115;124;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldPosInputsNode;3;-3339.414,321.3961;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;96;-2252.443,-4407.05;Float;False;1983.557;1305.217;;31;67;87;68;70;69;88;85;83;90;89;86;71;64;72;65;66;74;82;93;91;94;95;73;76;79;77;78;81;75;80;99;Foam;1,1,1,1;0;0
Node;AmplifyShaderEditor.DdyOpNode;2;-3127.785,394.24;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DdxOpNode;1;-3131.001,319.0717;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;67;-2121.471,-4175.148;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CrossProductOpNode;4;-2963.398,287.3027;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;63;-2245.499,1601.408;Float;False;1587.299;1074.075;;15;46;55;58;44;60;61;49;43;62;59;42;45;54;56;50;Distortion;1,1,1,1;0;0
Node;AmplifyShaderEditor.NormalizeNode;115;-2799.836,296.3946;Float;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;70;-2050.976,-4012.474;Float;False;Constant;_Float1;Float 1;6;0;Create;True;0;0;False;0;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;87;-2202.443,-3919.458;Float;False;Property;_FoamScale;Foam Scale;17;0;Create;True;0;0;False;0;2;2;0.01;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;68;-1859.361,-4041.431;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;46;-2195.497,1811.817;Float;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-1841.361,-3932.431;Float;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RelayNode;124;-2544.728,320.2361;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1692.593,2038.284;Float;False;Property;_Distortion;Distortion;12;0;Create;True;0;0;False;0;0.1;0.66;0;0.66;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;244;-3549.227,-2921.353;Float;False;1076.32;979.4187;;16;240;230;233;234;235;236;237;238;239;241;40;242;231;229;232;243;Chromatic Aberration;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;85;-2080.126,-3787.653;Float;False;Constant;_Vector2;Vector 2;7;0;Create;True;0;0;False;0;0.33,0.66;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;90;-1577.157,-4357.05;Float;False;Constant;_Float3;Float 3;9;0;Create;True;0;0;False;0;-1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;58;-1656.599,1681.769;Float;False;True;True;False;True;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;55;-1751.127,1797.008;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;88;-1846.039,-4257.933;Float;False;Property;_FoamSpeed;Foam Speed;16;0;Create;True;0;0;False;0;2;2;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-1852.366,-3797.142;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.8,0.8;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;79;-2007.596,-3249.133;Float;False;Constant;_Float2;Float 2;7;0;Create;True;0;0;False;0;0.25;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;49;-1515.525,1810.605;Float;False;Property;_HardDistortion;Hard Distortion;11;0;Create;True;0;0;False;0;0;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CameraDepthFade;229;-3481.981,-2102.867;Float;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;66;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;61;-1509.305,2189.031;Float;False;5;0;FLOAT;0;False;1;FLOAT;0.005;False;2;FLOAT;0.66;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;-1430.59,-4264.26;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;86;-1811.243,-3659.011;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;60;-1474.449,2444.645;Float;False;Constant;_Vector1;Vector 1;5;0;Create;True;0;0;False;0;0,-0.66;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;76;-2052.496,-3361.133;Float;False;Property;_FoamDistance;Foam Distance;15;0;Create;True;0;0;False;0;1.5;2;0;6;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;77;-1811.595,-3234.833;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;71;-1566.764,-3995.676;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexturePropertyNode;64;-1615.024,-3847.116;Float;True;Property;_Foam;Foam;14;1;[NoScaleOffset];Create;True;0;0;False;0;None;8d55201b19bb15042b89cb2ad7fc1280;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.PannerNode;72;-1574.325,-3600.417;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;-1,-1;False;1;FLOAT;0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;230;-3225.735,-2099.602;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;-1264.255,2278.813;Float;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-1258.418,1889.539;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;66;-1228.586,-3974.809;Float;True;Property;_TextureSample1;Texture Sample 1;7;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenPosInputsNode;42;-1023.355,2468.481;Float;False;0;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;231;-3000.943,-2097.935;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.3;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;65;-1212.586,-3721.809;Float;True;Property;_TextureSample0;Texture Sample 0;6;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;78;-1614.495,-3289.133;Float;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;232;-3446.938,-2228.838;Float;False;Property;_RefractionChromaticAberration;Refraction Chromatic Aberration;13;0;Create;True;0;0;False;0;0;0.066;0;0.15;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;59;-1053.007,2305.219;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;234;-3467.938,-2530.838;Float;False;Constant;_Vector3;Vector 3;31;0;Create;True;0;0;False;0;-0.1,-0.1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;45;-812.1981,2253.148;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.Vector2Node;235;-3464.938,-2392.838;Float;False;Constant;_Vector5;Vector 5;31;0;Create;True;0;0;False;0;0.1,0.1;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;233;-3017.943,-2200.934;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;74;-827.765,-3844.676;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;81;-1290.495,-3270.133;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;216;-2229.953,-1747.108;Float;False;1701.703;1148.824;;22;191;198;200;189;187;202;204;190;182;209;205;185;201;208;186;211;210;206;213;214;212;215;Scattering;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;236;-3267.938,-2521.838;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;237;-3251.938,-2358.838;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RelayNode;242;-3499.227,-2716.864;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleAddOpNode;82;-816.8467,-3603.605;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;191;-2168.645,-1566.215;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;198;-2171.792,-1676.445;Float;False;Blinn-Phong Half Vector;-1;;1;91a149ac9d615be429126c95e20753ce;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;239;-3118.938,-2540.838;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.CommentaryNode;37;-2253.985,-2940.74;Float;False;1902.54;966.1738;;13;34;35;36;21;20;27;41;97;138;140;245;249;207;Water Tint;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;238;-3088.938,-2366.838;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TFHCRemapNode;93;-658.6527,-3603.201;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-2;False;4;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;91;-437.884,-3588.886;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;33;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-2213.494,-2544.585;Float;False;Property;_Density;Density;4;0;Create;True;0;0;False;0;0.01;0.46;0.01;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;157;-2222.839,875.0076;Float;False;1185.526;507.4801;;12;146;149;150;148;151;152;153;154;159;175;180;217;Highlights;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;200;-1783.91,-1697.108;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;144;-2212.064,161.8872;Float;False;970.6471;458.6547;;5;136;103;135;143;137;Fresnel Reflection;1,1,1,1;0;0
Node;AmplifyShaderEditor.ScreenColorNode;40;-2985.699,-2871.353;Float;False;Global;_GrabScreen0;Grab Screen 0;3;0;Create;True;0;0;False;0;Object;-1;False;True;1;0;FLOAT4;0,0,0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;240;-2908.345,-2445.659;Float;False;Global;_GrabScreen3;Grab Screen 3;3;0;Create;True;0;0;False;0;Instance;40;False;True;1;0;FLOAT4;0,0,0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;241;-2980.169,-2645.184;Float;False;Global;_GrabScreen2;Grab Screen 2;3;0;Create;True;0;0;False;0;Instance;40;False;True;1;0;FLOAT4;0,0,0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DepthFade;75;-1626.495,-3427.133;Float;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;20;-2203.734,-2877.214;Float;False;Property;_WaterTint;Water Tint;2;0;Create;True;0;0;False;0;0.5235849,0.8924802,1,1;0.768868,0.9271776,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;142;-2204.563,-370.7008;Float;False;834.215;259.2077;;3;12;13;39;Lambert Shading;1,1,1,1;0;0
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;187;-2167.953,-939.0031;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;202;-1629.492,-1686.812;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;137;-2128.939,505.542;Float;False;Property;_Gloss;Gloss;9;0;Create;True;0;0;False;0;0.88;0.9;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;99;-961.6539,-3405.745;Float;False;Property;_FoamIntensity;Foam Intensity;18;0;Create;True;0;0;False;0;0;1;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;243;-2639.907,-2694.178;Float;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;80;-1290.495,-3369.133;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;12;-2154.563,-320.701;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FunctionNode;245;-1867.037,-2865.667;Float;False;WaterDepthColoring;-1;;11;b2855d2069d92e144a4d6c165a40bc19;0;2;16;COLOR;1,1,1,1;False;15;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;94;-453.0186,-3471.255;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;189;-2168.793,-761.6891;Float;False;Property;_ScatteringOffset;Scattering Offset;7;0;Create;True;0;0;False;0;-1;1.25;-6;6;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;175;-2187.959,931.3331;Float;False;Blinn-Phong Half Vector;-1;;10;91a149ac9d615be429126c95e20753ce;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.ColorNode;249;-2164.409,-2400.633;Float;False;Property;_ScatteringTint;Scattering Tint;3;0;Create;True;0;0;False;0;0.5235849,0.8924802,1,1;0.7921569,0.4654653,0.3568626,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;250;-1909.63,-2225.053;Float;False;Constant;_Float5;Float 5;21;0;Create;True;0;0;False;0;0.33;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;182;-2168.564,-1087.024;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;13;-1840.606,-250.3133;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;146;-1880.926,990.228;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;34;-1479.294,-2724.493;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;149;-1854.558,1146.036;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;11;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;204;-1466.59,-1686.268;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-1727.061,-2500.227;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.1509434;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;95;-574.6301,-3287.994;Float;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;228;-534.9589,667.388;Float;False;1304.468;594.9589;;8;220;223;218;219;222;226;225;224;Displacement Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;190;-1828.793,-1015.689;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;209;-1713.503,-908.4107;Float;False;Property;_ScatteringIntensity;Scattering Intensity;6;0;Create;True;0;0;False;0;0.45;6;0;6;0;1;FLOAT;0
Node;AmplifyShaderEditor.Exp2OpNode;150;-1661.517,1088.01;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;97;-1199.261,-2732.789;Float;False;Screen;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.FunctionNode;220;-484.9589,938.5433;Float;False;WorldSpaceCoordDual;-1;;12;39024daf4a9269e428da367a6e63e26b;0;2;15;FLOAT;12;False;20;FLOAT;0;False;2;FLOAT2;0;FLOAT2;16
Node;AmplifyShaderEditor.SaturateNode;159;-1742.095,940.0062;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;143;-2162.064,335.1668;Float;False;Property;_ReflectionFresnel;Reflection Fresnel;10;0;Create;True;0;0;False;0;6;5;0.1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RelayNode;207;-1688.106,-2052.791;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;205;-1446.877,-1599.483;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-0.2;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;39;-1545.347,-267.4932;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.25;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;185;-1830.481,-1135.271;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;223;-427.5756,1059.323;Float;False;DualPanner;-1;;13;493d5f6edc56fb549b8eb8a84e9af86c;0;3;6;FLOAT2;0,0;False;7;FLOAT2;0,0;False;8;FLOAT;22;False;2;FLOAT2;0;FLOAT2;9
Node;AmplifyShaderEditor.SaturateNode;201;-1370.867,-1403.845;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IndirectSpecularLight;135;-1752.03,427.7491;Float;False;World;3;0;FLOAT3;0,0,1;False;1;FLOAT;0.5;False;2;FLOAT;1;False;1;FLOAT3;0
Node;AmplifyShaderEditor.FresnelNode;103;-1813.469,211.8872;Float;False;Standard;WorldNormal;ViewDir;True;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;140;-884.2722,-2667.42;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;214;-1383.468,-713.2832;Float;False;Property;_WaterEmission;Water Emission;5;0;Create;True;0;0;False;0;0.2;0.029;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;208;-1396.799,-1080.098;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;180;-1334.49,1246.717;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.0025;False;2;FLOAT;100;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;36;-1252.672,-2303.074;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;35;-1152.536,-2482.299;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SaturateNode;186;-1397.539,-1201.499;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;148;-1562.251,934.0948;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;151;-1485.026,1039.199;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;153;-1193.308,940.298;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;6;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;218;-139.9587,842.5433;Float;False;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;158;-521.1266,262.9389;Float;False;701.3131;183;;2;101;100;Shore Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;213;-1059.468,-753.2831;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightAttenuation;152;-1617.45,1186.897;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-732.1374,-2513.841;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;-1111.377,-1327.249;Float;True;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;-1410.418,381.4421;Float;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ToggleSwitchNode;217;-1659.533,1272.302;Float;False;Property;_UseSpecularGloss;Use Specular Gloss;8;0;Create;True;0;0;False;0;1;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;219;-105.9587,969.5433;Float;False;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;225;207.7827,1147.347;Float;False;Property;_DisplacementNoisePower;Displacement Noise Power;19;0;Create;True;0;0;False;0;0.3;0.193;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;226;417.9467,717.3879;Float;False;Constant;_Vector4;Vector 4;18;0;Create;True;0;0;False;0;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;156;-494.7725,-118.2896;Float;False;204;183;;1;155;Final Mix;1,1,1,1;0;0
Node;AmplifyShaderEditor.BlendOpsNode;138;-655.6505,-2292.624;Float;False;Screen;True;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;101;-471.1268,323.845;Float;False;Property;_ShoreBlendDistance;Shore Blend Distance;1;0;Create;True;0;0;False;0;0.02;0.02;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;222;209.0412,932.5433;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;154;-1179.635,1088.499;Float;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;210;-1038.799,-1065.24;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightAttenuation;211;-1099.701,-909.5547;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;215;-870.1886,-1222.618;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DepthFade;100;-92.81369,312.9388;Float;False;True;True;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;54;-1300.148,2025.337;Float;False;Constant;_Vector0;Vector 0;5;0;Create;True;0;0;False;0;0,1,0,1.33;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;155;-444.7724,-68.28959;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;50;-1029.426,2016.942;Float;False;5;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;1,0;False;3;FLOAT2;0,0;False;4;FLOAT2;1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;73;-1560.764,-4137.676;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;224;600.5093,888.8624;Float;False;3;3;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;212;-697.2503,-1195.397;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;56;-1093.128,1793.008;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;358.232,-288.3465;Float;False;True;6;Float;ASEMaterialInspector;0;0;CustomLighting;DCG/Water/Lowpoly Water;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;False;150;True;Transparent;;AlphaTest;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;1;3;10;25;False;0;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;0;-1;-1;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;2;0;3;0
WireConnection;1;0;3;0
WireConnection;4;0;2;0
WireConnection;4;1;1;0
WireConnection;115;0;4;0
WireConnection;68;0;67;1
WireConnection;68;1;67;3
WireConnection;69;0;68;0
WireConnection;69;1;70;0
WireConnection;69;2;87;0
WireConnection;124;0;115;0
WireConnection;58;0;124;0
WireConnection;55;0;46;1
WireConnection;55;1;46;2
WireConnection;83;0;69;0
WireConnection;49;0;55;0
WireConnection;49;1;58;0
WireConnection;61;0;44;0
WireConnection;89;0;88;0
WireConnection;89;1;90;0
WireConnection;86;0;83;0
WireConnection;86;1;85;0
WireConnection;77;0;76;0
WireConnection;77;1;79;0
WireConnection;71;0;69;0
WireConnection;71;2;88;0
WireConnection;72;0;86;0
WireConnection;72;2;89;0
WireConnection;230;0;229;0
WireConnection;62;0;61;0
WireConnection;62;1;60;0
WireConnection;43;0;49;0
WireConnection;43;1;44;0
WireConnection;66;0;64;0
WireConnection;66;1;71;0
WireConnection;231;0;230;0
WireConnection;65;0;64;0
WireConnection;65;1;72;0
WireConnection;78;0;77;0
WireConnection;59;0;43;0
WireConnection;59;1;62;0
WireConnection;45;0;59;0
WireConnection;45;1;42;0
WireConnection;233;0;232;0
WireConnection;233;1;231;0
WireConnection;74;0;66;1
WireConnection;74;1;65;1
WireConnection;81;0;78;0
WireConnection;236;0;234;0
WireConnection;236;1;233;0
WireConnection;237;0;235;0
WireConnection;237;1;233;0
WireConnection;242;0;45;0
WireConnection;82;0;74;0
WireConnection;82;1;81;0
WireConnection;239;0;242;0
WireConnection;239;1;236;0
WireConnection;238;0;242;0
WireConnection;238;1;237;0
WireConnection;93;0;82;0
WireConnection;91;0;93;0
WireConnection;200;0;198;0
WireConnection;200;1;191;0
WireConnection;40;0;242;0
WireConnection;240;0;238;0
WireConnection;241;0;239;0
WireConnection;75;0;76;0
WireConnection;202;0;200;0
WireConnection;243;0;241;1
WireConnection;243;1;40;2
WireConnection;243;2;240;3
WireConnection;80;0;75;0
WireConnection;245;16;20;0
WireConnection;245;15;27;0
WireConnection;94;0;91;0
WireConnection;13;0;12;0
WireConnection;13;1;124;0
WireConnection;146;0;175;0
WireConnection;146;1;124;0
WireConnection;34;0;245;0
WireConnection;34;1;243;0
WireConnection;149;0;137;0
WireConnection;204;0;202;0
WireConnection;21;0;249;0
WireConnection;21;1;250;0
WireConnection;95;0;94;0
WireConnection;95;1;80;0
WireConnection;95;2;99;0
WireConnection;190;0;187;2
WireConnection;190;1;189;0
WireConnection;150;0;149;0
WireConnection;97;0;95;0
WireConnection;97;1;34;0
WireConnection;159;0;146;0
WireConnection;207;0;21;0
WireConnection;205;0;204;0
WireConnection;39;0;13;0
WireConnection;185;0;182;2
WireConnection;185;1;190;0
WireConnection;223;6;220;0
WireConnection;223;7;220;16
WireConnection;201;0;205;0
WireConnection;135;0;124;0
WireConnection;135;1;137;0
WireConnection;103;0;124;0
WireConnection;103;3;143;0
WireConnection;140;0;97;0
WireConnection;140;1;39;0
WireConnection;208;0;207;0
WireConnection;208;1;209;0
WireConnection;180;0;137;0
WireConnection;186;0;185;0
WireConnection;148;0;159;0
WireConnection;148;1;150;0
WireConnection;153;0;148;0
WireConnection;153;1;180;0
WireConnection;218;0;223;0
WireConnection;213;0;21;0
WireConnection;213;1;214;0
WireConnection;41;0;140;0
WireConnection;41;1;35;0
WireConnection;41;2;36;0
WireConnection;206;0;201;0
WireConnection;206;1;186;0
WireConnection;206;2;208;0
WireConnection;136;0;103;0
WireConnection;136;1;135;0
WireConnection;219;0;223;9
WireConnection;138;0;136;0
WireConnection;138;1;41;0
WireConnection;222;0;218;0
WireConnection;222;1;219;0
WireConnection;154;0;153;0
WireConnection;154;1;151;0
WireConnection;154;2;152;0
WireConnection;154;3;217;0
WireConnection;215;0;206;0
WireConnection;215;1;213;0
WireConnection;100;0;101;0
WireConnection;155;0;138;0
WireConnection;155;1;154;0
WireConnection;50;0;43;0
WireConnection;50;1;54;1
WireConnection;50;2;54;2
WireConnection;50;3;54;3
WireConnection;50;4;54;4
WireConnection;224;0;222;0
WireConnection;224;1;226;0
WireConnection;224;2;225;0
WireConnection;212;0;215;0
WireConnection;212;1;210;0
WireConnection;212;2;211;0
WireConnection;0;2;212;0
WireConnection;0;9;100;0
WireConnection;0;13;155;0
WireConnection;0;11;224;0
ASEEND*/
//CHKSM=65C3686FD6EA07F21FE6B283CAAB920968F0D4DD