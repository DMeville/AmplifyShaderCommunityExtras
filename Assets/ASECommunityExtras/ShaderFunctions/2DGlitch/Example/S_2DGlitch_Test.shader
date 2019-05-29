// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Test/2DGlitchTest"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Color) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
		_GlitchAmount("GlitchAmount", Range( 0 , 1)) = 0
		_TimeScale("TimeScale", Float) = 0
		_RectSize("RectSize", Range( 1 , 4)) = 0
		_Perturbation("Perturbation", Float) = 0
		_HorizontalGlitchAmount("HorizontalGlitchAmount", Float) = 0
		_VerticalGlitchAmount("VerticalGlitchAmount", Float) = 1
		_AlphaSquaresSize("AlphaSquaresSize", Float) = 0
		_NoiseTiling("NoiseTiling", Range( 0 , 1)) = 0
		_NoiseThreshold("NoiseThreshold", Range( 0 , 1)) = 0
		_NoiseTexture("NoiseTexture", 2D) = "white" {}
	}

	SubShader
	{
		Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "PreviewType"="Plane" "CanUseSpriteAtlas"="True" }

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha
		
		
		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
			#include "UnityCG.cginc"
			#include "UnityShaderVariables.cginc"


			struct appdata_t
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 texcoord  : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
				
			};
			
			uniform fixed4 _Color;
			uniform float _EnableExternalAlpha;
			uniform sampler2D _MainTex;
			uniform sampler2D _AlphaTex;
			uniform float _RectSize;
			uniform float _GlitchAmount;
			uniform float _NoiseTiling;
			uniform sampler2D _NoiseTexture;
			uniform float _TimeScale;
			uniform float _Perturbation;
			uniform float _NoiseThreshold;
			uniform float _HorizontalGlitchAmount;
			uniform float _VerticalGlitchAmount;
			uniform float _AlphaSquaresSize;
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
			
			
			v2f vert( appdata_t IN  )
			{
				v2f OUT;
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
				UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
				float baseScale85_g45 = _RectSize;
				
				
				IN.vertex.xyz += ( IN.vertex.xyz * ( baseScale85_g45 - 1.0 ) ); 
				OUT.vertex = UnityObjectToClipPos(IN.vertex);
				OUT.texcoord = IN.texcoord;
				OUT.color = IN.color * _Color;
				#ifdef PIXELSNAP_ON
				OUT.vertex = UnityPixelSnap (OUT.vertex);
				#endif

				return OUT;
			}

			fixed4 SampleSpriteTexture (float2 uv)
			{
				fixed4 color = tex2D (_MainTex, uv);

#if ETC1_EXTERNAL_ALPHA
				// get the color from an external texture (usecase: Alpha support for ETC1 on android)
				fixed4 alpha = tex2D (_AlphaTex, uv);
				color.a = lerp (color.a, alpha.r, _EnableExternalAlpha);
#endif //ETC1_EXTERNAL_ALPHA

				return color;
			}
			
			fixed4 frag(v2f IN  ) : SV_Target
			{
				float baseScale85_g45 = _RectSize;
				float2 temp_cast_0 = (baseScale85_g45).xx;
				float2 temp_cast_1 = (( ( -baseScale85_g45 * 0.5 ) + 0.5 )).xx;
				float2 uv089_g45 = IN.texcoord.xy * temp_cast_0 + temp_cast_1;
				float2 scaleUV90_g45 = uv089_g45;
				float2 temp_cast_2 = (_Time.y).xx;
				float simplePerlin2D66 = snoise( temp_cast_2 );
				float mainGlitchAmount151_g45 = ( step( simplePerlin2D66 , 0.0 ) * _GlitchAmount );
				float noiseTiling132_g45 = _NoiseTiling;
				float2 temp_cast_3 = (noiseTiling132_g45).xx;
				float2 uv025_g45 = IN.texcoord.xy * temp_cast_3 + float2( 0,0 );
				float timeScale104_g45 = _TimeScale;
				float mulTime3_g45 = _Time.y * ( timeScale104_g45 * 7.0 );
				float2 temp_cast_4 = (noiseTiling132_g45).xx;
				float2 uv05_g45 = IN.texcoord.xy * temp_cast_4 + float2( 0,0 );
				float temp_output_82_0_g45 = _Perturbation;
				float2 temp_cast_5 = (( ( floor( mulTime3_g45 ) + uv05_g45.y + temp_output_82_0_g45 ) * temp_output_82_0_g45 )).xx;
				float noiseThreshold126_g45 = _NoiseThreshold;
				float U77_g45 = ( (-1.0 + (step( uv025_g45.y , step( tex2D( _NoiseTexture, temp_cast_5 ).r , noiseThreshold126_g45 ) ) - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) * _HorizontalGlitchAmount );
				float2 temp_cast_6 = (noiseTiling132_g45).xx;
				float2 uv026_g45 = IN.texcoord.xy * temp_cast_6 + float2( 0,0 );
				float mulTime4_g45 = _Time.y * ( timeScale104_g45 * 7.0 );
				float2 temp_cast_7 = (noiseTiling132_g45).xx;
				float2 uv08_g45 = IN.texcoord.xy * temp_cast_7 + float2( 0,0 );
				float temp_output_81_0_g45 = _Perturbation;
				float2 temp_cast_8 = (( ( floor( mulTime4_g45 ) + uv08_g45.x + temp_output_81_0_g45 ) * temp_output_81_0_g45 )).xx;
				float V75_g45 = ( (-1.0 + (step( uv026_g45.x , step( tex2D( _NoiseTexture, temp_cast_8 ).r , noiseThreshold126_g45 ) ) - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) * _VerticalGlitchAmount );
				float2 appendResult42_g45 = (float2(U77_g45 , V75_g45));
				float mulTime32_g45 = _Time.y * ( timeScale104_g45 * 1.0 );
				float2 temp_cast_9 = (mulTime32_g45).xx;
				float mulTime73_g45 = _Time.y * ( timeScale104_g45 * 4.21 );
				float2 temp_cast_10 = (( floor( mulTime73_g45 ) * 0.28 )).xx;
				float smoothstepResult72_g45 = smoothstep( 0.3 , 0.7 , tex2D( _NoiseTexture, temp_cast_10 ).r);
				float mulTime9_g45 = _Time.y * ( timeScale104_g45 * 4.1 );
				float temp_output_28_0_g45 = ( smoothstepResult72_g45 * round( ( sin( floor( mulTime9_g45 ) ) * 10.0 ) ) );
				float temp_output_74_0_g45 = _AlphaSquaresSize;
				float2 temp_cast_11 = (temp_output_74_0_g45).xx;
				float2 uv031_g45 = IN.texcoord.xy * temp_cast_11 + float2( 0,0 );
				float2 panner33_g45 = ( temp_output_28_0_g45 * float2( 1,1 ) + uv031_g45);
				float2 temp_cast_12 = ((panner33_g45).x).xx;
				float temp_output_149_0_g45 = ( ( 1.0 - mainGlitchAmount151_g45 ) + noiseThreshold126_g45 );
				float2 temp_cast_13 = (( temp_output_74_0_g45 * 1.32 )).xx;
				float2 uv0166_g45 = IN.texcoord.xy * temp_cast_13 + float2( 0,0 );
				float2 panner165_g45 = ( temp_output_28_0_g45 * float2( 1,1 ) + uv0166_g45);
				float2 temp_cast_14 = ((panner165_g45).y).xx;
				float4 appendResult6 = (float4(1.0 , 1.0 , 1.0 , saturate( ( step( tex2D( _NoiseTexture, temp_cast_12 ).r , temp_output_149_0_g45 ) + step( tex2D( _NoiseTexture, temp_cast_14 ).r , temp_output_149_0_g45 ) ) )));
				
				fixed4 c = ( tex2D( _MainTex, ( scaleUV90_g45 + ( mainGlitchAmount151_g45 * appendResult42_g45 * (-1.0 + (step( tex2D( _NoiseTexture, temp_cast_9 ).r , noiseThreshold126_g45 ) - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) ) ) ) * IN.color * appendResult6 );
				c.rgb *= c.a;
				return c;
			}
		ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=16700
-1912;-1919;1756;1010;2841.443;304.3232;2.229088;True;False
Node;AmplifyShaderEditor.SimpleTimeNode;67;-1659.458,429.3697;Float;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;66;-1470.138,424.1466;Float;False;Simplex2D;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;68;-1253.399,424.4748;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;15;-1397.226,541.1926;Float;False;Property;_GlitchAmount;GlitchAmount;0;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1118.548,982.0674;Float;False;Property;_HorizontalGlitchAmount;HorizontalGlitchAmount;4;0;Create;True;0;0;False;0;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-1067.237,1233.313;Float;False;Property;_AlphaSquaresSize;AlphaSquaresSize;6;0;Create;True;0;0;False;0;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;26;-1032.995,1150.82;Float;False;Property;_Perturbation;Perturbation;3;0;Create;True;0;0;False;0;0;5.14;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;28;-1094.597,1064.773;Float;False;Property;_VerticalGlitchAmount;VerticalGlitchAmount;5;0;Create;True;0;0;False;0;1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1134.894,899.1773;Float;False;Property;_NoiseThreshold;NoiseThreshold;8;0;Create;True;0;0;False;0;0;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1128.211,1315.782;Float;False;Property;_RectSize;RectSize;2;0;Create;True;0;0;False;0;0;4;1;4;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexturePropertyNode;47;-1084.095,626.4133;Float;True;Property;_NoiseTexture;NoiseTexture;9;0;Create;True;0;0;False;0;None;None;False;white;Auto;Texture2D;0;1;SAMPLER2D;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-1030.893,513.5009;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;23;-1043.388,413.0625;Float;False;Property;_TimeScale;TimeScale;1;0;Create;True;0;0;False;0;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-1137.456,818.7354;Float;False;Property;_NoiseTiling;NoiseTiling;7;0;Create;True;0;0;False;0;0;0.05;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode;65;-740.7407,751.1782;Float;True;2DGlitch;-1;;45;bd8fe1e3c0f6ac1469b20cc8dbe6f59a;0;11;103;FLOAT;0.1;False;65;FLOAT;1;False;57;SAMPLER2D;;False;133;FLOAT;0.5;False;125;FLOAT;0.5;False;80;FLOAT;1;False;64;FLOAT;1;False;82;FLOAT;1.27;False;81;FLOAT;1.27;False;74;FLOAT;2.4;False;91;FLOAT;1;False;3;FLOAT2;0;FLOAT;56;FLOAT3;94
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;1;-242.1405,276.9843;Float;False;0;0;_MainTex;Shader;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;6;110.2815,646.7099;Float;False;FLOAT4;4;0;FLOAT;1;False;1;FLOAT;1;False;2;FLOAT;1;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;2;-41.1405,271.9843;Float;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;3;72.85954,467.9843;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WireNode;60;413.403,784.5235;Float;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;288.8596,406.9843;Float;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;634.6002,407.0931;Float;False;True;2;Float;ASEMaterialInspector;0;6;Test/2DGlitchTest;0f8ba0101102bb14ebf021ddadce9b49;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;2;True;3;1;False;-1;10;False;-1;0;1;False;-1;0;False;-1;False;False;True;2;False;-1;False;False;True;2;False;-1;False;False;True;5;Queue=Transparent=Queue=0;IgnoreProjector=True;RenderType=Transparent=RenderType;PreviewType=Plane;CanUseSpriteAtlas=True;False;0;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;2;0;FLOAT4;0,0,0,0;False;1;FLOAT3;0,0,0;False;0
WireConnection;66;0;67;0
WireConnection;68;0;66;0
WireConnection;69;0;68;0
WireConnection;69;1;15;0
WireConnection;65;103;23;0
WireConnection;65;65;69;0
WireConnection;65;57;47;0
WireConnection;65;133;41;0
WireConnection;65;125;44;0
WireConnection;65;80;27;0
WireConnection;65;64;28;0
WireConnection;65;82;26;0
WireConnection;65;81;26;0
WireConnection;65;74;36;0
WireConnection;65;91;19;0
WireConnection;6;3;65;56
WireConnection;2;0;1;0
WireConnection;2;1;65;0
WireConnection;60;0;65;94
WireConnection;4;0;2;0
WireConnection;4;1;3;0
WireConnection;4;2;6;0
WireConnection;0;0;4;0
WireConnection;0;1;60;0
ASEEND*/
//CHKSM=5E67A9F5BA8B621191E478F7970B46462CCB71DD