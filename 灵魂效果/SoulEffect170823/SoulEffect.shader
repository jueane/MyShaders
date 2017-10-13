Shader "Custom/SoulEffect" {
	Properties {
		//_Color ("Color", Color) = (1,1,1,1)


		_RimColor("RimColor", Color) = (0, 1, 1, 1)
		_RimPower("Rim Power", Range(0.1, 8.0)) = 1.0
		_Para1("Para1", Range(0, 10)) = 0
		//_Para2("Para2", Range(0, 10)) = 0
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BackTex("BackGround", 2D) = "white"{}


	}
	SubShader {
	
Tags { 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"

}
		//Cull Off
		//Lighting Off
		//ZWrite Off
		Blend One OneMinusSrcAlpha
		Blend SrcAlpha OneMinusSrcAlpha


		pass{


			//ZWrite Off
		

			CGPROGRAM
			// Physically based Standard lighting model, and enable shadows on all light types
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			// Use shader model 3.0 target, to get nicer looking lighting
			//#pragma target 3.0

			float4 _Color;
			float _Para1;
			float _Para2;
			sampler2D _MainTex;
			sampler2D _BackTex;


			float4 _RimColor;
			float _RimPower;

			struct a2v{
				float4 vertex:POSITION;
				float4 mainTex:TEXCOORD;
				float4 bgTex:TEXCOORD1;

				fixed4 color:COLOR;
				float4 normal:NORMAL;
			};

			struct v2f{
				float4 pos:SV_POSITION;
				float4 screenPos:TEXCOORD3;

				float2 uv:TEXCOORD0;
				float2 uvBg:TEXCOORD1;

				fixed4 color:COLOR;
			};

			v2f vert(a2v v){
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.screenPos = ComputeScreenPos(o.pos);
			
				o.uv = v.mainTex.xy;
				o.uvBg = v.bgTex.xy;

				//o.color=v.color;


				float3 viewDir = normalize(ObjSpaceViewDir(v.vertex));
				float rim = 1 - saturate(dot(viewDir, v.normal));
				o.color = _RimColor*pow(rim, _RimPower);


				return o;
			}
		
			fixed4 frag(v2f i) : SV_Target{
				fixed3 rgb = tex2D(_MainTex, i.uv).rgb;
				fixed3 rgbBg = tex2D(_BackTex, i.uv).rgb;

				//将坐标原点移至屏幕中心（原理：在当前点(0.5,0.5)显示点(0,0)的内容，也就是按向量(-0.5,-0.5)平移后的内容）
				float2 pos = float2(i.screenPos.x - 0.5, i.screenPos.y - 0.5);

					float3 finalcolor = rgb;


					///最NB的效果。

					//float4 f2=float4(finalcolor*_Color.a*3.5, 0.7*pow(finalcolor.r*20,0.0001));

					//float4 f2=float4(finalcolor*_Color.a*3.5, 0.2*pow(finalcolor.r*8,3));

					if (_Para1 != 0){
						_Para1 /= 10;
					}

					//混合原色
					i.color.rgb = lerp(i.color.rgb, rgb, _Para1);




				float n = (rgbBg.r + rgbBg.g + rgbBg.b)/3;

				//if (n > 0){


				//		//i.color.rgb *=1.2;
				//		i.color.a *=2 ;
				//		}

						//	float n = (rgb.r + rgb.g + rgb.b) / 2;

						//if (n>0.7){
						//	float c = _RimColor*1.5;
						//}
						//
						//	i.color.a =0.3+pow(n,_Para1);

				float m = 3;
				if (n > 0){
					//m += n * 1;
				}
						i.color.rgb *=m;

						//if (n > 0.2){
						//	i.color.rgb *= n;
						//}
				return i.color;
			}


		//void surf (Input IN, inout SurfaceOutputStandard o) {
		//	// Albedo comes from a texture tinted by color
		//	fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
		//	o.Albedo = c.rgb;
		//	// Metallic and smoothness come from slider variables
		//	o.Metallic = _Metallic;
		//	o.Smoothness = _Glossiness;
		//	o.Alpha = c.a;
		//}
		ENDCG
		}
	}
	FallBack "Diffuse"
}