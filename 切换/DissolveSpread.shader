Shader "Custom/DissolveSpread" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_DissAmount("DissAmount", Range(0,2)) = 0.2
		_EdgeSize("EdgeSize", Range(-0.2,0.3)) = 0
		//_RandomValue("RandomValue", Float) = 0
		_MainTex("Albedo (RGB)", 2D) = "white" {}

		_BrightnessAmount("Brightness Amount", Range(0.0, 3.0)) = 1.45
		_SaturationAmount("Saturation Amount", Range(0.0, 2.0)) = 1.0
		_ContrastAmount("Contrast Amount", Range(0.0, 2.0)) = 1.6

		_BackTex("BackGround", 2D) = "white"{}
		_DissolveTex("DissolveTex", 2D) = "white" {} // 溶解贴图 
	}
	SubShader {
		Tags{ "Queue" = "Transparent" "LightMode"= "ForwardBase"}
		LOD 200
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGPROGRAM
		#pragma vertex myvert
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _BackTex;
		sampler2D _DissolveTex;

		fixed _BrightnessAmount;
		fixed _SaturationAmount;
		fixed _ContrastAmount;

		fixed4 _Color;
		float _DissAmount;
		//float _RandomValue;
		float _EdgeSize;
		float4 finalColor;

		struct Input {
			float2 uv_MainTex;
			float2 uv_BackTex;
			//float4 screenPos;
			//float2 uv_DissolveTex;
			float4 pos;
		};

		//调整贴图对比度，饱和度，亮度
		float3 ContrastSaturationBrightness(float3 color, float brt, float sat, float con) {
			// Increase or decrease these values to  
			// adjust r, g and b color channels separately  
			float avgLumR = 0.5;
			float avgLumG = 0.5;
			float avgLumB = 0.5;

			// Luminance coefficients for getting luminance from the image  
			float3 LuminanceCoeff = float3 (0.2125, 0.7154, 0.0721);

				// Operation for brightmess  
				float3 avgLumin = float3 (avgLumR, avgLumG, avgLumB);
				float3 brtColor = color * brt;
				float intensityf = dot(brtColor, LuminanceCoeff);
			float3 intensity = float3 (intensityf, intensityf, intensityf);

				// Operation for saturation  
				float3 satColor = lerp(intensity, brtColor, sat);

				// Operation for contrast  
				float3 conColor = lerp(avgLumin, satColor, con);

				return conColor;
		}


		void myvert(inout appdata_full v, out Input IN)
		{
			UNITY_INITIALIZE_OUTPUT(Input, IN);
			IN.pos = mul(UNITY_MATRIX_MVP, v.vertex);
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// 对主材质进行采样 
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
			// 对背景材质进行采样
			fixed4 cb = tex2D(_BackTex, IN.uv_BackTex);
			// 设置主材质和颜色 
			//o.Albedo = c.rgb * _Color.rgb ;

			float posR = sqrt(pow(IN.pos.x * 1.8, 2) + pow(IN.pos.y+0.15, 2));

			if (posR < _DissAmount){
				//cb.rgb = ContrastSaturationBrightness(cb.rgb, _BrightnessAmount, _SaturationAmount, _ContrastAmount);
				o.Albedo = cb.rgb;
				//clip(-0.1);
			}
			else{

				float noiseColor = tex2D(_DissolveTex, float2(IN.pos.x ,IN.pos.y)).r;
				//控制渐变颜色范围大小
				float lerpV = 4.0 * (posR - _DissAmount) * noiseColor;
				if (lerpV < 0 || lerpV > 1){
					lerpV = lerpV / lerpV;
				}
				//控制外边缘大小
				if (posR >= _DissAmount  && posR <= _DissAmount + _EdgeSize + noiseColor){
					//圆外层边缘的颜色
					finalColor = lerp(cb, c, lerpV);
				}
				else{
					//1.35调整背景亮度
					finalColor.rgb = c.rgb;
				}
				// 融合 
				o.Albedo = finalColor.rgb;
			}
			o.Alpha = c.a * _Color.a;
			o.Albedo.rgb = ContrastSaturationBrightness(o.Albedo.rgb, _BrightnessAmount, _SaturationAmount, _ContrastAmount);
		}
		ENDCG
	}
	FallBack "Diffuse"
}
