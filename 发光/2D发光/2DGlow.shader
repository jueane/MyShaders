Shader "Custom/2DGlow"
{
	Properties{
		
		_Tint("Tint", Color) = (1, 1, 1, 1)
		_MainTex("Texture", 2D) = "white"{}
		_R("Radius", Range(1, 100)) = 1
		_Dis("Distance", Range(1, 5)) = 1

		_GlowColor("GlowColor", Color) = (1,1,1,1)
	}

	SubShader{

			Tags
			{
				"Queue" = "Transparent"
			}

			//发光Pass

			Pass{
				Blend  SrcAlpha OneMinusSrcAlpha
				Cull Off
				

				CGPROGRAM
#pragma vertex VertexProgram

#pragma fragment FragmentProgram
#include "UnityCG.cginc"

				float4 _Tint;
				sampler2D _MainTex;
				half4 _MainTex_TexelSize;
				float4 _MainTex_ST;


				sampler2D _AlphaTex;

				float _Value;
				int _R;
				int _Dis;

				float4 _GlowColor;

				struct Interpolators{
					float4 vertex:POSITION;
					float2 uv:TEXCOORD0;
				};


				Interpolators VertexProgram(float4 vertex:POSITION, float2 uv : TEXCOORD0){
					Interpolators i;

					i.vertex = UnityObjectToClipPos(vertex);
					//i.pos = UnityObjectToClipPos(float4(pos.xy*2,pos.z+0.01,pos.w));


					//i.uv = uv*_MainTex_ST.xy + _MainTex_ST.zw;
					//i.uv = TRANSFORM_TEX(uv, _MainTex);

					i.uv = uv;

					//i.dis = sqrt(pow(pos.x, 2) + pow(pos.y, 2));

					return i;
				}


				float4 GetColor(float2 uv) {

					int R = _R;
					//不模糊
					if (R == 1){
						float4 f = tex2D(_MainTex, uv);
							//f.a = f.r;
							f.rgb *= f.a;

						return f;
					}

					//计算权重和。
					float total;
					for (int i = -R; i <= R; i++){
						for (int j = -R; j <= R; j++){
							//与当前像素的距离
							float dis = R - (abs(i) + abs(j)) / 2;
							dis /= R;
							dis = pow(dis, 5);
							total += dis;
						}
					}

					float4 color = float4(0, 0, 0, 0);
						for (int i = -R; i <= R; i++){
							for (int j = -R; j <= R; j++){

								float dis = R - (abs(i) + abs(j)) / 2;
								dis /= R;
								dis = pow(dis, 5);
								//权重
								dis /= total;

								float u = i*(_MainTex_TexelSize.x)*_Dis;
								float v = j*(_MainTex_TexelSize.y)*_Dis;

								float4 sampleColor = tex2D(_MainTex, uv + float2(u, v));
									color += sampleColor*dis;
							}
						}


					return color;
				}

				float4 FragmentProgram(Interpolators v2f) : SV_TARGET{

					float4 color = GetColor(v2f.uv);

					color.rgb *= 1.5;
					color.rgb = _GlowColor;

					return color;
				}

					ENDCG
			}


			//原色Pass

			Pass{
				Blend  SrcAlpha OneMinusSrcAlpha
				Cull Off

				CGPROGRAM
#pragma vertex VertexProgram

#pragma fragment FragmentProgram
#include "UnityCG.cginc"

				float4 _Tint;
				sampler2D _MainTex;
				half4 _MainTex_TexelSize;
				float4 _MainTex_ST;


				sampler2D _AlphaTex;

				float _Value;
				int _R;
				int _Dis;

				struct Interpolators{
					float4 vertex:POSITION;
					float2 uv:TEXCOORD0;
				};


				Interpolators VertexProgram(float4 vertex:POSITION, float2 uv : TEXCOORD0){
					Interpolators i;

					i.vertex = UnityObjectToClipPos(vertex);
					//i.pos = UnityObjectToClipPos(float4(pos.xy*2,pos.z+0.01,pos.w));


					//i.uv = uv*_MainTex_ST.xy + _MainTex_ST.zw;
					//i.uv = TRANSFORM_TEX(uv, _MainTex);

					i.uv = uv;

					//i.dis = sqrt(pow(pos.x, 2) + pow(pos.y, 2));

					return i;
				}


				float4 GetColor(float2 uv) {

					int R = _R;
					//不模糊
					if (R == 1){
						float4 f = tex2D(_MainTex, uv);
							//f.a = f.r;
							f.rgb *= f.a;

						return f;
					}

					//计算权重和。
					float total;
					for (int i = -R; i <= R; i++){
						for (int j = -R; j <= R; j++){
							//与当前像素的距离
							float dis = R - (abs(i) + abs(j)) / 2;
							dis /= R;
							dis = pow(dis, 5);
							total += dis;
						}
					}

					float4 color = float4(0, 0, 0, 0);
						for (int i = -R; i <= R; i++){
							for (int j = -R; j <= R; j++){

								float dis = R - (abs(i) + abs(j)) / 2;
								dis /= R;
								dis = pow(dis, 5);
								//权重
								dis /= total;

								float u = i*(_MainTex_TexelSize.x)*_Dis;
								float v = j*(_MainTex_TexelSize.y)*_Dis;

								float4 sampleColor = tex2D(_MainTex, uv + float2(u, v));
									color += sampleColor*dis;
							}
						}


					return color;
				}

				float4 FragmentProgram(Interpolators v2f) : SV_TARGET{

					float4 color = GetColor(v2f.uv);

					//混合原色做发光。
					//color = lerp(color, tex2D(_MainTex, v2f.uv), 0.8);
					float4 origin = tex2D(_MainTex, v2f.uv);

					return origin;
				}



					ENDCG
			}




		}

}
