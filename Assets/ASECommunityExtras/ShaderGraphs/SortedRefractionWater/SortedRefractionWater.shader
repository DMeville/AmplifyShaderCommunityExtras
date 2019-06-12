// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DM/SortedRefraction"
{
	Properties
	{
		_Normals("Normals", 2D) = "bump" {}
		_Strength("Strength", Float) = 0.1
		_Timescale("Timescale", Float) = 1
		_DeepColor("Deep Color", Color) = (0,0,0,0)
		_TopColor("TopColor", Color) = (0,0,0,0)
		_Depth("Depth", Float) = 49
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		GrabPass{ }
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 3.5
		UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture); 
		#pragma surface surf Standard alpha:fade keepalpha addshadow fullforwardshadows  
		struct Input
		{
			float2 uv_texcoord;
			float4 screenPos;
		};

		uniform float4 _CameraDepthTexture_TexelSize;
		uniform float _Strength;
		uniform sampler2D _Normals;
		uniform float _Timescale;
		uniform sampler2D _GrabTexture;
		uniform float4 _TopColor;
		uniform float4 _DeepColor;
		uniform float _Depth;
		uniform float _Metallic;
		uniform float _Smoothness;


		float2 AlignWithGrabTexel( float2 uv )
		{
			#if UNITY_UV_STARTS_AT_TOP
			if (_CameraDepthTexture_TexelSize.y < 0) {
				uv.y = 1 - uv.y;
			}
			#endif
			return (floor(uv * _CameraDepthTexture_TexelSize.zw) + 0.5) * abs(_CameraDepthTexture_TexelSize.xy);
		}


		void ResetAlpha( Input SurfaceIn , SurfaceOutputStandard SurfaceOut , inout fixed4 FinalColor )
		{
			FinalColor.a = 1;
		}


		float GetRefractedDepth55( float3 tangentSpaceNormal , float4 screenPos , inout float2 uv )
		{
			float2 uvOffset = tangentSpaceNormal.xy;
			uvOffset.y *= _CameraDepthTexture_TexelSize.z * abs(_CameraDepthTexture_TexelSize.y);
			uv = AlignWithGrabTexel((screenPos.xy + uvOffset) / screenPos.w);
			float backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
			float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(screenPos.z);
			float depthDifference = backgroundDepth - surfaceDepth;
			uvOffset *= saturate(depthDifference);
			uv = AlignWithGrabTexel((screenPos.xy + uvOffset) / screenPos.w);
			backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv));
			return depthDifference = backgroundDepth - surfaceDepth;
		}


		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float mulTime28 = _Time.y * _Timescale;
			float cos27 = cos( mulTime28 );
			float sin27 = sin( mulTime28 );
			float2 rotator27 = mul( i.uv_texcoord - float2( 0.5,0.5 ) , float2x2( cos27 , -sin27 , sin27 , cos27 )) + float2( 0.5,0.5 );
			float3 Normals77 = UnpackScaleNormal( tex2D( _Normals, rotator27 ), _Strength );
			o.Normal = Normals77;
			float3 tangentSpaceNormal55 = Normals77;
			float4 ase_screenPos = float4( i.screenPos.xyz , i.screenPos.w + 0.00000000001 );
			float4 screenPos55 = ase_screenPos;
			float2 uv55 = float2( 0,0 );
			float localGetRefractedDepth55 = GetRefractedDepth55( tangentSpaceNormal55 , screenPos55 , uv55 );
			float2 RefractedUVS66 = uv55;
			float4 screenColor37 = tex2D( _GrabTexture, RefractedUVS66 );
			float RefractedDepth64 = saturate( ( localGetRefractedDepth55 / _Depth ) );
			float4 lerpResult44 = lerp( ( screenColor37 * _TopColor ) , _DeepColor , RefractedDepth64);
			o.Emission = ( lerpResult44 * _TopColor.a ).rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16700
