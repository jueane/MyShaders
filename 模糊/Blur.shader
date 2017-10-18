// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Blur"{
	Properties{
		_Tint("Tint", Color) = (1, 1, 1, 1)
		_MainTex("Texture", 2D) = "white"{}
		_R("Radius",Range(1,100)) = 1
		_Dis("Distance", Range(1, 5)) = 1
		[Toggle] _Density("Density", float) = 0
		_Temp("Temp", Range(0,10))=1
		
	}

	SubShader{


			Pass{
				//Blend  SrcAlpha OneMinusSrcAlpha

				CGPROGRAM
#pragma vertex VertexProgram

#pragma fragment FragmentProgram
#include "UnityCG.cginc"

				half4 _Tint;
				sampler2D _MainTex;
				half4 _MainTex_TexelSize;
				half4 _MainTex_ST;

				int _R;
				int _Dis;
				
				float _Density;
				int _Temp;

				struct VertexData{
					half4 pos:POSITION;
					half2 uv:TEXCOORD0;
				};

				struct Interpolators{
					half4 pos:POSITION;
					half2 uv:TEXCOORD0;
					half4 color:COLOR;
				};
				

				half4 GetColor(half2 uv);

				Interpolators VertexProgram(half4 pos:POSITION, half2 uv : TEXCOORD0){
					Interpolators i;

					i.pos = UnityObjectToClipPos(pos);
					//i.pos = UnityObjectToClipPos(half4(pos.xy*2,pos.z+0.01,pos.w));


					//i.uv = uv*_MainTex_ST.xy + _MainTex_ST.zw;
					//i.uv = TRANSFORM_TEX(uv, _MainTex);

					i.uv = uv;

					//i.dis = sqrt(pow(pos.x, 2) + pow(pos.y, 2));


					return i;
				}


				half4 FragmentProgram(Interpolators v2f) : SV_TARGET{

					half4 color = GetColor(v2f.uv);


					//混合原色做发光。
					//color = lerp(color, tex2D(_MainTex, v2f.uv), 0.5);
					


					return color;
				}


				half4 GetColor(half2 uv) {

					int R = _R;
					//不模糊
					if (R == 1){
						return tex2D(_MainTex, uv);
					}



					//计算权重和。
					half total;
					for (int i = -R; i <= R; i++){
						for (int j = -R; j <= R; j++){
							//与当前像素的距离
							half dis = R - (abs(i) + abs(j)) / 2;
							dis /= R;
							dis = pow(dis, 5);
							total += dis;

							if (_Density == 1){
								j += _Temp;
							}
						}

						if (_Density == 1){
							i += _Temp;
						}
					}

					half4 color = half4(0, 0, 0, 0);
						for (int i = -R; i <= R; i++){
							for (int j = -R; j <= R; j++){

								half dis = R - (abs(i) + abs(j)) / 2;
								dis /= R;
								dis = pow(dis, 5);
								//权重
								dis /= total;

								half u = i*(_MainTex_TexelSize.x)*_Dis;
								half v = j*(_MainTex_TexelSize.y)*_Dis;

								half4 sampleColor = tex2D(_MainTex, uv + half2(u, v));
									color += sampleColor*dis;

								if (_Density == 1){
									j += _Temp;
								}
							}

							if (_Density == 1){
								i += _Temp;
							}
						}

					return color;
				}

					ENDCG
			}

		}


}