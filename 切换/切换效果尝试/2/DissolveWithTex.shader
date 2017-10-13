Shader "Custom/DissolveWithTex" {
	Properties{
		_DissAmount("DissAmount", Range(0, 3)) = 0
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BackTex("BackGround", 2D) = "white"{}
		_DisTex("DisTex", 2D) = "white"{}
		_DisTex1("DisTex1", 2D) = "white"{}


		_P1("P1", Range(0, 10)) = 0
			_P2("P2", Range(0, 10)) = 0
			_P3("P3", Range(0, 10)) = 0
			_P4("P4", Range(0, 10)) = 0
			_P5("P5", Range(0, 10)) = 0
			_P6("P6", Range(0, 10)) = 0
			_P7("P7", Range(0, 10)) = 0
			_P8("P8", Range(0, 10)) = 0
			_P9("P9", Range(0, 10)) = 0
			_P10("P10", Range(0, 10)) = 0


	}
	SubShader{
			Tags{
				"RenderQueue" = "Transparent"


			}

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			Pass{

					CGPROGRAM
#pragma vertex vert
#pragma fragment frag
#include "UnityCG.cginc"


					float _DissAmount;
					sampler2D _MainTex;
					fixed4 _MainTex_TexelSize;
					sampler2D _BackTex;
					sampler2D _DisTex;

					float _P1;
					float _P2;
					float _P3;
					float _P4;
					float _P5;
					float _P6;
					float _P7;
					float _P8;
					float _P9;
					float _P10;

					struct a2v {
						float4 vertex:POSITION;

						float4 mainTex:TEXCOORD0;
						float4 bgTex:TEXCOORD1;
						float4 disTex:TEXCOORD1;
					};

					struct v2f{
						float4 pos:SV_POSITION;
						float4 screenPos:TEXCOORD3;

						float2 uv:TEXCOORD0;
						float2 uvBg:TEXCOORD1;
					};


					float4 alg1(float2 scrPos, float2 uv);
					float4 alg3(float2 scrPos, float2 uv);
					float4 alg4(float2 scrPos, float2 uv);
					float shapeAlg1(float2 scrPos, float2 uv);

					v2f vert(a2v v){
						v2f o;
						o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
						o.screenPos = ComputeScreenPos(o.pos);


						o.uv = v.mainTex.xy;
						o.uvBg = v.bgTex.xy;
						return o;
					}

					fixed4 frag(v2f i) : SV_Target{

						//将坐标原点移至屏幕中心（原理：在当前点(0.5,0.5)显示点(0,0)的内容，也就是按向量(-0.5,-0.5)平移后的内容）
						float2 pos = float2(i.screenPos.x - 0.5, i.screenPos.y - 0.5);
						pos.x *= 1.2;

						float4 fc;


						//方式1
						//fc = alg1(pos, i.uv);

						fc = alg4(pos, i.uv);



						return float4(fc);
					};

					float4 alg3(float2 scrPos, float2 uv){
						float4 fc;
						//当前点离屏幕中心的距离
						float x = scrPos.x;
						float y = scrPos.y;
						float r = sqrt(pow(x, 2) + pow(y, 2));

						float offset = 0.05;

						if (uv.x < 0.1&&uv.y>0){
							uv.x += _P1*offset;
							uv.y += _P1*offset;

						}
						else if (uv.x < 0.2&&uv.y>0){
							uv.x += _P2*offset;
							uv.y += _P2*offset;

						}
						else if (uv.x < 0.3&&uv.y>0){
							uv.x += _P3*offset;
							uv.y += _P3*offset;

						}
						else if (uv.x < 0.4&&uv.y>0){
							uv.x += _P4*offset;
							uv.y += _P4*offset;

						}
						else if (uv.x < 0.5&&uv.y>0){
							uv.x += _P5*offset;
							uv.y += _P5*offset;

						}
						else if (uv.x < 0.6&&uv.y>0){
							uv.x += _P6*offset;
							uv.y += _P6*offset;

						}
						else if (uv.x < 0.7&&uv.y>0){
							uv.x += _P7*offset;
							uv.y += _P7*offset;

						}
						else if (uv.x < 0.8&&uv.y>0){
							uv.x += _P8*offset;
							uv.y += _P8*offset;

						}
						else if (uv.x < 0.9&&uv.y>0){
							uv.x += _P9*offset;
							uv.y += _P9*offset;

						}
						else{
							uv.x += _P10*offset;
							uv.y += _P10*offset;

						}

						fixed3 rgb = tex2D(_MainTex, uv).rgb;
						fixed3 rgbBg = tex2D(_BackTex, uv).rgb;




						fc = float4(rgb, 1);
						//if (r < _DissAmount / 3+){
						//	fc.rgb = rgbBg;
						//}
						//else{
						//	fc.rgb = rgb;
						//	//fc.rgb = lerp(rgb, rgbBg, r);
						//}

						//fc.rgb = lerp(rgb, rgbBg, r);


						return fc;
					}

					float4 alg1(float2 scrPos, float2 uv){

						//当前点离屏幕中心的距离
						float x = scrPos.x;
						float y = scrPos.y;




						float r = sqrt(pow(x, 2) + pow(y, 2));

						//float r = sqrt(pow(pos.x, 2) + pow(pos.y, 2));

						float t;

						float theta = atan2(y, x);

						float e = 2.71828;
						float pi = 3.14159;


						float blurValue = 0.0035;
						fixed4 disBg = tex2D(_DisTex, uv);
						fixed4 disBg1 = tex2D(_DisTex, uv + float2(0, blurValue));
						fixed4 disBg2 = tex2D(_DisTex, uv + float2(blurValue, 0));
						fixed4 disBg3 = tex2D(_DisTex, uv + float2(0, -blurValue));
						fixed4 disBg4 = tex2D(_DisTex, uv + float2(-blurValue, 0));
						disBg = (disBg + disBg1 + disBg2 + disBg3 + disBg4) / 5;



						blurValue = 0.002;
						//disBg = tex2D(_DisTex, uv);
						disBg1 = tex2D(_DisTex, uv + float2(0, blurValue));
						disBg2 = tex2D(_DisTex, uv + float2(blurValue, 0));
						disBg3 = tex2D(_DisTex, uv + float2(0, -blurValue));
						disBg4 = tex2D(_DisTex, uv + float2(-blurValue, 0));

						disBg = (disBg + disBg1 + disBg2 + disBg3 + disBg4) / 5;





						blurValue = 0.0055;
						//disBg = tex2D(_DisTex, uv);
						disBg1 = tex2D(_DisTex, uv + float2(0, blurValue));
						disBg2 = tex2D(_DisTex, uv + float2(blurValue, 0));
						disBg3 = tex2D(_DisTex, uv + float2(0, -blurValue));
						disBg4 = tex2D(_DisTex, uv + float2(-blurValue, 0));

						disBg = (disBg + disBg1 + disBg2 + disBg3 + disBg4) / 5;


						float s32 = pow(e, sin(theta)) + cos(3 * theta);


						//尝试
						float s7 = pow(e, sin(theta)) - 0.7*cos(5 * theta - 0.7);

						_DissAmount *= 4;
						float inc = r*(12 + s7) - _DissAmount;
						//加上形变
						inc -= 0.35*r*s32*_DissAmount;

						float edge = 0.5;
						inc += 7;
						t = 1 - smoothstep(0, 1, inc*edge - 6 * disBg.r*0.4);






						fixed3 rgb = tex2D(_MainTex, uv).rgb;
						fixed3 rgbBg = tex2D(_BackTex, uv).rgb;
						float4 fc;
						fc.a = 1;
						fc.rgb = lerp(rgb, rgbBg, t);
						if (t > 0.5&&t < 1){

							////t = tan(t) / cos(t);

							//float v1 = 1 - abs(0.6 - t) / 0.3;
							////v1 = sin(v1);
							//fc.a = v1;

							//fc.rgb = float3(0.3 + v1, 0.4 + v1, 1 + v1);




							float v1 = 0.7 - abs(r - 1.9*t + 0.8);
							//float v1 = 0.8 - abs(0.57 - t) / 0.11;
							fc.a = v1;

							//float rgbT = float3(0.4+v1 , 0.5+v1 , 1 )*(0.5+v1);
							float3 rgbT = float3(v1, v1, 1 + t)*(1.5 + v1);

								if (s32 < 0.7){
									rgbT = float3(0, 0, 0.9 + s7*t)*(1 - s32);

								}


							fc.rgb = lerp(fc.rgb, rgbT, v1);

							fc.a *= pow(fc.a*(4 * r), 10);

						}
						else{
							fc.a = 1;
						}


						return float4(fc);
					}

					float4 alg4(float2 srcPos, float2 uv){
						float2 pixSize = _MainTex_TexelSize.xy;

							float ret = 0;


						pixSize *= 5;

						float ret1 = shapeAlg1(srcPos, uv);




						fixed3 rgb = tex2D(_MainTex, uv).rgb;
						fixed3 rgbBg = tex2D(_BackTex, uv).rgb;


						float4 fc = float4(1, 1, 0, 1);
							fc.rgb = lerp(rgb, rgbBg, ret1);



						float outBorderWidth =0.5;
						float inBorderWidth = 1;
						if (ret1 > 1 - outBorderWidth && ret1 < inBorderWidth){

							fc = float4(0.3, 0.6, 1, 1 - ret1);
							fc.rgb *= 1.6;
							fc.a *= 2;
						}
						else{
						}



						return fc;

					}

					float shapeAlg1(float2 scrPos, float2 uv){

						//当前点离屏幕中心的距离
						float x = scrPos.x;
						float y = scrPos.y;


						float2 pixSize = _MainTex_TexelSize.xy * 15;

							fixed4 disBg = tex2D(_DisTex, uv);
						fixed4 disBg1 = tex2D(_DisTex, uv + pixSize);
						fixed4 disBg2 = tex2D(_DisTex, uv - pixSize);
						fixed4 disBg3 = tex2D(_DisTex, uv + float2(pixSize.x, -pixSize.y));
						fixed4 disBg4 = tex2D(_DisTex, uv + float2(-pixSize.x, pixSize.y));

						disBg = (disBg + disBg1 + disBg2 + disBg3 + disBg4) / 5;



						float r = sqrt(pow(x, 2) + pow(y, 2));

						//float r = sqrt(pow(pos.x, 2) + pow(pos.y, 2));

						float t;

						float theta = atan2(y, x);

						float e = 2.71828;
						float pi = 3.14159;

						float s32 = pow(e, sin(theta)) + cos(3 * theta);


						//尝试
						float s7 = pow(e, sin(theta)) - 0.7*cos(5 * theta - 0.7);

						_DissAmount *= 4;
						float inc = r*(12 + s7) - _DissAmount;
						//加上形变
						inc -= 0.35*r*s32*_DissAmount;

						float edge = 0.5;
						inc += 7;
						t = 1 - smoothstep(0, 1, inc*edge - 6 * disBg.r*0.4);


						return t;
					}

					float alg2(){

						float range = 0.01;
						float width = 0.1;

						//if (t > 0 && t < 0.1){
						//	return float4(0.7, 0.6, 1, disBg.a);
						//}
						//else{
						//	float size = 0.005;
						//	bool a = false;
						//	for (int j = 0; j < 20; j++){
						//		float n1 = sqrt(pow(0.001, 2) - pow(j*size - x, 2)) + y;
						//		float n2 = - sqrt(pow(0.001, 2) - pow(j*size - x, 2)) + y;

						//		fixed4 d91 = tex2D(_DisTex, float2(j*size, n1));
						//		fixed4 d92 = tex2D(_DisTex, float2(j*size, n2));

						//		float t91 = 1 - smoothstep(0, 1, inc*edge - 6 * d91.r*0.8);
						//		if (t91 > 0 && t91 < 0.1){
						//			a = true;
						//			break;
						//		}
						//		float t92 = 1 - smoothstep(0, 1, inc*edge - 6 * d92.r*0.8);
						//		if (t92 > 0 && t92 < 0.1){
						//			a = true;
						//			break;
						//		}



						//	}
						//	if (a){
						//		return float4(0.7, 0.6, 1, disBg.a);

						//	}


						//	float jkl = testa();
						//	if ( jkl>3){
						//		return float4(1, 1, 1, 1);
						//	}


						//	//fixed4 d2 = tex2D(_DisTex, i.uv + float2(0, range));
						//	//float t2 = 1 - smoothstep(0, 1, inc*edge - 6 * d2.r*0.8);

						//	//fixed4 d3 = tex2D(_DisTex, i.uv + float2(0, -range));
						//	//float t3 = 1 - smoothstep(0, 1, inc*edge - 6 * d3.r*0.8);

						//	//fixed4 d4 = tex2D(_DisTex, i.uv + float2(range, 0));
						//	//float t4 = 1 - smoothstep(0, 1, inc*edge - 6 * d4.r*0.8);

						//	//fixed4 d5 = tex2D(_DisTex, i.uv + float2(-range, 0));
						//	//float t5 = 1 - smoothstep(0, 1, inc*edge - 6 * d5.r*0.8);


						//	//if (t2 > 0 && t2 < width&&t3 > 0 && t3 < width&&t4 > 0 && t4 < width&&t5 > 0 && t5 < width){
						//	//	return float4(0,0, 1, disBg.a)/1.2;

						//	//}

						//}
					}

					ENDCG
				}
		}
}