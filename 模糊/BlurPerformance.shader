// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/BlurPerformance"{
	Properties{
		_Tint("Tint", Color) = (1, 1, 1, 1)
		_MainTex("Texture", 2D) = "white"{}
		_R("Radius", Range(1, 100)) = 1
		_Dis("Distance", Range(1, 100)) = 1
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

				float _Value;
				int _R;
				int _Dis;

				struct VertexData{
					half4 pos:POSITION;
					half2 uv:TEXCOORD0;
				};

				struct Interpolators{
					half4 pos:POSITION;
					half2 uv:TEXCOORD0;
				};


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
				
				half4 GetColor(half2 uv) {

					int R = (int)_R;
					if (R == 1){
						return tex2D(_MainTex, uv);
					}

					float total = 0;
					for (int i = -R; i <= R; i++){

						float dis = R - abs(i / 2);
						dis /= R;
						dis = pow(dis, 3);
						total += dis;
					}



					half4 color = half4(0, 0, 0, 0);
					for (int i = -R; i <= R; i++){
							
						float dis = R - abs(i/2);
						dis /= R;
						dis = pow(dis, 3);
						dis = dis / total;
						

						float u = i*(_MainTex_TexelSize.x)*_Dis;
						float v = i*(_MainTex_TexelSize.y)*_Dis;

						half4 m = tex2D(_MainTex, uv + half2(u, 0));
						half4 n = tex2D(_MainTex, uv + half2(0, v));

						half4 m1 = tex2D(_MainTex, uv + half2(u, v));
						half4 n1 = tex2D(_MainTex, uv + half2(-u, v));

						color += (m + n + m1 + n1)/4*dis;
					}

					//color /= R * 4 + 1;
					
					return color;
				}




				half4 FragmentProgram(Interpolators v2f) : SV_TARGET{
					
					half4 color = GetColor(v2f.uv);

					return color;
				}



					ENDCG
			}

		}


}