741;73;1536;777;2485.097;1211.858;1.916041;True;False
Node;AmplifyShaderEditor.CommentaryNode;81;-2956.464,-969.7385;Float;False;1306.332;343.1838;Comment;7;29;30;28;27;5;3;77;Animated Normals;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;29;-2906.464,-780.6386;Float;False;Property;_Timescale;Timescale;2;0;Create;True;0;0;False;0;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;30;-2792.062,-919.7385;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;28;-2728.36,-788.4385;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RotatorNode;27;-2455.36,-896.3394;Float;False;3;0;FLOAT2;0,0;False;1;FLOAT2;0.5,0.5;False;2;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2431.25,-762.238;Float;False;Property;_Strength;Strength;1;0;Create;True;0;0;False;0;0.1;0.28;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-2208.884,-856.5546;Float;True;Property;_Normals;Normals;0;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;77;-1893.132,-860.3583;Float;False;Normals;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;82;-2962.055,-569.0341;Float;False;1319.979;403.3264;Comment;8;56;60;55;66;59;61;80;64;Refracted uvs and depth;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;-2912.055,-483.1249;Float;False;77;Normals;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ScreenPosInputsNode;56;-2818.811,-372.7076;Float;False;1;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;55;-2541.801,-433.7443;Float;False;float2 uvOffset = tangentSpaceNormal.xy@$uvOffset.y *= _CameraDepthTexture_TexelSize.z * abs(_CameraDepthTexture_TexelSize.y)@$uv = AlignWithGrabTexel((screenPos.xy + uvOffset) / screenPos.w)@$$float backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv))@$float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(screenPos.z)@$float depthDifference = backgroundDepth - surfaceDepth@$$uvOffset *= saturate(depthDifference)@$uv = AlignWithGrabTexel((screenPos.xy + uvOffset) / screenPos.w)@$backgroundDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uv))@$return depthDifference = backgroundDepth - surfaceDepth@;1;False;3;True;tangentSpaceNormal;FLOAT3;0,0,0;In;;Float;False;True;screenPos;FLOAT4;0,0,0,0;In;;Float;False;True;uv;FLOAT2;0,0;InOut;;Float;False;GetRefractedDepth;True;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT2;0,0;False;2;FLOAT;0;FLOAT2;3
Node;AmplifyShaderEditor.RangedFloatNode;60;-2407.112,-519.034;Float;False;Property;_Depth;Depth;5;0;Create;True;0;0;False;0;49;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;59;-2192.566,-469.1594;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;66;-2165.032,-353.7026;Float;False;RefractedUVS;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;61;-2053.536,-460.3881;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;67;-1577.934,-639.7211;Float;False;66;RefractedUVS;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;62;-1401.376,-486.2285;Float;False;Property;_TopColor;TopColor;4;0;Create;True;0;0;False;0;0,0,0,0;0.3773585,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScreenColorNode;37;-1378.428,-666.1057;Float;False;Global;_GrabScreen0;Grab Screen 0;5;0;Create;True;0;0;False;0;Object;-1;False;False;1;0;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;64;-1897.076,-459.7549;Float;False;RefractedDepth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;63;-1147.478,-566.6893;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;43;-1403.093,-307.239;Float;False;Property;_DeepColor;Deep Color;3;0;Create;True;0;0;False;0;0,0,0,0;0.3773585,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;65;-1182.499,-242.6204;Float;False;64;RefractedDepth;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;79;-315.1937,-987.4354;Float;False;630.7476;322.4601;Comment;3;18;76;9;Required Functions;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;44;-953.2538,-561.7892;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;71;-766.9747,-164.3348;Float;False;Property;_Metallic;Metallic;6;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;78;-726.9465,-651.0814;Float;False;77;Normals;1;0;OBJECT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;72;-750.9451,-84.60052;Float;False;Property;_Smoothness;Smoothness;7;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;18;-265.1936,-871.9753;Float;False;Global;_CameraDepthTexture_TexelSize;_CameraDepthTexture_TexelSize;2;0;Create;True;0;0;True;0;0,0,0,0;0.0008628128,0.00131579,1159,760;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CustomExpressionNode;9;32.33227,-937.4354;Float;False;#if UNITY_UV_STARTS_AT_TOP$if (_CameraDepthTexture_TexelSize.y < 0) {$	uv.y = 1 - uv.y@$}$#endif$return (floor(uv * _CameraDepthTexture_TexelSize.zw) + 0.5) * abs(_CameraDepthTexture_TexelSize.xy)@;2;False;1;True;uv;FLOAT2;0,0;In;;Float;False;AlignWithGrabTexel;False;True;0;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CustomExpressionNode;76;25.55392,-859.3743;Float;False;FinalColor.a = 1@;7;False;3;True;SurfaceIn;OBJECT;0;In;Input;Float;False;True;SurfaceOut;OBJECT;0;In;SurfaceOutputStandard;Float;False;True;FinalColor;OBJECT;0;InOut;fixed4;Float;False;ResetAlpha;False;True;0;4;0;FLOAT;0;False;1;OBJECT;0;False;2;OBJECT;0;False;3;OBJECT;0;False;2;FLOAT;0;OBJECT;4
Node;AmplifyShaderEditor.OneMinusNode;83;-856.4623,-405.2048;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;84;-664.8582,-489.5107;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-416.4424,-617.4054;Float;False;True;3;Float;ASEMaterialInspector;0;0;Standard;DM/SortedRefraction;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;1;Custom;UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture)@ ;False;;1;;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;70;-1565.653,-1023.986;Float;False;1214.676;108.1244;Because the GetRefractedDepth custom expression needs this, and it doesn't get autogenerated;0;Note: See the "Additional Directives" in the inspector. We add a UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture) " ;1,1,1,1;0;0
WireConnection;28;0;29;0
WireConnection;27;0;30;0
WireConnection;27;2;28;0
WireConnection;3;1;27;0
WireConnection;3;5;5;0
WireConnection;77;0;3;0
WireConnection;55;0;80;0
WireConnection;55;1;56;0
WireConnection;59;0;55;0
WireConnection;59;1;60;0
WireConnection;66;0;55;3
WireConnection;61;0;59;0
WireConnection;37;0;67;0
WireConnection;64;0;61;0
WireConnection;63;0;37;0
WireConnection;63;1;62;0
WireConnection;44;0;63;0
WireConnection;44;1;43;0
WireConnection;44;2;65;0
WireConnection;83;0;62;4
WireConnection;84;0;44;0
WireConnection;84;1;62;4
WireConnection;0;1;78;0
WireConnection;0;2;84;0
WireConnection;0;3;71;0
WireConnection;0;4;72;0
ASEEND*/
//CHKSM=8C56892392FD5D2B510F45ACE0B9A034323BE48A