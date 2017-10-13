// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Blur"{
	Properties{
		_Tint("Tint", Color) = (1, 1, 1, 1)
		_MainTex("Texture", 2D) = "white"{}
		_Count("Count", Range(1, 100)) = 1
	}

	SubShader{


			Pass{
				//Blend  SrcAlpha OneMinusSrcAlpha

				CGPROGRAM
#pragma vertex VertexProgram

#pragma fragment FragmentProgram
#include "UnityCG.cginc"

				float4 _Tint;
				sampler2D _MainTex;
				half4 _MainTex_TexelSize;
				float4 _MainTex_ST;

				float _Value;
				float _Count;

				struct VertexData{
					float4 pos:POSITION;
					float2 uv:TEXCOORD0;
				};

				struct Interpolators{
					float4 pos:POSITION;
					float2 uv:TEXCOORD0;
				};


				Interpolators VertexProgram(float4 pos:POSITION, float2 uv : TEXCOORD0){
					Interpolators i;

					i.pos = UnityObjectToClipPos(pos);
					//i.pos = UnityObjectToClipPos(float4(pos.xy*2,pos.z+0.01,pos.w));


					//i.uv = uv*_MainTex_ST.xy + _MainTex_ST.zw;
					//i.uv = TRANSFORM_TEX(uv, _MainTex);

					i.uv = uv;

					//i.dis = sqrt(pow(pos.x, 2) + pow(pos.y, 2));

					return i;
				}


				float4 GetColor(float2 uv) {
					
					int Count = (int)_Count;
					if (Count == 1){
						return tex2D(_MainTex, uv);
					}

					float4 color = float4(0, 0, 0, 0);
					for (int i = -Count; i <= Count; i++){
						for (int j = -Count; j <= Count; j++){

							float a = i / Count;
							float b = j / Count;

							float dis = Count - (abs(i) + abs(j)) / 2;
							dis /= Count;
							dis = pow(dis, 5);

							float u = i*(_MainTex_TexelSize.x);
							float v = j*(_MainTex_TexelSize.y);

							float4 s = tex2D(_MainTex, uv + float2(u, v));
								
							color += s*dis;
						}
					}

					color = normalize(color);
					return color;
				}

				float4 FragmentProgram(Interpolators v2f) : SV_TARGET{
					
					float4 color = GetColor(v2f.uv);

					//混合原色做发光。
					//color = lerp(color, tex2D(_MainTex, v2f.uv), 0.2);


					return color;
				}



					ENDCG
			}

		}


}