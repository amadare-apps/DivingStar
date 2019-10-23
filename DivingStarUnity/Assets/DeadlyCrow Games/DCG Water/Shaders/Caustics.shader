// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DCG/Water/Caustics"
{
	Properties
	{
		[NoScaleOffset]_Caustic("Caustic", 2D) = "white" {}
		[NoScaleOffset]_Falloff("Falloff", 2D) = "white" {}
		_Tiling("Tiling", Float) = 10
		[Toggle]_GrabScreenColor("Grab Screen Color", Float) = 0
		_Color("Color", Color) = (1,1,1,1)
		_CausticIntensity("Caustic Intensity", Float) = 1
		_AnimationSpeed("Animation Speed", Range( 0 , 60)) = 24
		[Toggle]_ProjectionMode("Projection Mode", Float) = 0
	}
	
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100
		CGINCLUDE
		#pragma target 3.0
		ENDCG
		Blend DstColor One
		Cull Back
		ColorMask RGB
		ZWrite Off
		ZTest LEqual
		Offset -1 , -1
		
		GrabPass{ }


		Pass
		{
			Name "SubShader 0 Pass 0"
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			#include "UnityStandardBRDF.cginc"


			struct appdata
			{
				float4 vertex : POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				float3 ase_normal : NORMAL;
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_OUTPUT_STEREO
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			uniform float _GrabScreenColor;
			uniform float4 _Color;
			uniform float _CausticIntensity;
			uniform sampler2D _Caustic;
			float4x4 unity_Projector;
			uniform float _Tiling;
			uniform float _AnimationSpeed;
			uniform sampler2D _Falloff;
			float4x4 unity_ProjectorClip;
			uniform sampler2D _GrabTexture;
			uniform float _ProjectionMode;
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
			
			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float4 vertexToFrag11 = mul( unity_Projector, v.vertex );
				o.ase_texcoord = vertexToFrag11;
				float4 vertexToFrag15 = mul( unity_ProjectorClip, v.vertex );
				o.ase_texcoord1 = vertexToFrag15;
				float4 ase_clipPos = UnityObjectToClipPos(v.vertex);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				float3 ase_worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				o.ase_texcoord3.xyz = ase_worldPos;
				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				
				v.vertex.xyz +=  float3(0,0,0) ;
				o.vertex = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				fixed4 finalColor;
				float clampResult47 = clamp( _CausticIntensity , 0.0 , 1000.0 );
				float4 vertexToFrag11 = i.ase_texcoord;
				// *** BEGIN Flipbook UV Animation vars ***
				// Total tiles of Flipbook Texture
				float fbtotaltiles70 = 4.0 * 4.0;
				// Offsets for cols and rows of Flipbook Texture
				float fbcolsoffset70 = 1.0f / 4.0;
				float fbrowsoffset70 = 1.0f / 4.0;
				// Speed of animation
				float fbspeed70 = _Time[ 1 ] * _AnimationSpeed;
				// UV Tiling (col and row offset)
				float2 fbtiling70 = float2(fbcolsoffset70, fbrowsoffset70);
				// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
				// Calculate current tile linear index
				float fbcurrenttileindex70 = round( fmod( fbspeed70 + 0.0, fbtotaltiles70) );
				fbcurrenttileindex70 += ( fbcurrenttileindex70 < 0) ? fbtotaltiles70 : 0;
				// Obtain Offset X coordinate from current tile linear index
				float fblinearindextox70 = round ( fmod ( fbcurrenttileindex70, 4.0 ) );
				// Multiply Offset X by coloffset
				float fboffsetx70 = fblinearindextox70 * fbcolsoffset70;
				// Obtain Offset Y coordinate from current tile linear index
				float fblinearindextoy70 = round( fmod( ( fbcurrenttileindex70 - fblinearindextox70 ) / 4.0, 4.0 ) );
				// Reverse Y to get tiles from Top to Bottom
				fblinearindextoy70 = (int)(4.0-1) - fblinearindextoy70;
				// Multiply Offset Y by rowoffset
				float fboffsety70 = fblinearindextoy70 * fbrowsoffset70;
				// UV Offset
				float2 fboffset70 = float2(fboffsetx70, fboffsety70);
				// Flipbook UV
				half2 fbuv70 = frac( ( ( (vertexToFrag11).xy * _Tiling ) / (vertexToFrag11).w ) ) * fbtiling70 + fboffset70;
				// *** END Flipbook UV Animation vars ***
				float4 tex2DNode18 = tex2D( _Caustic, fbuv70 );
				float4 appendResult25 = (float4(( float4( (( _Color * clampResult47 )).rgb , 0.0 ) * tex2DNode18 ).rgb , ( 1.0 - tex2DNode18.a )));
				float4 vertexToFrag15 = i.ase_texcoord1;
				float4 temp_output_35_0 = ( appendResult25 * tex2D( _Falloff, ( (vertexToFrag15).xy / (vertexToFrag15).w ) ).a );
				float4 screenPos = i.ase_texcoord2;
				float4 ase_grabScreenPos = ASE_ComputeGrabScreenPos( screenPos );
				float4 screenColor41 = tex2Dproj( _GrabTexture, UNITY_PROJ_COORD( ase_grabScreenPos ) );
				float3 ase_worldPos = i.ase_texcoord3.xyz;
				float3 worldSpaceLightDir = Unity_SafeNormalize(UnityWorldSpaceLightDir(ase_worldPos));
				float3 ase_worldNormal = i.ase_texcoord4.xyz;
				float3 normalizedWorldNormal = normalize( ase_worldNormal );
				float dotResult67 = dot( worldSpaceLightDir , normalizedWorldNormal );
				
				
				finalColor = ( lerp(temp_output_35_0,( screenColor41 * temp_output_35_0 ),_GrabScreenColor) * lerp(saturate( dotResult67 ),saturate( (1.0 + (dotResult67 - -1.0) * (-1.0 - 1.0) / (1.0 - -1.0)) ),_ProjectionMode) );
				return finalColor;
			}
			ENDCG
		}
	}
	//CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=15701
