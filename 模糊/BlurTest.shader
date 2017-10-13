Shader "Custom/BlurTest" {
	Properties{

		_BlurValue("BlurValue", Range(0, 10)) = 0
		_MainTex("Albedo (RGB)", 2D) = "white" {}


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

				int _BlurValue;
				sampler2D _MainTex;
				fixed4 _MainTex_TexelSize;


				struct a2v {
					float4 vertex:POSITION;
					float4 mainTex:TEXCOORD0;
				};

				struct v2f{
					float4 pos:SV_POSITION;
					float4 screenPos:TEXCOORD3;

					float2 uv:TEXCOORD0;
				};


				float4 samplerAlg1(float2 scrPos, float2 uv);

				float4 alg2(float2 scrPos, float2 uv, int count);

				v2f vert(a2v v){
					v2f o;
					o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
					o.screenPos = ComputeScreenPos(o.pos);
					o.uv = v.mainTex.xy;
					return o;
				}

				fixed4 frag(v2f i) : SV_Target{

					//将坐标原点移至屏幕中心（原理：在当前点(0.5,0.5)显示点(0,0)的内容，也就是按向量(-0.5,-0.5)平移后的内容）
					float2 pos = float2(i.screenPos.x - 0.5, i.screenPos.y - 0.5);
					pos.x *= 1.2;

					float4 fc = samplerAlg1(pos, i.uv);


						//方式1
						//fc = alg1(pos, i.uv);


						return float4(fc);
				};


				float4 samplerAlg1(float2 scrPos, float2 uv){
					int count = _BlurValue*2;

					float4 fc = alg2(scrPos, uv, count);


						return fc;
				}


				float4 alg2(float2 scrPos, float2 uv, int size){
					float4 fc = float4(0, 0, 0, 0);
						float max = _MainTex_TexelSize.x*size;

					for (int i = 0; i < size; i++){


						float dis = lerp(0, max, i*_MainTex_TexelSize.x);


						float2 pixSize = _MainTex_TexelSize.xy * i;


							fixed4 rgb1 = tex2D(_MainTex, uv + pixSize);
						fixed4 rgb2 = tex2D(_MainTex, uv - pixSize);
						fixed4 rgb3 = tex2D(_MainTex, uv + float2(pixSize.x, -pixSize.y));
						fixed4 rgb4 = tex2D(_MainTex, uv + float2(-pixSize.x, pixSize.y));


						fixed4 rgb5 = tex2D(_MainTex, uv + float2(pixSize.x, 0));
						fixed4 rgb6 = tex2D(_MainTex, uv + float2(-pixSize.x, 0));
						fixed4 rgb7 = tex2D(_MainTex, uv + float2(0, -pixSize.y));
						fixed4 rgb8 = tex2D(_MainTex, uv + float2(0, pixSize.y));

						//fc += rgb1 + rgb2 + rgb3 + rgb4 + rgb5 + rgb6 + rgb7 + rgb8;


						fc += rgb1 + rgb2 + rgb3 + rgb4 + rgb5 + rgb6 + rgb7 + rgb8;

						fc *= 1 - dis;
					}

					fc += tex2D(_MainTex, uv);
					fc /= 8 * size + 1;


					return fc;
				}





				ENDCG
			}
	}
}
