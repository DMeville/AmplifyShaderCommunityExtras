// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DMToon"
{
	Properties
	{
		_Albedo("Albedo", 2D) = "white" {}
		_Color("Color", Color) = (0,0,0,0)
		_LightScale("LightScale", Float) = 0.3
		[HDR]_ShadowTint("ShadowTint", Color) = (0,0,0,0)
		_ShadowOffset("ShadowOffset", Float) = 0
		_ShadowSharpness("ShadowSharpness", Float) = 0
		[HDR]_SpecularColor("SpecularColor", Color) = (0,0,0,0)
		_Specularity("Specularity", Float) = 159.88
		_Glossiness("Glossiness", Range( 0 , 30)) = 4.192941
		_SpecularSmoothstep("Specular Smoothstep", Vector) = (0,0,0,0)
		[HDR]_RimColor("RimColor", Color) = (0,1,0.8758622,0)
		_RimOffset("RimOffset", Float) = 0.24
		_RimPower("Rim Power", Range( 0 , 10)) = 0.5
		_Normals("Normals", 2D) = "bump" {}
		_NormalScale("Normal Scale", Range( -1 , 1)) = 0
		_OutlineColorMultiplier("OutlineColorMultiplier", Range( 0 , 1)) = 1
		_OutlineWidth("Outline Width", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ }
		Cull Front
		CGPROGRAM
		#pragma target 3.0
		#pragma surface outlineSurf Outline nofog  keepalpha noshadow noambient novertexlights nolightmap nodynlightmap nodirlightmap nometa noforwardadd vertex:outlineVertexDataFunc 
		void outlineVertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float outlineVar = _OutlineWidth;
			v.vertex.xyz += ( v.normal * outlineVar );
		}
		inline half4 LightingOutline( SurfaceOutput s, half3 lightDir, half atten ) { return half4 ( 0,0,0, s.Alpha); }
		void outlineSurf( Input i, inout SurfaceOutput o )
		{
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 TintedAlbedo47 = ( tex2D( _Albedo, uv_Albedo ) * _Color );
			float4 Emission72 = ( _ShadowTint * TintedAlbedo47 * UNITY_LIGHTMODEL_AMBIENT );
			o.Emission = ( Emission72 * _OutlineColorMultiplier ).rgb;
		}
		ENDCG
		

		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			INTERNAL_DATA
			float3 worldPos;
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

		uniform float4 _ShadowTint;
		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform float4 _Color;
		uniform float2 _SpecularSmoothstep;
		uniform float _NormalScale;
		uniform sampler2D _Normals;
		uniform float4 _Normals_ST;
		uniform float _Glossiness;
		uniform float _Specularity;
		uniform float4 _SpecularColor;
		uniform float _LightScale;
		uniform float _ShadowOffset;
		uniform float _ShadowSharpness;
		uniform float _RimOffset;
		uniform float _RimPower;
		uniform float4 _RimColor;
		uniform float _OutlineWidth;
		uniform float _OutlineColorMultiplier;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 Outline79 = 0;
			v.vertex.xyz += Outline79;
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
			float2 uv_Normals = i.uv_texcoord * _Normals_ST.xy + _Normals_ST.zw;
			float3 Normals95 = UnpackScaleNormal( tex2D( _Normals, uv_Normals ), _NormalScale );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			#if defined(LIGHTMAP_ON) && UNITY_VERSION < 560 //aseld
			float3 ase_worldlightDir = 0;
			#else //aseld
			float3 ase_worldlightDir = normalize( UnityWorldSpaceLightDir( ase_worldPos ) );
			#endif //aseld
			float3 normalizeResult4_g2 = normalize( ( ase_worldViewDir + ase_worldlightDir ) );
			float dotResult22 = dot( normalize( (WorldNormalVector( i , Normals95 )) ) , normalizeResult4_g2 );
			float clampResult29 = clamp( dotResult22 , 0.0 , 1.0 );
			float smoothstepResult91 = smoothstep( _SpecularSmoothstep.x , _SpecularSmoothstep.y , ( pow( clampResult29 , exp2( _Glossiness ) ) * _Specularity ));
			#if defined(LIGHTMAP_ON) && ( UNITY_VERSION < 560 || ( defined(LIGHTMAP_SHADOW_MIXING) && !defined(SHADOWS_SHADOWMASK) && defined(SHADOWS_SCREEN) ) )//aselc
			float4 ase_lightColor = 0;
			#else //aselc
			float4 ase_lightColor = _LightColor0;
			#endif //aselc
			float4 Spec66 = ( saturate( smoothstepResult91 ) * _SpecularColor * ase_lightColor * ase_lightAtten );
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 TintedAlbedo47 = ( tex2D( _Albedo, uv_Albedo ) * _Color );
			float dotResult4 = dot( normalize( (WorldNormalVector( i , Normals95 )) ) , ase_worldlightDir );
			float WorldDotLight6 = dotResult4;
			float clampResult24 = clamp( ( ( WorldDotLight6 + _ShadowOffset ) * _ShadowSharpness ) , 0.0 , 1.0 );
			float clampResult38 = clamp( ( ase_lightAtten * clampResult24 ) , 0.0 , 1.0 );
			float ShadowMask58 = clampResult38;
			float dotResult14 = dot( normalize( (WorldNormalVector( i , Normals95 )) ) , ase_worldViewDir );
			float4 RimColor63 = ( saturate( ( ( WorldDotLight6 * ase_lightAtten ) * pow( ( 1.0 - saturate( ( dotResult14 + _RimOffset ) ) ) , _RimPower ) ) ) * _RimColor * _RimColor.a * ase_lightColor );
			float4 CustomLighting80 = saturate( ( Spec66 + ( TintedAlbedo47 * ( ase_lightColor * _LightScale ) * ShadowMask58 ) + RimColor63 ) );
			c.rgb = CustomLighting80.rgb;
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
			o.Normal = float3(0,0,1);
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			float4 TintedAlbedo47 = ( tex2D( _Albedo, uv_Albedo ) * _Color );
			float4 Emission72 = ( _ShadowTint * TintedAlbedo47 * UNITY_LIGHTMODEL_AMBIENT );
			o.Emission = Emission72.rgb;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardCustomLighting keepalpha fullforwardshadows vertex:vertexDataFunc 

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
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
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
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16800
671;73;1444;778;2218.7;2337.921;3.016847;True;False
Node;AmplifyShaderEditor.CommentaryNode;99;-2325.871,-1413.903;Float;False;831.9146;313.1678;Comment;3;100;95;94;Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;100;-2284.085,-1311.967;Float;False;Property;_NormalScale;Normal Scale;14;0;Create;True;0;0;False;0;0;0;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;94;-2018.067,-1365.41;Float;True;Property;_Normals;Normals;13;0;Create;True;0;0;False;0;None;f53512d44b91e954dae7bf028209df1a;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;1;-1478.417,-1418.964;Float;False;836.6255;384.7068;Comment;5;96;2;6;4;3;WorldDotLight;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;95;-1705.295,-1361.794;Float;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;96;-1452.424,-1360.126;Float;False;95;Normals;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;3;-1275.485,-1203.988;Float;False;False;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;2;-1262.993,-1361.24;Float;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;7;-1554.876,-418.0767;Float;False;2137.645;550.9127;;19;63;61;48;46;51;40;34;33;30;89;28;31;21;20;14;13;9;11;98;Rim Light;1,1,1,1;0;0
Node;AmplifyShaderEditor.DotProductOpNode;4;-1011.842,-1265.214;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;15;-1782.996,-970.6217;Float;False;1998.762;474.0247;;19;66;57;45;52;90;53;91;41;92;39;32;36;29;26;23;22;17;19;97;Spec;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;98;-1518.046,-339.0741;Float;False;95;Normals;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-872.8873,-1255.687;Float;False;WorldDotLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;5;317.9308,-1420.479;Float;False;1082.442;371.774;Shadowmask (no color);12;58;49;42;38;25;24;18;16;12;10;8;88;Toon-ify lights/shadows;1,1,1,1;0;0
Node;AmplifyShaderEditor.WorldNormalVector;11;-1310.382,-370.2595;Float;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;9;-1308.701,-173.8482;Float;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;97;-1737.584,-907.0498;Float;False;95;Normals;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;10;372.7949,-1354.2;Float;False;6;WorldDotLight;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;373.6869,-1254.561;Float;False;Property;_ShadowOffset;ShadowOffset;4;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;16;593.4885,-1312.13;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;19;-1530.813,-764.7902;Float;False;Blinn-Phong Half Vector;-1;;2;91a149ac9d615be429126c95e20753ce;0;0;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;13;-1307.431,-14.38029;Float;False;Property;_RimOffset;RimOffset;11;0;Create;True;0;0;False;0;0.24;0.24;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;367.9319,-1163.706;Float;False;Property;_ShadowSharpness;ShadowSharpness;5;0;Create;True;0;0;False;0;0;50;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;17;-1534.202,-920.6218;Float;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;14;-1097.383,-185.3152;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;-969.4885,-166.0462;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;22;-1272.155,-889.8726;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1516.854,-603.6201;Float;False;Property;_Glossiness;Glossiness;8;0;Create;True;0;0;False;0;4.192941;1.7;0;30;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;727.6516,-1290.258;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightAttenuation;88;740.5883,-1376.279;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;27;-566.4028,-1520.915;Float;False;845.2498;484.4934;;4;47;43;37;35;Tinted Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.Exp2OpNode;26;-1230.144,-605.4882;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;21;-841.5736,-156.1741;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;24;876.143,-1220.288;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;29;-1123.054,-894.3593;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;31;-819.3878,-371.5037;Float;False;6;WorldDotLight;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;36;-945.7343,-882.1416;Float;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-986.6565,-773.5862;Float;False;Property;_Specularity;Specularity;7;0;Create;True;0;0;False;0;159.88;0.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;35;-507.0087,-1243.422;Float;False;Property;_Color;Color;1;0;Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LightAttenuation;89;-804.2977,-283.6034;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;30;-695.1932,-156.1741;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;37;-516.4038,-1470.915;Float;True;Property;_Albedo;Albedo;0;0;Create;True;0;0;False;0;None;84508b93f15f2b64386ec07486afc7a3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;25;1049.807,-1252.92;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-873.0864,-50.4943;Float;False;Property;_RimPower;Rim Power;12;0;Create;True;0;0;False;0;0.5;2.9;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;34;-503.1935,-184.3592;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;92;-952.5984,-693.6652;Float;False;Property;_SpecularSmoothstep;Specular Smoothstep;9;0;Create;True;0;0;False;0;0,0;0.9,0.93;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;33;-493.9845,-311.7487;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-776.4676,-892.11;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;-140.7508,-1374.953;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;38;1220.685,-1248.352;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;40;-271.8643,-290.0766;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;41;-598.2553,-706.3436;Float;False;Property;_SpecularColor;SpecularColor;6;1;[HDR];Create;True;0;0;False;0;0,0,0,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;91;-608.8699,-890.614;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;42;1353.298,-1255.937;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;50;1528.379,-1185.265;Float;False;839.3904;449.7384;Comment;5;72;67;56;55;54;Base, shadowed before any lights add passes;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;35.84705,-1368.986;Float;False;TintedAlbedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;49;1125.206,-1321.552;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;51;-309.3936,-175.9642;Float;False;Property;_RimColor;RimColor;10;1;[HDR];Create;True;0;0;False;0;0,1,0.8758622,0;0,1367.12,809.828,0.003921569;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;54;1582.468,-1135.265;Float;False;Property;_ShadowTint;ShadowTint;3;1;[HDR];Create;True;0;0;False;0;0,0,0,0;0,1.231373,2,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;56;1578.379,-927.3286;Float;False;47;TintedAlbedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LightColorNode;48;-292.1636,9.592379;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.WireNode;52;-366.337,-784.4511;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;44;1521.34,-646.7816;Float;False;1203.894;438.6239;Comment;11;80;77;73;70;69;68;65;64;62;60;59;Per light, additive stuff;1,1,1,1;0;0
Node;AmplifyShaderEditor.LightAttenuation;90;-362.2397,-613.8602;Float;False;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;45;-393.6375,-892.5867;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;53;-356.6556,-738.5093;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.FogAndAmbientColorsNode;55;1584.035,-832.4301;Float;False;UNITY_LIGHTMODEL_AMBIENT;0;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;46;-79.86539,-290.0766;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-116.359,-915.3408;Float;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;61;112.1346,-290.0766;Float;False;4;4;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;60;1580.247,-399.8484;Float;False;Property;_LightScale;LightScale;2;0;Create;True;0;0;False;0;0.3;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;59;1572.718,-530.2188;Float;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;67;1961.807,-1046.568;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;58;1153.709,-1378.978;Float;False;ShadowMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;21.48306,-913.9579;Float;False;Spec;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;65;1570.77,-299.1676;Float;False;58;ShadowMask;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;72;2141.138,-1050.065;Float;False;Emission;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;71;255.3858,-958.6806;Float;False;984.4829;354.9595;Comment;6;79;86;87;74;75;101;Outline;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;62;1774.72,-489.8193;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;64;1571.342,-596.7817;Float;False;47;TintedAlbedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;63;297.2037,-241.4145;Float;False;RimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;2111.674,-594.1398;Float;False;66;Spec;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;68;2028.477,-518.2326;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;74;276.1389,-894.6588;Float;False;72;Emission;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;75;285.7667,-800.3561;Float;False;Property;_OutlineColorMultiplier;OutlineColorMultiplier;15;0;Create;True;0;0;False;0;1;0.18;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;70;2145.554,-366.0585;Float;False;63;RimColor;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;595.1654,-890.0112;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;2382.085,-587.4719;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;101;330.3907,-692.7694;Float;False;Property;_OutlineWidth;Outline Width;16;0;Create;True;0;0;False;0;0;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;77;2528.56,-584.0997;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OutlineNode;86;740.1669,-895.0112;Float;False;0;True;None;0;0;Front;3;0;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;80;2499.241,-420.6152;Float;False;CustomLighting;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;79;969.7171,-898.2429;Float;False;Outline;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;82;2454.764,-824.9918;Float;False;79;Outline;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;81;2441.089,-936.8341;Float;False;80;CustomLighting;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;83;2474.916,-1116.013;Float;False;72;Emission;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;2690.223,-1161.034;Float;False;True;2;Float;ASEMaterialInspector;0;0;CustomLighting;DMToon;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;94;5;100;0
WireConnection;95;0;94;0
WireConnection;2;0;96;0
WireConnection;4;0;2;0
WireConnection;4;1;3;0
WireConnection;6;0;4;0
WireConnection;11;0;98;0
WireConnection;16;0;10;0
WireConnection;16;1;8;0
WireConnection;17;0;97;0
WireConnection;14;0;11;0
WireConnection;14;1;9;0
WireConnection;20;0;14;0
WireConnection;20;1;13;0
WireConnection;22;0;17;0
WireConnection;22;1;19;0
WireConnection;18;0;16;0
WireConnection;18;1;12;0
WireConnection;26;0;23;0
WireConnection;21;0;20;0
WireConnection;24;0;18;0
WireConnection;29;0;22;0
WireConnection;36;0;29;0
WireConnection;36;1;26;0
WireConnection;30;0;21;0
WireConnection;25;0;88;0
WireConnection;25;1;24;0
WireConnection;34;0;30;0
WireConnection;34;1;28;0
WireConnection;33;0;31;0
WireConnection;33;1;89;0
WireConnection;39;0;36;0
WireConnection;39;1;32;0
WireConnection;43;0;37;0
WireConnection;43;1;35;0
WireConnection;38;0;25;0
WireConnection;40;0;33;0
WireConnection;40;1;34;0
WireConnection;91;0;39;0
WireConnection;91;1;92;1
WireConnection;91;2;92;2
WireConnection;42;0;38;0
WireConnection;47;0;43;0
WireConnection;49;0;42;0
WireConnection;52;0;41;0
WireConnection;45;0;91;0
WireConnection;46;0;40;0
WireConnection;57;0;45;0
WireConnection;57;1;52;0
WireConnection;57;2;53;0
WireConnection;57;3;90;0
WireConnection;61;0;46;0
WireConnection;61;1;51;0
WireConnection;61;2;51;4
WireConnection;61;3;48;0
WireConnection;67;0;54;0
WireConnection;67;1;56;0
WireConnection;67;2;55;0
WireConnection;58;0;49;0
WireConnection;66;0;57;0
WireConnection;72;0;67;0
WireConnection;62;0;59;0
WireConnection;62;1;60;0
WireConnection;63;0;61;0
WireConnection;68;0;64;0
WireConnection;68;1;62;0
WireConnection;68;2;65;0
WireConnection;87;0;74;0
WireConnection;87;1;75;0
WireConnection;73;0;69;0
WireConnection;73;1;68;0
WireConnection;73;2;70;0
WireConnection;77;0;73;0
WireConnection;86;0;87;0
WireConnection;86;1;101;0
WireConnection;80;0;77;0
WireConnection;79;0;86;0
WireConnection;0;2;83;0
WireConnection;0;13;81;0
WireConnection;0;11;82;0
ASEEND*/
//CHKSM=D793A9352C3E9C7A3F76540661242A7DAAFEAD56