2184;169;1710;885;-390.6375;-68.61131;1;True;True
Node;AmplifyShaderEditor.UnityProjectorMatrixNode;8;-2380.882,-448.2843;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.PosVertexDataNode;10;-2380.882,-368.2844;Float;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-2172.881,-448.2843;Float;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexToFragmentNode;11;-2028.88,-448.2843;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;21;-1789.88,-448.2843;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;40;-1573.035,-617.8054;Float;False;Property;_Tiling;Tiling;2;0;Create;True;0;0;False;0;10;133;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;22;-1788.88,-368.2844;Float;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-1450.85,-445.2964;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;13;-1408,464;Float;False;1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;44;-679.087,-676.9681;Float;False;Property;_CausticIntensity;Caustic Intensity;5;0;Create;True;0;0;False;0;1;55;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;20;-1278.447,-391.9721;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.UnityProjectorClipMatrixNode;9;-1408,384;Float;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.ClampOpNode;47;-352.878,-662.5524;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1000;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;73;-1122.355,-393.9696;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-1401.4,-252.0438;Float;False;Property;_AnimationSpeed;Animation Speed;6;0;Create;True;0;0;False;0;24;24;0;60;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;37;-426.7548,-874.8679;Float;False;Property;_Color;Color;4;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;14;-1200,384;Float;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-93.87831,-665.5524;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexturePropertyNode;48;-1070.772,14.66824;Float;True;Property;_Caustic;Caustic;0;1;[NoScaleOffset];Create;True;0;0;False;0;None;bc8ddebb8a5c5a2419040c44c20ec19e;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;70;-960.446,-397.0055;Float;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;4;False;2;FLOAT;4;False;3;FLOAT;24;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.VertexToFragmentNode;15;-1056,384;Float;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ComponentMaskNode;36;-149.755,-451.8675;Float;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode;32;-816,384;Float;False;True;True;False;False;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;18;-662.8263,-224.1101;Float;True;Property;_asdf;asdf;0;1;[NoScaleOffset];Create;True;0;0;False;0;None;84508b93f15f2b64386ec07486afc7a3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ComponentMaskNode;33;-816,464;Float;False;False;False;False;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;63;586.5676,600.9464;Float;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;30;11.93517,-89.13599;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;31;-576,384;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;24;120.2449,-392.8672;Float;False;2;2;0;FLOAT3;0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;66;552.5677,433.9465;Float;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;25;195.5347,-222.8673;Float;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;34;-429,386;Float;True;Property;_Falloff;Falloff;1;1;[NoScaleOffset];Create;True;0;0;False;0;None;2b852a51201397442a9c5d8ead6e107c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DotProductOpNode;67;873.5677,499.7784;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScreenColorNode;41;477.0392,-284.4507;Float;False;Global;_GrabScreen0;Grab Screen 0;4;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;423.7279,-45.82638;Float;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TFHCRemapNode;85;1174.943,586.2358;Float;False;5;0;FLOAT;0;False;1;FLOAT;-1;False;2;FLOAT;1;False;3;FLOAT;1;False;4;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;86;1235.638,398.6113;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;87;1421.637,572.6113;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;710.3945,50.38928;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;42;848.8884,-184.1779;Float;False;Property;_GrabScreenColor;Grab Screen Color;3;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;88;1532.637,402.6113;Float;False;Property;_ProjectionMode;Projection Mode;7;0;Create;True;0;0;False;0;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;1121.242,179.9105;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;38;1459.751,44.07389;Float;False;True;2;Float;ASEMaterialInspector;0;1;DCG/Water/Caustics;0770190933193b94aaa3065e307002fa;0;0;SubShader 0 Pass 0;2;True;1;2;False;-1;1;False;-1;0;1;False;-1;0;False;-1;True;0;False;-1;0;False;-1;True;0;False;-1;True;True;True;True;False;0;False;-1;True;False;1;False;-1;1;False;-1;1;False;-1;5;False;-1;2;False;-1;2;False;-1;2;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;0;False;-1;True;True;-1;False;-1;-1;False;-1;True;1;RenderType=Opaque=RenderType;True;2;0;False;False;False;False;False;False;False;False;False;False;0;;0;0;Standard;0;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;12;0;8;0
WireConnection;12;1;10;0
WireConnection;11;0;12;0
WireConnection;21;0;11;0
WireConnection;22;0;11;0
WireConnection;39;0;21;0
WireConnection;39;1;40;0
WireConnection;20;0;39;0
WireConnection;20;1;22;0
WireConnection;47;0;44;0
WireConnection;73;0;20;0
WireConnection;14;0;9;0
WireConnection;14;1;13;0
WireConnection;46;0;37;0
WireConnection;46;1;47;0
WireConnection;70;0;73;0
WireConnection;70;3;75;0
WireConnection;15;0;14;0
WireConnection;36;0;46;0
WireConnection;32;0;15;0
WireConnection;18;0;48;0
WireConnection;18;1;70;0
WireConnection;33;0;15;0
WireConnection;30;0;18;4
WireConnection;31;0;32;0
WireConnection;31;1;33;0
WireConnection;24;0;36;0
WireConnection;24;1;18;0
WireConnection;25;0;24;0
WireConnection;25;3;30;0
WireConnection;34;1;31;0
WireConnection;67;0;66;0
WireConnection;67;1;63;0
WireConnection;35;0;25;0
WireConnection;35;1;34;4
WireConnection;85;0;67;0
WireConnection;86;0;67;0
WireConnection;87;0;85;0
WireConnection;43;0;41;0
WireConnection;43;1;35;0
WireConnection;42;0;35;0
WireConnection;42;1;43;0
WireConnection;88;0;86;0
WireConnection;88;1;87;0
WireConnection;84;0;42;0
WireConnection;84;1;88;0
WireConnection;38;0;84;0
ASEEND*/
//CHKSM=54FA27A28A5C6FA70E6CE7D16D6D0B5AE3EBC5A2